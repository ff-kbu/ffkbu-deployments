nginx-exporter
=========

Provides metrics of nginx process and access metrics to ressources

## Requirements

Running version of nginx providing nginx_status (see: [stub_status_module](http://nginx.org/en/docs/http/ngx_http_stub_status_module.html)

Role Variables
--------------

`nginx_exporter_version` Exporter version to install

`nginx_exporter_basdir` Where the exporter binary is copied to

`nginx_exporter_scape_url` URL for scraping stub status

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: nginx-exporter
           tags: nginx-exporter

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
