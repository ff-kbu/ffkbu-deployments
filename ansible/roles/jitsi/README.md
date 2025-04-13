# Ansible Role: Jitsi

An Ansible role for deploying Jitsi Meet using Docker containers.

## Requirements

- Docker must be installed on the target system.

## Role Variables

- `jitsi_version`: The version of Jitsi Meet to install (default: `stable-8960-1`).
- `jitsi_domain`: The domain for Jitsi Meet (default: `meet.kbu.freifunk.net`).
- `jitsi_http_port`: The HTTP port (default: `127.0.0.1:8000`).
- `jitsi_https_port`: The HTTPS port (default: `127.0.0.1:8443`).
- `jitsi_timezone`: System time zone (default: `CET`).
- `jitsi_jvb_advertise_ips`: List of IP addresses to advertise for Jitsi Videobridge.
- `jitsi_letsencrypt_active`: Whether to enable Let's Encrypt certificate generation (default: `0`).
- `jitsi_letsencrypt_domain`: Domain for Let's Encrypt certificate.
- `jitsi_letsencrypt_email`: Email for Let's Encrypt notifications.
- `jitsi_etherpad_base`: Etherpad-lite URL in the docker local network.
- `jitsi_etherpad_public_url`: Etherpad-lite public URL.
- `jitsi_etherpad_title`: Name of the Etherpad instance.
- `jitsi_etherpad_text`: Default text of a pad.
- `jitsi_etherpad_skin_name`: Name of the skin for Etherpad.
- `jitsi_etherpad_skin_variants`: List of skin variants for Etherpad.
- `jitsi_docker_directory`: Directory where Docker files will be stored (default: `/opt/jitsi/docker`).
- `jitsi_config_directory`: Directory where configuration will be stored (default: `/opt/jitsi/config`).

## Dependencies

None

## Example Playbook

```yaml
- hosts: jitsi
  roles:
    - role: jitsi
