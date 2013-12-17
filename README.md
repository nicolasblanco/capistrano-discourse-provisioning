# Rails provisioning (standalone server)

This is is a fairly simple puppet script to provision an Ubuntu server with the following components:

- UFW & Denyhosts for security (only ports 22/80 are opened)
- rbenv
- Ruby 2.0
- Postgresql
- Nginx
- A single user `deployer`

In general, it follows the manual approach given in [Railscast #335](http://railscasts.com/episodes/335-deploying-to-a-vps)

## Instructions

    apt-get install -y git
    git clone https://github.com/slainer68/my-rails-puppet.git /etc/puppet
    . /etc/puppet/install_puppet.sh

Edit `/etc/puppet/manifests/config.pp` with the correct variables

    sudo puppet apply /etc/puppet/manifests/main.pp

Done!

## Notes

You'll need setup Capistrano to complete this installation (nginx configu files, gems, unicorn_init etc).

    cat ~/.ssh/id_rsa.pub | ssh deployer@178.79.177.190 "cat >> ~/.ssh/authorized_keys"
    cap deploy:setup
    cap deploy
