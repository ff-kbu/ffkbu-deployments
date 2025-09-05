# Ansible Role: certbot-exporter

This role installs and configures **certbot-exporter**, a Prometheus exporter for monitoring Certbot certificates.

## Requirements

- Ansible >= 2.9
- Systemd-based Linux distribution

## Role Variables

The following variables can be customized in `defaults/main.yml` or your playbook:

| Variable | Default | Description |
|----------|---------|-------------|
| `certbot_exporter_user` | `certbot-exp` | The system user for running the exporter |
| `certbot_exporter_group` | `certbot-exp` | The system group for the exporter |
| `certbot_exporter_base_folder` | `/opt/certbot-exporter` | Base installation directory |
| `certbot_exporter_version` | `1.0.0` | Version of the exporter to install |
| `certbot_exporter_download_url` | *URL to release* | Download URL for the exporter binary |

## Handlers

- `restart_certbot_exporter`: Restarts the systemd service after updates.

## Dependencies

None.

## Example Playbook

```yaml
- hosts: exporters
  roles:
    - role: certbot-exporter
      vars:
        certbot_exporter_version: "1.0.0"
        certbot_exporter_download_url: "https://github.com/prometheus-community/certbot_exporter/releases/download/v1.0.0/certbot_exporter"
```

## Service Management

The role installs a systemd service:

```bash
systemctl enable --now certbot_exporter.service
systemctl status certbot_exporter.service
```

## License

MIT

## Author

Your Name <you@example.com>
