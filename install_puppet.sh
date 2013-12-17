wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb
sudo apt-get update
sudo apt-get install -y puppet-common

cp /etc/puppet/manifests/sample_config.pp /etc/puppet/manifests/config.pp
echo "Please update config.pp with the required variables"
