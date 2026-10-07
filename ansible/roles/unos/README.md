# Ansible Role: UniFi OS Server (Docker)

Deploys UniFi OS Server in Docker, using the community image
[unihosted/unifi-os-server-docker](https://github.com/unihosted/unifi-os-server-docker),
with optional Let's Encrypt certificates.

The image is not supported by Ubiquiti and has no in-app updater. Upgrade by bumping
`unifi_os_image_tag` after taking a backup.

## Requirements

- Ansible installed on the control machine.
- Docker installed on the target machine.
- A reverse proxy (nginx role) that terminates TLS for the web UI, see Notes.

## Role Variables

```yaml
# defaults/main.yml

unifi_os_image: ghcr.io/unihosted/unifi-os-server-docker
unifi_os_image_tag: "5.1.42"
unifi_os_directory: /opt/unifi-os

# Address devices use to reach the controller (inform host)
unifi_system_ip: 127.0.0.1

# Watchtower must not update this container
unifi_watchtower_active: false

unifi_https_bind_address: 127.0.0.1
unifi_https_port: 11443
unifi_stun_bind_address: 127.0.0.1
unifi_http_bind_address: 0.0.0.0
unifi_speedtest_bind_address: 0.0.0.0
```

## Ports

| Host | Container | Use |
|---|---|---|
| 8080/tcp | 8080 | device inform |
| 127.0.0.1:11443/tcp | 443 | web UI, only for the reverse proxy (nginx serves it on 443) |
| 6789/tcp | 6789 | speedtest |
| 3478/udp | 3478 | STUN |
| 10003/udp | 10003 | discovery |

PostgreSQL (5432) is deliberately not published.

## Migration from the Network Server

The role removes the old `unifi` container but leaves its data in `/opt/unifi`.
Restore a `.unf` backup in the new UI under Network, Settings, Control Plane, Backups.

## Notes

- unifi-core regenerates its own self-signed certificate (CN=unifi.local) unless one was uploaded through the UI,
  so a certificate cannot simply be copied into the container. The web UI is published on localhost only
  and nginx terminates TLS with the certbot certificate on port 443 (see `nginx_sites` of the host).
- Deploy order when the UI port changes: this role first (frees the host port), then the nginx role.
