# Ansible Role: Homer

An Ansible role to deploy [Homer](https://github.com/bastienwirtz/homer), a customizable web dashboard for your bookmarks and other links.

## Requirements

This role assumes that Docker is installed on the target system. It checks for the presence of the `docker` service as part of the preflight tasks.

## Role Variables

- `homer_install_path`: The base installation path for Homer.
- `homer_container_name`: The name for the Docker container running Homer.
- `homer_image_tag`: The tag for the Homer Docker image.
- `homer_ports`: List of ports to expose for the Homer container.
- `homer_labels`: Additional labels for the Homer Docker container.
- `homer_restart_policy`: Restart policy

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: your_homer_role
      homer_install_path: "/opt/homer"
      homer_container_name: "homer_container"
      homer_image_tag: "latest"
      homer_ports:
        - "8080:80"
      homer_labels:
        - "com.example.label=example"
      homer_restart_policy: "always"
```
