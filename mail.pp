node default {

  package { 
    'opensmtpd':
      ensure => 'latest';
  }->
  file {
    '/etc/smtpd.conf':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => "file:///vagrant/opensmtpd/smtpd.conf";
    '/etc/maildomains':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => "arenstar.net\n";
    '/etc/pki/wildcard_arenstar.net.key':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "file:///vagrant/pki/wildcard_arenstar.net.key";
    '/etc/pki/wildcard_arenstar.net.pem':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "file:///vagrant/pki/wildcard_arenstar.net.pem";
    '/etc/pki/arenstar_CA_cert.pem':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
      source => "file:///vagrant/pki/arenstar_CA_cert.pem";
  }

  package { 
    'dovecot-imapd':
      ensure => 'latest';
    'dovecot-antispam':
      ensure => 'latest';
    'dovecot-lmtpd':
      ensure => 'latest';
  }->
  file {
    '/etc/dovecot/dovecot.conf':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => "file:///vagrant/dovecot/dovecot.conf";
    '/usr/bin/sa-learn-pipe.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => "file:///vagrant/dovecot/sa-learn-pipe.sh";
  }

  package { 
    'spampd':
      ensure => 'latest';
  }->
  file {
    '/etc/default/spamassassin':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => "file:///vagrant/spamassassin/default";
  }

  file {
    ['/etc/skel/Maildir','/etc/skel/Maildir/cur','/etc/skel/Maildir/new','/etc/skel/Maildir/tmp']:
      ensure => present;
    ['/etc/skel/Maildir/.Drafts','/etc/skel/Maildir/.Drafts/cur','/etc/skel/Maildir/.Drafts/new','/etc/skel/Maildir/.Drafts/tmp']:
      ensure => present;
    ['/etc/skel/Maildir/.Sent','/etc/skel/Maildir/.Sent/cur','/etc/skel/Maildir/.Sent/new','/etc/skel/Maildir/.Sent/tmp']:
      ensure => present;
    ['/etc/skel/Maildir/.Trash','/etc/skel/Maildir/.Trash/cur','/etc/skel/Maildir/.Trash/new','/etc/skel/Maildir/.Trash/tmp']:
      ensure => present;
    ['/etc/skel/Maildir/.Templates','/etc/skel/Maildir/.Templates/cur','/etc/skel/Maildir/.Templates/new','/etc/skel/Maildir/.Templates/tmp']:
      ensure => present;
  }

  group { 'mail':
    ensure => 'present',
    gid    => '500',
  }->
  user { 'test':
    ensure           => 'present',
    home             => '/home/test',
    password         => 'password',
    shell            => '/bin/bash',
    groups           => 'mail',
  }

}
