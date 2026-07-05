---
name: new-site
description: Legt einen neuen Freifunk-Peering-Standort an. Erkennt das nächste freie Subnetz automatisch, generiert WireGuard-Keypairs mit kbu-Prefix (beliebige Groß-/Kleinschreibung: kbu, KBU, kBU, Kbu etc.), verschlüsselt Private Keys mit ansible-vault (Vault-ID ffkbu, kein manuelles Passwort nötig) und hängt die Konfigurationsblöcke an wireguard.yml und ibgp.yml an. Vollautomatisch. Invoke with /new-site.
---

# Neuen Freifunk-Peering-Standort anlegen

## Schritt 1: Nächstes freies Subnetz ermitteln

```bash
grep '^\s*port:' ansible/env_prd/group_vars/exitnode/wireguard.yml \
  | awk '{print $2}' | sort -n | tail -1
```

Berechne: `next_port = last_port + 1`, `next_N = next_port - 19300`

## Schritt 2: Benutzer befragen

Frage per `AskUserQuestion` in einer einzigen Anfrage:
1. **Standortname** — nur neutrale Platzhalter als Options (z.B. "→ Namen im 'Other'-Feld eingeben"), kein konkreter Namensvorschlag.
2. **Subnetz-Nummer N** — auto-erkannten Wert als empfohlene Option, 'Other' für abweichenden Wert.

**Kein Vault-Passwort abfragen** — `ANSIBLE_VAULT_IDENTITY_LIST=ffkbu@~/vaultpass_ffkbu` ist in der Shell gesetzt, ansible-vault läuft vollautomatisch.

## Schritt 3: Übersicht anzeigen und Bestätigung einholen

Berechne alle abgeleiteten Werte (`PORT = 19400 + N - 100`, `DATA_N = N + 100`) und zeige sie als Text:

```
========================================
  Neuer Standort: Übersicht
========================================
  Standortname:      <name>
  Interface:         wg_<name>
  WireGuard-Port:    <PORT>
  Subnetz N:         <N>
  Data-Subnetz:      <DATA_N>

  Server-Tunnel (exitnode):
    en01:  10.<N>.0.1/32   2a03:2260:101a:<N>::1/128
    en02:  10.<N>.0.2/32   2a03:2260:101a:<N>::2/128

  Client-Tunnel (Remote-Site):
    en01:  10.<N>.0.11/32  2a03:2260:101a:<N>::11/128
    en02:  10.<N>.0.12/32  2a03:2260:101a:<N>::12/128

  Allowed IPs (Client):
    - 10.<N>.0.0/24
    - 10.<DATA_N>.0.0/16
    - 2a03:2260:101a:<N>::/64
    - 2a03:2260:101a:<DATA_N>::/64

  Zu ändernde Dateien:
    - ansible/env_prd/group_vars/exitnode/wireguard.yml
    - ansible/env_prd/group_vars/exitnode/bird/ibgp.yml
========================================
```

Frage per `AskUserQuestion`: "Konfiguration so anlegen?" Erst bei Zustimmung weiter.

## Schritt 4: Alles automatisch ausführen

Konstruiere das Bash-Kommando mit `NAME` und `N` eingesetzt. Führe es mit **Timeout 300000ms** aus.

**Hinweise:**
- kbu-Prefix: jede Groß-/Kleinschreibung ist gültig — `kbu`, `KBU`, `kBU`, `Kbu` etc. Shell-Glob `[Kk][Bb][Uu]*` prüft dies ohne Subprozess.
- 4 parallele Worker halbieren die durchschnittliche Wartezeit auf ~15s pro Keypair.
- Vault: `--encrypt-vault-id ffkbu` (kein `--vault-id`, kein `@prompt`) — liest Passwort automatisch aus `~/vaultpass_ffkbu`.
- Nach jeder Vault-Operation prüfen ob `$ANSIBLE_VAULT` im Output enthalten ist, sonst `exit 1`.

