docker_etherpad
===============

This role deploys Etherpad with Docker based on official [Etherpad docker image](https://hub.docker.com/r/etherpad/etherpad) with associated Postgres DB.
The main repo for this role is on [Le Filament GitLab](https://sources.le-filament.com/lefilament/ansible-roles/docker_etherpad.git)

Requirements
------------

None.

Role Variables
--------------

Variables from default directory :
* etherpad_url: URL on which Etherpad will be listening
* etherpad_admin_pass: Administrator password for Etherpad
* etherpad_db_name: Database name
* etherpad_db_user: Database user
* etherpad_db_pass: Database password
* Backups (for backups to be deployed, host needs to be in maintenance_contract group):
  * swift parameters for 2 object storage instances where backups should be pushed daily
  * etherpad_backup_pass : Passphrase for encryption of backups


Dependencies
------------

This role requires the following Ansible collection :
* community.docker

This Docker role supposes that Traefik is deployed as an inverseproxy in front of the deployed Dockers.
The following role is used by Le Filament for deploying Traefik : docker_server (https://sources.le-filament.com/lefilament/ansible-roles/docker_server)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: docker_etherpad }
      vars:
         - { etherpad_url: "pad.example.org" }
         - { etherpad_admin_pass: "veryUnsecureAdminPassToBeModified" }
         - { etherpad_db_pass: "veryUnsecurePassToBeModified" }

License
-------

AGPL-3

Author Information
------------------

Le Filament (https://le-filament.com)
