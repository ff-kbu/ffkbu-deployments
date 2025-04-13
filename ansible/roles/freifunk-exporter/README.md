# Ansible Role: Freifunk Exporter

This Ansible role, `freifunk-exporter`, is designed for deploying and configuring the [Freifunk Exporter](https://github.com/xperimental/freifunk-exporter) tool. The Freifunk Exporter queries JSON data from the Meshviewer map and exposes it as metrics for Prometheus. This README provides an overview of the role's purpose, variables that can be customized, and the tasks it performs.

## Role Purpose

The `freifunk-exporter` role automates the deployment and configuration of the Freifunk Exporter on your server, making it easy to collect and expose Freifunk network metrics for monitoring with Prometheus. Key features include:

- Downloading and compiling the Freifunk Exporter from source.
- Configuring multiple data sources to query Meshviewer JSON data.
- Creating systemd service units for each data source.
- Enabling and starting the Freifunk Exporter services.

## Variables

Customize the behavior of the `freifunk-exporter` role by modifying the following variables in your playbook or inventory files:

### Installation and Configuration

- `freifunk_exporter_src_url`: URL to download the Freifunk Exporter source code.
- `freifunk_exporter_base_folder`: Base directory for Freifunk Exporter installation.
- `freifunk_exporter_user`: User for running Freifunk Exporter service.
- `freifunk_exporter_group`: Group for the Freifunk Exporter user.

### Data Sources

- `freifunk_exporter_data_sources`: List of data sources to query. Each source includes a name, data URL, and port.

### Service Configuration

- `freifunk_exporter_data_refreshtime`: Time interval for refreshing data sources.
- `freifunk_exporter_bind_address`: IP address to bind the Freifunk Exporter to.

## Tasks

The `freifunk-exporter` role performs various tasks to set up and manage the Freifunk Exporter on your server. These tasks include:

- Checking the availability of the Go programming language.
- Downloading and compiling the Freifunk Exporter.
- Creating user and group for the Freifunk Exporter.
- Configuring data sources and service units.
- Enabling and starting Freifunk Exporter services.

## Usage

To use the `freifunk-exporter` role in your playbook, include it as follows:

```yaml
---
- name: Apply Freifunk Exporter configuration
  hosts: your_servers
  become: true
  roles:
    - freifunk-exporter