```bash
set -euo pipefail
set +x  # xtrace aus Umgebung unterdrücken (verhindert Ausgabe aller generierten Private Keys)

NAME="__NAME__"
N=__N__
PORT=$((19400 + N - 100))
DATA_N=$((N + 100))
INTERFACE="wg_${NAME}"
REPO_DIR="/Users/juz/repos/ffkbu-deployments"
WG_YML="${REPO_DIR}/ansible/env_prd/group_vars/exitnode/wireguard.yml"
BGP_YML="${REPO_DIR}/ansible/env_prd/group_vars/exitnode/bird/ibgp.yml"
NWORKERS=4

# Funktion: generiert WireGuard-Keypair mit kbu-Prefix (case-insensitiv)
# Schreibt "PRIV\nPUB" atomar in $1 sobald ein gültiger Key gefunden wurde
_gen_kbu_key() {
  local result_file="$1"
  while [ ! -f "$result_file" ]; do
    local priv pub
    priv=$(wg genkey)
    pub=$(wg pubkey <<< "$priv")
    case "$pub" in
      [Kk][Bb][Uu]*)
        printf '%s\n%s' "$priv" "$pub" > "${result_file}.tmp.$$"
        mv "${result_file}.tmp.$$" "$result_file" 2>/dev/null \
          || rm -f "${result_file}.tmp.$$"
        return
        ;;
    esac
  done
}

echo "==> Generiere Server-Keypair mit kbu-Prefix [Kk][Bb][Uu] (4 Worker)..."
SERVER_RESULT=$(mktemp -u /tmp/wg_srv_XXXXXX)
for _i in $(seq 1 $NWORKERS); do _gen_kbu_key "$SERVER_RESULT" & done
while [ ! -f "$SERVER_RESULT" ]; do sleep 0.05; done
kill $(jobs -p) 2>/dev/null || true; wait 2>/dev/null || true
server_priv=$(sed -n '1p' "$SERVER_RESULT")
server_pub=$(sed -n '2p' "$SERVER_RESULT")
rm -f "$SERVER_RESULT"
echo "    Server-Public-Key: ${server_pub}"

echo "==> Generiere Client-Keypair mit kbu-Prefix [Kk][Bb][Uu] (4 Worker)..."
CLIENT_RESULT=$(mktemp -u /tmp/wg_cli_XXXXXX)
for _i in $(seq 1 $NWORKERS); do _gen_kbu_key "$CLIENT_RESULT" & done
while [ ! -f "$CLIENT_RESULT" ]; do sleep 0.05; done
kill $(jobs -p) 2>/dev/null || true; wait 2>/dev/null || true
client_priv=$(sed -n '1p' "$CLIENT_RESULT")
client_pub=$(sed -n '2p' "$CLIENT_RESULT")
rm -f "$CLIENT_RESULT"
echo "    Client-Public-Key: ${client_pub}"

echo "==> Verschlüssele Server Private Key (ansible-vault, Vault-ID: ffkbu)..."
server_vault_full=$(printf '%s' "${server_priv}" | ansible-vault encrypt_string \
  --encrypt-vault-id ffkbu \
  --stdin-name 'private_key')
echo "${server_vault_full}" | grep -q 'ANSIBLE_VAULT' \
  || { echo "ERROR: Vault-Verschlüsselung Server-Key fehlgeschlagen"; exit 1; }
server_vault_lines=$(echo "${server_vault_full}" | tail -n +2 | sed 's/^[[:space:]]*/      /')

echo "==> Verschlüssele Client Private Key (ansible-vault, Vault-ID: ffkbu)..."
client_vault_full=$(printf '%s' "${client_priv}" | ansible-vault encrypt_string \
  --encrypt-vault-id ffkbu \
  --stdin-name 'private_key')
echo "${client_vault_full}" | grep -q 'ANSIBLE_VAULT' \
  || { echo "ERROR: Vault-Verschlüsselung Client-Key fehlgeschlagen"; exit 1; }
client_vault_lines=$(echo "${client_vault_full}" | tail -n +2 | sed 's/^[[:space:]]*/          /')

echo "==> Hänge WireGuard-Block an wireguard.yml an..."
cat >> "${WG_YML}" << WGYML

  - interface: ${INTERFACE}
    port: ${PORT}
    public_key: ${server_pub}
    private_key: !vault |
${server_vault_lines}
    address4: "10.${N}.0.{{ groups['exitnode'].index(inventory_hostname) | int + 1 }}/32"
    address6: "2a03:2260:101a:${N}::{{ groups['exitnode'].index(inventory_hostname) | int + 1 }}/128"
    wireguard_clients_dir: /opt/wireguard/client_configs
    wireguard_endpoint: "{{ hcloud_dns_ptr }}"
    wireguard_clients:
      - name: ${INTERFACE}
        address4: "10.${N}.0.{{ groups['exitnode'].index(inventory_hostname) | int + 11 }}/32"
        address6: "2a03:2260:101a:${N}::{{ groups['exitnode'].index(inventory_hostname) | int + 11 }}/128"
        public_key: ${client_pub}
        private_key: !vault |
${client_vault_lines}
        allowed_ips:
          - 10.${N}.0.0/24
          - 10.${DATA_N}.0.0/16
          - 2a03:2260:101a:${N}::/64
          - 2a03:2260:101a:${DATA_N}::/64
WGYML

echo "==> Hänge BGP-Block an ibgp.yml an..."
cat >> "${BGP_YML}" << BGPYML

  - protocol: bgp
    name: ${NAME}
    description: iBGP ${NAME}
    neighbor:
      ip: "10.${N}.0.{{ groups['exitnode'].index(inventory_hostname) | int + 11 }}"
      as: "{{ ffrl_as_local }}"
    local:
      ip: 10.${N}.0.{{ groups['exitnode'].index(inventory_hostname) | int + 1 }}
      as: "{{ ffrl_as_local }}"
    options:
      - hold time 60
    ipv4: "{{ bird_ibgp_default_filter_ipv4 }}"
    ipv6: "{{ bird_ibgp_default_filter_ipv6 }}"
BGPYML

echo "==> Validiere YAML-Syntax..."
yq eval '.' "${WG_YML}" > /dev/null && echo "    wireguard.yml: OK"
yq eval '.' "${BGP_YML}" > /dev/null && echo "    ibgp.yml:      OK"

echo ""
echo "============================================================"
echo "  Standort '${NAME}' erfolgreich konfiguriert!"
echo "============================================================"
echo "  Interface:        ${INTERFACE}"
echo "  Port:             ${PORT}"
echo "  Subnetz N:        ${N}  /  Data-Subnetz: ${DATA_N}"
echo "  Server PubKey:    ${server_pub}"
echo "  Client PubKey:    ${client_pub}"
echo "============================================================"
echo "  Private Keys sind vault-verschluesselt (Vault-ID: ffkbu)"
echo "============================================================"
```

## Schritt 5: Zusammenfassung

Zeige nach Abschluss Interface, Port, Subnetz, beide Public Keys und die geänderten Dateien. Empfohlener nächster Schritt: `git diff ansible/env_prd/group_vars/exitnode/`

**Private Keys niemals im Klartext ausgeben.**
