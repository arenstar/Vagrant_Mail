#!/bin/bash

wget --quiet http://apt.puppetlabs.com/puppetlabs-release-trusty.deb -O /tmp/puppetlabs-release-trusty.deb
dpkg -i /tmp/puppetlabs-release-trusty.deb
apt-get update
apt-get install -y puppet-common puppet ldapscripts git
sed -i '/templatedir/d' /etc/puppet/puppet.conf

puppet module install garethr-docker
puppet module install jproyo-dovecot
puppet module install wyrie-spamassassin
