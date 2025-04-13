# Ansible Role: Nginx

This Ansible role, `nginx`, is designed for configuring and managing Nginx web servers on Debian-based systems. It includes tasks for installing Nginx, configuring SSL certificates, managing site configurations, and more. This README provides an overview of the role's purpose, variables that can be customized, and the tasks it performs.

## Role Purpose

The `nginx` role automates the deployment and configuration of Nginx web servers, making it easy to set up and manage web hosting on Debian-based systems. Key features include:

- Installation of required packages and dependencies.
- Configuration of SSL certificates for secure websites.
- Management of Nginx site configurations, including custom log formats.
- Handling of SSL certificate and private key files.
- Optional LDAP integration for authentication.

## Variables

Customize the behavior of the `nginx` role by modifying the following variables in your playbook or inventory files:

### Package Management

- `nginx_apt_packages`: List of APT packages required for Nginx.
- `nginx_pip_packages`: List of Python packages to be installed using pip.

### SSL Certificate Management

- `nginx_ssl_certificates`: List of SSL certificates and associated configurations.

### Site Configuration

- `nginx_sites`: List of Nginx site configurations, including virtual hosts, SSL settings, and authentication.

### File Paths and Settings

- `nginx_log_path`: Path to Nginx log files.
- `nginx_auth_path`: Path for storing authentication files.
- `nginx_syslog_server`: Syslog server configuration (optional).

### Additional Configuration

- `nginx_use_access_log`: Control whether to enable access logging.
- `nginx_use_ipv6`: Control whether to enable IPv6 support.
- `nginx_disable_cache_tweaks`: Disable Nginx caching tweaks.

## Tasks

The `nginx` role performs various tasks to set up and manage Nginx on your server. These tasks include:

- Installation of required APT packages and Python packages.
- Disabling service autostart temporarily for installation.
- Installing Nginx via APT.
- Generating Diffie-Hellman parameters (DH param) for SSL.
- Configuring SSL certificates and keys.
- Managing Nginx site configurations.
- Testing Nginx configuration and reloading/restarting Nginx.

## Usage

To use the `nginx` role in your playbook, include it as follows:

```yaml
---
- name: Apply Nginx configuration
  hosts: your_servers
  become: true
  roles:
    - nginx
