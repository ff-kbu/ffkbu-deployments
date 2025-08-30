# Ansible Role: Base

This Ansible role, `base`, is designed to set up and configure various aspects of a Debian-based system. It covers tasks related to package management, system configuration, SSH key deployment, network settings, and more. This README provides an overview of the role's purpose, variables that can be customized, and the tasks it performs.

## Role Purpose

The `base` role aims to automate the initial setup and configuration of a Debian-based system. It includes tasks such as:

- Package management: Installing, upgrading, and purging packages.
- Repository setup: Configuring APT repositories and managing repository keys.
- SSH key deployment: Deploying SSH keys to the root user.
- System tweaks: Customizing system settings like Grub, MOTD, and Vim.
- Network configuration: Managing network-related settings.
- Firewall rules: Managing IPTables rules.
- System information: Displaying distribution and version information.
- Provisioning status: Checking and setting a provisioning marker.

## Variables

You can customize the behavior of the `base` role by modifying the following variables in your playbook or inventory files:

### Package Management

- `debian_base_packages`: List of Debian packages to be installed.
- `debian_purge_packages`: List of Debian packages to be purged.
- `base_pip_packages`: List of Python packages to be installed using pip.

### APT Repositories

- `base_apt_mirrors_bookworm`: APT mirror configuration for Debian bookworm release.
- `base_apt_mirrors_trixie`: APT mirror configuration for Debian trixie release.


### SSH Key Deployment

- `base_deploy_sshkeys_for_user_root`: List of SSH keys to be deployed to the root user.

### Custom Host Entries

- `base_custom_hosts`: List of custom host entries to be added to the `/etc/hosts` file.

### IPTables Rules

- `base_iptables_rules`: List of IPTables rules to be applied.

### Custom IP Addresses

- `base_extra_ips`: List of custom IP addresses and interfaces to be configured.

## Tasks

The `base` role performs a series of tasks to configure the system. These tasks include:

- Upgrading `pip` if necessary.
- Setting up APT repositories.
- Installing required Debian packages.
- Purging obsolete Debian packages.
- Configuring `iptables` and saving rules.
- Deploying SSH keys to the root user.
- Customizing system settings (e.g., Grub, MOTD, Vim).
- Checking and setting a provisioning marker.
- Displaying system information.
- Configuring network-related settings.

## Usage

You can include this role in your playbook as follows:

```yaml
---
- name: Apply base configuration to servers
  hosts: your_servers
  become: true
  roles:
    - base
