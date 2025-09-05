## Portkonfiguration

| Port  | Zuweisung  |
|-------|------------|
| eth0  | WAN0       |
| eth1  | WAN1 (optional)       |
| eth2  | LAN        |

## Vorbereitung
1. Lade die passende Firmware auf den Host herunter, falls die Firmware nicht `v3.x.x` ist und somit Wireguard nicht ad-hoc unterstützt:
    - Für ER-X, ER-10X, ER-X-SFP und EP-R6:
    [Firmware-Download](https://dl.ui.com/firmwares/edgemax/3.0.0/ER-e50.v3.0.0.5842787.tar)
    - Für ER-4, ER-6P, ER-12 und ER-12P:
    [Firmware-Download](https://dl.ui.com/firmwares/edgemax/3.0.0/ER-e300.v3.0.0.5842788.tar)

    Die Version kann mit dem Befehl `show version` angezeigt werden:
    ```
    Version:      v3.0.0-rc.5
    Build ID:     5669575
    Build on:     11/25/23 00:39
    Copyright:    2012-2023 Ubiquiti, Inc.
    HW model:     EdgeRouter X 5-Port
    HW S/N:       AC8BA9BCC643
    Uptime:       23:17:08 up 3 days,  9:50,  1 user,  load average: 1.05, 1.05, 1.07
    ```
2. Benenne die Firmware-Datei in 'firmware.tar' um.
3. Schließe den Router an den Strom an (falls noch nicht geschehen) und warte 60 Sekunden, damit der Bootvorgang abgeschlossen wird.
4.  Halte den Reset-Knopf des Routers 10 Sekunden lang gedrückt. Warte 60 Sekunden für den Neustart.
5. Trenne den Host von allen Netzwerken (Kabel und/oder WLAN).
6. Wähle eine LAN-Schnittstelle am Host und setze deren IP-Adresse in den Bereich 192.168.1.0/24, wobei 192.168.1.1 für den Router selbst freigelassen wird.

## Initiale Verbindung
1. Verbinde den Router mit `eth0` an die Schnittstelle.
2. Verbinde dich mit ubnt@192.168.1.1 mit dem Passwort 'ubnt'.
3. Überprüfe die Betriebssystemversion: `show version`
4. Falls die Version nicht mit `v3.x` beginnt, fahre mit [`Firmware Aktualisierung`](#Firmware-Aktualisierung) fort, andernfalls gehe zum Punkt [`Konfiguration`](#Konfiguration).

## Firmware Aktualisierung
1. Führe den SCP-Befehl auf dem Host in einem zweiten Terminal mit dem Passwort 'ubnt' aus: 'scp <path/to/firmware.tar> ubnt@192.168.1.1:/tmp/'
2. Im ersten Terminal, das die SSH-Sitzung ausführt, führe aus: 'add system image /tmp/firmware.tar'
3. Führe den Befehl 'reboot' aus und warte 60 Sekunden, bis der Router neu startet.
4. Stelle die SSH-Verbindung wieder her.

## Konfiguration
### Teil 1
1. Setze zuerst die Konfigurationsvariablen in der setup.sh (`ZZZ` und `YYY`), kopiere dann die Konfiguration in die Zwischenablage und führe sie im SSH-Terminal aus. Der Router wird neu starten.
2. Wenn der Router neu startet, trenne den Host von eth0. Warte 60 Sekunden, bis der Bootvorgang abgeschlossen ist.
3. Stelle die Host-Schnittstelle, die zuvor auf 192.168.1.x eingestellt wurde, auf DHCP um.

### Teil 2
1. Verbinde den Host mit `eth2` des Routers. Eine IP-Adresse sollte zugewiesen werden.
2. Verbinde dich erneut via ssh, jedoch nun mit der IP, welche in `ROUTER_IPV4_ADDRESS` definiert wurde. Diese entspricht auch der Gateway IP-Addresse, welche via DHCP zugeteilt wird.
3. Kopiere das Skript, füge es ein und führe es erneut aus. Jetzt wird der verbleibende Teil der Konfiguration angewendet. Der Router startet ein zweites Mal neu.
4. Die Einrichtung ist abgeschlossen. Trenne den Router vom Host und lösche die heruntergeladene Datei 'firmware.tar'.

## Überprüfung
1. Verbinde dich nach dem reboot erneut mit dem Router, diesmal jedoch mit nem neuen Passwort.
2. Der Befehl `show interfaces` sollte nun die konfigurierten Schnittstellen anzeigen, wobei WAN1 optional ist:
    ```
    Interface    IP Address                        S/L  Description
    ---------    ----------                        ---  -----------
    eth0         192.168.2.1/24                    u/D  WAN0
    eth1         192.168.1.241/24                  u/u  WAN1
    eth2         10.205.0.100/16                   u/D  LAN
                2a03:2260:101a:205::100/64
    wg0          10.105.0.11/32                    u/u
                2a03:2260:101a:105::11/128
    wg1          10.105.0.12/32                    u/u
                2a03:2260:101a:105::12/128
    ```

3. Der Befehl `sudo wg show` sollte zwei konfigurierte Wireguard-Peers anzeigen:
    ```
    peer: ***redacted***
    endpoint: 116.202.4.116:19405
    allowed ips: ::/0, 0.0.0.0/0
    latest handshake: 1 minute, 39 seconds ago
    transfer: 237.39 MiB received, 95.67 MiB sent
    persistent keepalive: every 10 seconds

    peer: ***redacted***
    endpoint: 116.203.4.48:19405
    allowed ips: ::/0, 0.0.0.0/0
    latest handshake: 56 seconds ago
    transfer: 22.90 MiB received, 86.09 MiB sent
    persistent keepalive: every 10 seconds
    ```

4. Der Befehl `show ip bgp summary` sollte zwei aktive BGP sessions anzeigen:
    ```
    BGP router identifier 10.105.0.0, local AS number 65528
    BGP table version is 27
    1 BGP AS-PATH entries
    0 BGP community entries

    Neighbor                 V   AS   MsgRcv    MsgSen TblVer   InQ   OutQ    Up/Down   State/PfxRcd
    10.105.0.1               4 65528 16912      14729      27      0      0  3d00h58m               0
    10.105.0.2               4 65528 16937      14729      27      0      0  3d00h58m               0

    Total number of neighbors 2

    Total number of Established sessions 2
    ```
