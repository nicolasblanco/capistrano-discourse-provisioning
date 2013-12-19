# Rails provisioning (standalone server)

Tested on latest Ubuntu LTS (currently 12.04).

Perfect to setup a CI server/Redmine/Discourse in a few minutes...

This is is a Capistrano script combined with a Puppet script to provision an Ubuntu server with the following components:

- ufw & denyhosts for security (only ports 22/80 are opened)
- postgresql
- A single user `web`
- rbenv locally
- ruby 2.0
- nginx with passenger locally compiled in ~/nginx, application served from ~/app/current

## Instructions

* Create config/deploy/production.rb using the sample file with the good server data. Be sure you can access to your server using the credentials in this file without having to type a password, ie. : by putting your public SSH key in ~/.ssh/authorized_keys, otherwise Capistrano will fail.

    $> bundle install

    $> bin/cap production provisioning

Done!
