# Rails provisioning (standalone server)

Tested on latest Ubuntu LTS (currently 12.04).

Perfect to setup a CI server/Redmine/Discourse in a few minutes...

This is is a fairly simple puppet script to provision an Ubuntu server with the following components:

- ufw & denyhosts for security (only ports 22/80 are opened)
- postgresql
- A single user `web`
- rbenv locally
- ruby 2.0
- nginx with passenger locally compiled in ~/nginx, application served from ~/app/current

## Instructions

    (on your local box)

    $> bundle install

    (edit config/deploy/production.rb with the good SSH authentication)

    $> bin/cap production provisioning

Done!
