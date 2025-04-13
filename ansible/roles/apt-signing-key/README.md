# Ansible Role: apt-signing-key

## Summary

This Ansible role is designed to manage GPG keys used for package repositories. It provides tasks for checking if a matching GPG key already exists, downloading and adding a GPG key, and verifying the key ID/fingerprint. This role is typically used to set up GPG keys for package repositories.

## Role Variables

- `key_name`: The name of the GPG key.
- `url`: The URL to the GPG key.
- `dearmor`: Whether to dearmor the GPG key (default is `false`).
- `key_id`: The key ID or fingerprint to verify (optional).

## Files

### `tasks/main.yml`

This file contains the following tasks:

- Check if a matching GPG key already exists.
- Add the GPG key, including the option to dearmor it.
- Verify the key ID or fingerprint (if specified).
- Copy the GPG key to the specified location.
- Remove temporary files used during the process.
- Set the `apt_gpg_key_path` variable with the full path to the GPG key file.

---

**Note**: This Ansible role assumes that you have configured the necessary variables (`key_name`, `url`, `dearmor`, `key_id`) in your playbook or inventory files. The role is typically used in conjunction with other roles that require GPG key management.

For detailed usage instructions, please refer to the role's documentation.

Feel free to adapt this role to suit your specific environment and requirements.

Enjoy managing GPG keys with the `apt-signing-key` role!
