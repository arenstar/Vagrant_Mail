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
      notify => Service['opensmtpd'],
      source => "file:///vagrant/opensmtpd/smtpd.conf";
    '/etc/maildomains':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => "arenstar.net\n";
  }->
  service {
    'opensmtpd':
      ensure => running,
      enable => true;
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
      notify => Service['dovecot'],
      source => "file:///vagrant/dovecot/dovecot.conf";
    '/usr/bin/sa-learn-pipe.sh':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      source => "file:///vagrant/dovecot/sa-learn-pipe.sh";
  }->
  service {
    'dovecot':  
      ensure => running,
      enable => true,
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
  }->
  service {
    'spampd':  
      ensure => running,
      enable => true,
  }


  file {
    ['/etc/skel/Maildir','/etc/skel/Maildir/cur','/etc/skel/Maildir/new','/etc/skel/Maildir/tmp']:
      ensure => directory;
    ['/etc/skel/Maildir/.Drafts','/etc/skel/Maildir/.Drafts/cur','/etc/skel/Maildir/.Drafts/new','/etc/skel/Maildir/.Drafts/tmp']:
      ensure => directory;
    ['/etc/skel/Maildir/.Sent','/etc/skel/Maildir/.Sent/cur','/etc/skel/Maildir/.Sent/new','/etc/skel/Maildir/.Sent/tmp']:
      ensure => directory;
    ['/etc/skel/Maildir/.Trash','/etc/skel/Maildir/.Trash/cur','/etc/skel/Maildir/.Trash/new','/etc/skel/Maildir/.Trash/tmp']:
      ensure => directory;
    ['/etc/skel/Maildir/.Templates','/etc/skel/Maildir/.Templates/cur','/etc/skel/Maildir/.Templates/new','/etc/skel/Maildir/.Templates/tmp']:
      ensure => directory;
    '/etc/pki':
      ensure => directory;
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

  group { 'mail':
    ensure => 'present',
    gid    => '500',
  }->
  user { 'test':
    ensure           => 'present',
    home             => '/home/test',
    managehome       => true,
    password         => '$6$STFoC3Nx$0YurTwTvQG3f2otaFXGxAIo3DaVlgxJhbwh5CGAdQLV9Bh/LrE2mvvAHIZJevCxlWm2LNQVNprsHp5RZEYUB2/',
    shell            => '/bin/bash',
    groups           => 'mail',
  }

}
