# Freifunk Infrastructure Deployment

This repository contains Ansible playbooks and roles for deploying the infrastructure of our FFKBU Community (Hood). It automates the setup and configuration of various essential services such as Grafana, Jitsi, Portainer, Vaultwarden, and more.

## 🔐 Vault Password Configuration

To run encrypted roles or playbooks that require Ansible Vault, create a file containing your vault password.

- Place your `vaultpass` file in a secure, non-tracked location (e.g., `~/.vaultpass`).
- Use the `--vault-password-file` option when executing playbooks:

```bash
ansible-playbook deploy_base.yml --vault-password-file ~/.vaultpass
```

## 🔑 SSH Key for Remote Access

For SSH-based deployments, ensure that your Ansible keyfile is set up correctly:

- Place your private SSH key (e.g., `id_rsa`) in a secure location.
- Specify the key with the `--private-key` option or configure it in your `ansible.cfg` or inventory file.

Example:

```bash
ansible-playbook -i env_prd ansible/deploy_grafana.yml --private-key ~/.ssh/id_rsa
```

---

Please adjust paths and filenames as needed for your local setup.
