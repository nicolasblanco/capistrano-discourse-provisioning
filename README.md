# Discourse provisioning

## Instructions

* Be sure you can access to your server using the credentials in this file without having to type a password, ie. : by putting your public SSH key in ~/.ssh/authorized_keys, otherwise Capistrano will fail.

        $> bundle install

        $> HOST=XXX.XXX.XXX.XXX bin/cap production provisioning

Done!
