# Ansible Role: pstat

Deploy the pstat script as a mini web server with systemd service. The pstat script checks the availability of specified TCP ports locally and provides a simple web interface to query their status.

## Requirements

- Target system for deployment.

## Introduction

The pstat script serves as a lightweight web server, checking the local availability of specified TCP ports. It responds with a status of "Up" if the port is accessible and "Down" otherwise. This role automates the deployment and configuration of the pstat script along with a systemd service for convenient management.

## Role Variables

The role includes the following variable, which you can customize in your playbook:

- `pstat_directory: "/opt/pstat"`: The directory where the pstat script and related files will be stored.

## Dependencies

None.

## Example Playbook

Here's an example playbook demonstrating how to use the pstat role:

```yaml
- hosts: your_target_servers
  roles:
    - role: pstat
```
