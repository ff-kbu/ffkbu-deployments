bind9-exporter
=========

Provides metrics of bind9 process and access metrics to ressources

## Requirements

Running version of bind9 providing bind9_status (see: [stub_status_module](http://bind9.org/en/docs/http/ngx_http_stub_status_module.html)

Role Variables
--------------

`bind9_exporter_version` Exporter version to install

`bind9_exporter_basdir` Where the exporter binary is copied to

`bind9_exporter_scape_url` URL for scraping stub status

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: bind9-exporter
           tags: bind9-exporter

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
