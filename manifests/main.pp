import 'config.pp'

$home_path = "/home/${user_name}"
$passenger_nginx_install_dir = "${home_path}/nginx"
$passenger_nginx_options = "--auto --auto-download --prefix=${passenger_nginx_install_dir}"
$current_path = ["${home_path}/.rbenv/shims", "${home_path}/.rbenv/bin", '/bin', '/usr/bin']

class { 'apt':
  always_apt_update    => true,
  disable_keys         => undef,
  proxy_host           => false,
  proxy_port           => undef,
  purge_sources_list   => false,
  purge_sources_list_d => false,
  purge_preferences_d  => false
}

apt::ppa { "ppa:pitti/postgresql" :}

# Security : only allow ssh and http and installs deny hosts

include ufw

ufw::allow { "allow-ssh-from-all":
  port => 22
}

ufw::allow { "allow-http-from-all":
  port => 80
}

class { "denyhosts" : }

class { 'redis' : }

# Install required packages
package { 'curl' :
  ensure => present
}

package { 'libcurl4-openssl-dev' :
  ensure => present
}

package { 'git' :
  name => 'git-core',
  ensure => present
}

package { 'python-software-properties' :
  ensure => present
}

package { 'postgresql' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

package { 'libpq-dev' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

package { 'postgresql-contrib' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

# Install ImageMagick as it often cause problems with bundle install
package { 'libmagickcore-dev' :
  ensure => present
}

package { 'libmagickwand-dev' :
  ensure => present
}


group { 'admin' :
  ensure => present
}

# Setup the user accounts
user { $user_name :
  ensure => present,
  groups => 'admin',
  shell => '/bin/bash',
  managehome => true,
  home => $home_path,
  password => $user_password,
  require => Group['admin']
}

file { "${home_path}/.ssh" :
  owner => "$user_name",
  group => "$user_name",
  mode => 700,
  ensure => 'directory'
}

# Setup rbenv
rbenv::install { $user_name :
  require => User[$user_name]
}


rbenv::compile { $ruby_version :
  user => $user_name,
  home => $home_path,
  global => true,
  require => Rbenv::Install[$user_name]
}

rbenv::gem { "passenger" :
  user => $user_name,
  ruby => $ruby_version,
  require => Rbenv::Compile[$ruby_version]
}

exec { "rbenv::rehash" :
  command     => "rbenv rehash",
  user        => $user_name,
  group       => $user_name,
  cwd         => $home_path,
  environment => ["HOME=${home_path}"],
  path        => $current_path,
  require     => Rbenv::Gem["passenger"]
}

exec { 'nginx-install' :
  command => "${home_path}/.rbenv/shims/passenger-install-nginx-module ${passenger_nginx_options}",
  environment => ["HOME=${home_path}"],
  user    => $user_name,
  group   => $user_name,
  cwd     => $home_path,
  unless  => "/usr/bin/test -d ${passenger_nginx_install_dir}",
  require => Exec["rbenv::rehash"]
}


# Configure postgres
class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '127.0.0.1/32',
  listen_addresses           => 'localhost',
  ipv4acls                   => [ 'local   all             postgres                                peer',
                                      'local   all             all                                     md5',
                                      'host    all             all             127.0.0.1/32            md5',
                                      'host    all             all             10.0.2.2/32             md5']
}

# Create the database
postgresql::server::db { $db_name :
  user     => $db_user,
  password => $db_password,
  require => Package['postgresql']
}

# Create the application directory
file { "$home_path/$app_name" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => User[$user_name]
}

file { "$home_path/$app_name/releases" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name"]
}

file { "$home_path/$app_name/shared" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name"]
}

file { "$home_path/bin" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755
}

file { "$home_path/bin/ruby" :
  content => template("ruby"),
  owner => $user_name,
  group => $user_name,
  require => File["$home_path/bin"],
  mode => 755
}

file { "/etc/init.d/nginx" :
  source  => "puppet:///files/nginx.init.d",
  owner   => root,
  group   => root,
  mode    => 755,
  require => Exec["nginx-install"]
}

file { "/etc/default/nginx" :
  content => template("default/nginx"),
  owner   => root,
  group   => root,
  mode    => 755,
  require => Exec["nginx-install"]
}

file { "$home_path/nginx/conf/nginx.conf" :
  content => template("nginx.conf"),
  owner   => $user_name,
  group   => $user_name,
  require => Exec["nginx-install"]
}

file { "$home_path/nginx/conf/sites-available" :
  ensure  => 'directory',
  owner   => $user_name,
  group   => $user_name,
  mode    => 755,
  require => Exec["nginx-install"]
}

file { "$home_path/nginx/conf/sites-enabled" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => Exec["nginx-install"]
}

file { "$home_path/nginx/conf/sites-available/default" :
  content => template("sites-available/default"),
  owner => $user_name,
  group => $user_name,
  require => File["$home_path/nginx/conf/sites-available"]
}

file { "$home_path/nginx/conf/sites-enabled/default" :
  ensure => "link",
  target => "$home_path/nginx/conf/sites-available/default",
  owner => $user_name,
  group => $user_name,
  require => File["$home_path/nginx/conf/sites-available/default"]
}


service { "nginx" :
  ensure  => "running",
  enable  => "true",
  require => File["$home_path/nginx/conf/sites-enabled/default"]
}

class { 'sudo' : }

sudo::conf { $user_name :
  priority => 10,
  content  => "$user_name ALL=(ALL) NOPASSWD: ALL"
}
