import 'config.pp'

$home_path = "/home/${user_name}"

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
apt::ppa { "ppa:brightbox/ruby-ng-experimental" :}

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

package { 'nginx' :
  ensure => present
}

file { "/etc/nginx/nginx.conf" :
  content => template("nginx.conf"),
  owner   => root,
  group   => root,
  mode    => 644,
  require => Package["nginx"]
}

file { "/etc/nginx/sites-available" :
  ensure => 'directory',
  owner => root,
  group => root,
  mode => 755,
  require => File["/etc/nginx/nginx.conf"]
}

file { "/etc/nginx/sites-enabled" :
  ensure => 'directory',
  owner => root,
  group => root,
  mode => 755,
  require => File["/etc/nginx/sites-available"]
}

file { "/etc/nginx/sites-available/discourse" :
  content => template("sites-available/discourse"),
  owner   => root,
  group   => root,
  mode    => 644,
  require => File["/etc/nginx/sites-available"]
}

file { "/etc/nginx/sites-enabled/discourse" :
  ensure => 'link',
  target => '/etc/nginx/sites-available/discourse',
  require => File["/etc/nginx/sites-available/discourse"]
}

service { "nginx" :
  ensure  => "running",
  enable  => "true",
  require => Package["nginx"],
  subscribe => File["/etc/nginx/sites-enabled/discourse"]
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

package { 'libpq-dev' :
  ensure => present,
  require => Apt::Ppa["ppa:pitti/postgresql"]
}

package { 'imagemagick' :
  ensure => present
}

package { 'libmagickcore-dev' :
  ensure => present
}

package { 'libmagickwand-dev' :
  ensure => present
}

package { 'postfix' :
  ensure => present
}

file { "/etc/postfix/sasl" :
  ensure => 'directory',
  owner => root,
  group => root,
  mode => 755,
  require => Package["postfix"]
}

file { "/etc/postfix/sasl/passwd" :
  content => template("postfix/sasl/passwd"),
  owner   => root,
  group   => root,
  mode    => 600,
  require => File["/etc/postfix/sasl"]
}

exec { 'postfix::postmap' :
  command => "/usr/sbin/postmap /etc/postfix/sasl/passwd",
  require => File['/etc/postfix/sasl/passwd'],
  subscribe => File["/etc/postfix/sasl/passwd"],
  refreshonly => true,
  notify => Service["postfix"]
}

file { "/etc/postfix/main.cf" :
  content => template("postfix/main.cf"),
  owner   => root,
  group   => root,
  mode    => 644,
  require => Package["postfix"]
}

service { "postfix" :
  ensure  => "running",
  enable  => "true",
  require => Package["postfix"],
  subscribe => File["/etc/postfix/main.cf"]
}

package { 'ruby2.1' :
  ensure => present,
  require => Apt::Ppa["ppa:brightbox/ruby-ng-experimental"]
}

package { 'ruby2.1-dev' :
  ensure => present,
  require => Package['ruby2.1']
}

package { 'ruby2.1-doc' :
  ensure => present,
  require => Package['ruby2.1']
}

exec { 'god::install' :
  command => "/usr/bin/gem2.1 install god --no-doc",
  require => Package['ruby2.1-dev'],
  unless => "/usr/bin/which god"
}

file { "/etc/init.d/god" :
  content => template("god.init.d"),
  owner   => root,
  group   => root,
  mode    => 755,
  require => Exec["god::install"]
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
  ensure => 'directory',
  require => User[$user_name]
}

file { "${home_path}/.ssh/authorized_keys" :
  owner => "$user_name",
  group => "$user_name",
  mode => 600,
  source => '/root/.ssh/authorized_keys',
  ensure => present,
  require => File["${home_path}/.ssh"]
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

file { "$home_path/$app_name/shared/log" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/tmp" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/sockets" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/pids" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/config" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/plugins" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/public" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared"]
}

file { "$home_path/$app_name/shared/public/system" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared/public"]
}

file { "$home_path/$app_name/shared/public/uploads" :
  ensure => 'directory',
  owner => $user_name,
  group => $user_name,
  mode => 755,
  require => File["$home_path/$app_name/shared/public"]
}

file { "$home_path/$app_name/shared/config/thin.yml" :
  content => template("thin.yml"),
  owner   => $user_name,
  group   => $user_name,
  mode    => 644,
  require => File["$home_path/$app_name/shared/config"]
}

file { "$home_path/$app_name/shared/config/sidekiq.yml" :
  content => template("sidekiq.yml"),
  owner   => $user_name,
  group   => $user_name,
  mode    => 644,
  require => File["$home_path/$app_name/shared/config"]
}

file { "$home_path/$app_name/shared/config/discourse.conf" :
  content => template("discourse.conf"),
  owner   => $user_name,
  group   => $user_name,
  mode    => 644,
  require => File["$home_path/$app_name/shared/config"]
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

class { 'sudo' : }

sudo::conf { $user_name :
  priority => 10,
  content  => "$user_name ALL=(ALL) NOPASSWD: ALL"
}
