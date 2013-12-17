# Rails provisioning (standalone server)

Tested on latest Ubuntu LTS (currently 12.04).

This is is a fairly simple puppet script to provision an Ubuntu server with the following components:

- UFW & Denyhosts for security (only ports 22/80 are opened)
- rbenv
- Ruby 2.0
- Postgresql
- Nginx
- A single user `web`

## Instructions

    bundle install
    (edit config/deploy/production.rb with the good SSH authentication)
    bin/cap production provisioning

Done!
