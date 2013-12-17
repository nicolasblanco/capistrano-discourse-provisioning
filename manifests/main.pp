import 'config.pp'

class { 'apt':
  always_apt_update    => true,
  disable_keys         => undef,
  proxy_host           => false,
  proxy_port           => undef,
  purge_sources_list   => false,
  purge_sources_list_d => false,
  purge_preferences_d  => false
}

apt::ppa { "ppa:nginx/stable" :}
apt::ppa { "ppa:pitti/postgresql" :}
apt::ppa { "ppa:chris-lea/node.js" :}

# Install required packages
package { 'curl' :
  ensure => present,
}

package { 'git' :
  name => 'git-core',
  ensure => present,
}

package { 'python-software-properties' :
  ensure => present,
}

package { "nginx" :
  ensure => present,
  require => Apt::Ppa["ppa:nginx/stable"]
}

package { 'postgresql' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

package { 'libpq-dev' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

# Install ImageMagick as it often cause problems with bundle install
package { 'libmagickcore-dev' :
  ensure => present,
}

package { 'libmagickwand-dev' :
  ensure => present,
}


group { 'admin' :
  ensure => present,
}

# Setup the user accounts
user { 'deployer' :
  ensure => present,
  groups => 'admin',
  shell => '/bin/bash',
  managehome => true,
  home => '/home/deployer',
  password => $user_password,
  require => Group['admin']
}

file { '/home/deployer/.ssh' :
  owner => 'deployer',
  group => 'deployer',
  mode => 700,
  ensure => 'directory',
}

file { '/home/deployer/.ssh/known_hosts' :
  owner => 'deployer',
  group => 'deployer',
  mode => 644,
  source => 'puppet:///files/known_hosts',
  ensure => present,
  require => User['deployer'],
}


# Setup rbenv
rbenv::install { 'deployer' :
  require => User['deployer'],
}


rbenv::compile { "2.0.0-p353":
  user => 'deployer',
  home => "/home/deployer",
  global => true,
  require => User['deployer'],
}

# Configure postgres
class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '127.0.0.1/32',
  listen_addresses           => 'localhost',
  ipv4acls                   => [ 'local   all             postgres                                peer',
                                      'local   all             all                                     md5',
                                      'host    all             all             127.0.0.1/32            md5',
                                      'host    all             all             10.0.2.2/32             md5'],
}

# Create the database
postgresql::server::db { $db_name :
  user     => $db_user,
  password => $db_password,
  require => Package['postgresql']
}

# Create the application directory
file { "/home/deployer/$app_name" :
  ensure => 'directory',
  owner => 'deployer',
  group => 'deployer',
  mode => 755,
  require => User['deployer'],
}

file { "/home/deployer/$app_name/releases" :
  ensure => 'directory',
  owner => 'deployer',
  group => 'deployer',
  mode => 755,
  require => File["/home/deployer/$app_name"],
}

file { "/home/deployer/$app_name/shared" :
  ensure => 'directory',
  owner => 'deployer',
  group => 'deployer',
  mode => 755,
  require => File["/home/deployer/$app_name"],
}

service { "nginx" :
    ensure  => "running",
    enable  => "true",
    require => Package["nginx"],
}

file { "/etc/nginx/nginx.conf" :
  source => 'puppet:///files/nginx.conf',
  mode => 644,
  owner => 'root',
  require => Package['nginx'],
}

file { "/etc/nginx/sites-available/default" :
  source => 'puppet:///files/nginx-default',
  mode => 644,
  owner => 'root',
  notify => Service['nginx'],
  require => File['/etc/nginx/nginx.conf'],
}

class { 'sudo': }
sudo::conf { 'deployer_sudo':
  priority => 10,
  content  => 'deployer ALL=(ALL) NOPASSWD: ALL',
}

