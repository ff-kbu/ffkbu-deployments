# Ansible Role: Bird

This Ansible role is designed for configuring and managing the BIRD Internet Routing Daemon (BIRD) on your systems. BIRD is a fully functional dynamic IP routing daemon primarily targeted at routing IPv4 and IPv6 networks. This role facilitates the installation and configuration of BIRD, setting up various routing protocols as per your requirements.

## Overview

The role performs several tasks including installing BIRD, creating necessary directories and files for BIRD's configuration, setting up routing protocols, and ensuring that the service is correctly configured to work with systemd if needed.

## Requirements

- Ansible 2.9 or higher.
- The target systems should be running a Debian-based distribution since the role uses the `apt` module for installation.
- The role assumes that the system has network connectivity and necessary privileges to install packages and configure system files.

## Role Variables

The role uses several variables to customize its behavior. These are defined in the `defaults.yml` and `vars.yml` files.

### `vars.yml` Variables

- `bird_user`: The user under which the BIRD service will run (default: `bird`).
- `bird_group`: The group under which the BIRD service will run (default: `bird`).

### `defaults.yml` Variables

- `bird_log_file`: The path to the BIRD log file (default: `/var/log/bird.log`).
- `bird_log_level`: The logging level for BIRD (default: `all`).
- `bird_router_id`: The router ID for BIRD, typically set to a specific IP address on the system.
- `bird_systemd_aware`: Boolean to indicate if the role should manage BIRD as a systemd service (default: `true`).
- `bird_routing_tables`: A list of routing tables to be managed by BIRD, with their names and types (IPv4/IPv6).
- `bird_protocols`: A list of routing protocols to be configured. This list can include various protocols like device, kernel, direct, static, pipe, BGP, OSPF, etc., each with its specific configuration.

## Usage

You can include this role in your Ansible playbook and set the variables according to your network setup requirements. Ensure that you properly define the routing protocols and their specific configurations in the `bird_protocols` variable to match your network design.

### Example playbook usage:

```yaml
- hosts: routers
  roles:
    - your_custom_bird_role
  vars:
    bird_router_id: "192.0.2.1"
    bird_protocols:
      - protocol: bgp
        ...

## Protocol Configuration Examples

### Device Protocol
- protocol: device
  description: Get information about network interfaces

### Kernel Protocol
- protocol: kernel
  table: main4
  description: Import all IPv4 routes from the kernel
  learn: true
  ipv4:
    - import all

### Direct Protocol
- protocol: direct
  description: Create device routes for all network interfaces
  ipv4: true
  ipv6: true

### Static Protocol
- protocol: static
  description: Static route
  ipv4:
    - table bird_table_1
  routes:
    - network: 1.2.3.4
      nexthop: blackhole
      mode: recursive # (optional, 'via' or 'recursive')

### Pipe Protocol
- protocol: pipe
  description: Pipe route to bird table
  table: master4
  peer_table: bird_table_1
  filter:
    type: export
    acl:
      - rule: net ~ [10.0.0.0/16+]
        action: accept
    default_action: reject

### BGP Protocol
- protocol: bgp
  name: new_bgp_session
  description: BGP 1
  multihop: true
  neighbor:
    ip: 10.0.1.3
    as: 1234
  local:
    ip: 172.16.0.1
    as: 5678
  ipv4:
    - import all
    - export all
    - table bird_table_1

### OSPF Protocol
- protocol: ospf
  name: ospf_session
  description: OSPF
  ipv4:
    - import all
    - |
      export filter {
        if (net ~ [ 10.0.0.0/8 ]) then {
          ospf_metric1 = 10;
          accept;
        }
        accept;
      }
  areas:
    - id: 0.0.0.0
      interfaces:
        - name: gre_ffkbu_*
          type: broadcast
          options:
            - ttl security tx only
            - wait 10
            - cost 1024
