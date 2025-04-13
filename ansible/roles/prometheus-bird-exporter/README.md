prometheus-bird-exporter
=========

Install and configure prometheus-bird-exporter.

Role Variables
--------------


| Variable Name | Default Value | Description |
--------------- |---------------|--------------
`prometheus_bird_exporter_enable_ospf` | `false` | whether to enable ospf support
`prometheus_bird_exporter_use_version_2` | `{{ bird_use_version_2 }}` if defined, else `false` | whether to use bird version 2 (incompatible with version 1.6)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: prometheus-bird-exporter

License
-------

BSD

Author Information
------------------

Find me on [GitHub](https://github.com/ThreeFx).
