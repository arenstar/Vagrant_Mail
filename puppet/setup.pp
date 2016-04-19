node default {

  #package {
  #  'spampd':
  #    ensure => 'latest';
  #}->
  #file {
  #  '/etc/default/spamassassin':
  #    ensure => present,
  #    owner  => 'root',
  #    group  => 'root',
  #    source => "file:///vagrant/puppet/files/spamassassin/default";
  #}->
  #service {
  #  'spampd':
  #    ensure => running,
  #    enable => true,
  #}


  include firewall_setup
  include docker

  class { 'fail2ban': }

  docker::run { 'znc':
    image              => 'jimeh/znc',
    memory_limit       => '16m',
    ports              => ['6667:6667'],
    volumes            => ['/vagrant/puppet/files/znc/znc.conf:/znc-data/configs/znc.conf:rw'],
    restart_service    => true,
  }

  docker::image { 'arenstar/opensmtpd':
    docker_dir => '/vagrant/opensmtpd'
  }->
  docker::run { 'opensmtpd':
    image              => 'arenstar/opensmtpd',
    memory_limit       => '64m',
    ports              => ['25:25','587:587'],
    hostname           => 'mail.arenstar.net',
    hostentries        => ['ldap.arenstar.net:172.17.0.1'],
    volumes            => [
       '/etc/mailname:/etc/mailname:ro',
       '/vagrant/puppet/files/opensmtpd/smtpd.conf:/etc/smtpd.conf:ro',
       '/vagrant/puppet/files/opensmtpd/smtpd-ldap.conf:/etc/smtpd-ldap.conf:ro',
       '/etc/pki/wildcard_arenstar.net.pem:/etc/wildcard_arenstar.net.pem:ro',
       '/etc/pki/wildcard_arenstar.net.key:/etc/wildcard_arenstar.net.key:ro',
    ],
    restart_service    => true,
  }

  docker::run { 'registrator':
    image              => 'gliderlabs/registrator',
    memory_limit       => '16m',
    net                => 'host',
    command            => 'consul://localhost:8500',
    volumes            => [
       '/var/run/docker.sock:/tmp/docker.sock:ro',
    ],
  }

  docker::run { 'consul':
    image              => 'progrium/consul',
    memory_limit       => '16m',
    ports              => ['8400:8400','8500:8500','8600:53/udp'],
    hostname           => 'consul.arenstar.net',
    command            => '-server -bootstrap -ui-dir /ui',
    restart_service    => true,
  }

  docker::run { 'amavis':
    image              => 'flyhard/amavis',
    memory_limit       => '16m',
    ports              => ['10024:10024'],
    hostentries        => ['consul.arenstar.net:172.17.0.1'],
    restart_service    => true,
  }

  docker::image { 'arenstar/dovecot':
    docker_dir => '/vagrant/dovecot'
  }->
  docker::run { 'dovecot':
    image              => 'arenstar/dovecot',
    memory_limit       => '32m',
    ports              => ['24:24','993:993'],
    hostentries        => ['ldap.arenstar.net:172.17.0.1'],
    restart_service    => true,
    volumes            => [
       '/vagrant/puppet/files/dovecot/dovecot.conf:/etc/dovecot/dovecot.conf:ro',
       '/vagrant/puppet/files/dovecot/dovecot-ldap.conf.ext:/etc/dovecot/dovecot-ldap.conf.ext:ro',
       '/vagrant/puppet/files/dovecot/sa-learn-pipe.sh:/usr/bin/sa-learn-pipe.sh:ro',
       '/etc/pki/wildcard_arenstar.net.pem:/etc/pki/ssl_cert.pem:ro',
       '/etc/pki/wildcard_arenstar.net.key:/etc/pki/ssl_key.pem:ro',
    ],
  }

  docker::run { 'openldap':
    image              => 'osixia/openldap',
    memory_limit       => '32m',
    ports              => ['389:389'],
    hostname           => 'ldap.arenstar.net',
    restart_service    => true,
    env                => [
       'LDAP_ORGANISATION=arenstar',
       'LDAP_DOMAIN=arenstar.net',
       'LDAP_ADMIN_PASSWORD=password',
       'LDAP_CONFIG_PASSWORD=password',
       'LDAP_READONLY_USER=true',
       'LDAP_READONLY_USER_PASSWORD=password',
       'LDAP_TLS=False',
       'LDAP_REMOVE_CONFIG_AFTER_SETUP=true',
    ],
  }

  exec { "ldap-add-users":
    command => "/usr/bin/ldapadd -x -D 'cn=admin,dc=arenstar,dc=net' -w password -f /vagrant/puppet/files/openldap/add_users/add_users.ldif",
    unless  => "/usr/bin/ldapsearch -x -D 'cn=admin,dc=arenstar,dc=net' -w password -b \"uid=test,ou=people,dc=arenstar,dc=net\" \"uid=test\"",
  }
  exec { "ldap-default-policy":
    command => "/usr/bin/ldapadd -x -D 'cn=admin,dc=arenstar,dc=net' -w password -f /vagrant/puppet/files/openldap/default-policy.ldif",
    unless  => "/usr/bin/ldapsearch -x -D 'cn=admin,dc=arenstar,dc=net' -w password -b \"cn=default,ou=policies,dc=arenstar,dc=net\" \"cn=default\"",
  }
  exec { "ldap-email":
    command => "/usr/bin/ldapadd -x -D 'cn=admin,dc=arenstar,dc=net' -w password -f /vagrant/puppet/files/openldap/email_setup/email_setup.ldif",
    unless  => "/usr/bin/ldapsearch -x -D 'cn=admin,dc=arenstar,dc=net' -w password -b \"cn=stuff@arenstar.net,ou=aliases,dc=arenstar,dc=net\" \"cn=stuff@arenstar.net\"",
  }

  file {
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
    '/etc/mailname':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => "arenstar.net\n";
  }
}

class firewall_setup {

    class { 'firewall': }

    # basic firewall declarations
    # Ignore docker dynamic rules
    firewallchain { 'DOCKER:nat:IPv4':
        ensure => present,
        purge  => true,
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }->
    firewallchain { 'POSTROUTING:nat:IPv4':
        ensure => present,
        purge  => true,
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }->
    firewallchain { 'DOCKER:filter:IPv4':
        ensure => present,
        purge  => true,
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }->
    firewallchain { 'INPUT:filter:IPv4':
        ensure => present,
        purge  => true,
        policy => 'accept',
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }->
    firewallchain { 'FORWARD:filter:IPv4':
        ensure => present,
        purge  => true,
        policy => 'accept',
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }
    firewallchain { 'OUTPUT:filter:IPv4':
        ensure => present,
        purge  => true,
        policy => 'accept',
        ignore => [
            '-o docker0',
            '-i docker0',
            '172.17.',
        ],
    }

    firewall { '000 accept all icmp':
      proto   => 'icmp',
      action  => 'accept',
    }->
    firewall { '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
    }->
    firewall { '003 accept related established rules':
      proto   => 'all',
      state   => ['RELATED', 'ESTABLISHED'],
      action  => 'accept',
    }->
    firewall { '004 accept all to docker interfaces':
      proto   => 'all',
      iniface => 'docker0',
      action  => 'accept',
    }->
    firewall { '990 Allow INPUT SMTP':
      chain   => 'INPUT',
      dport   => ['25','587'],
      proto   => 'tcp',
      action  => 'accept',
    }->
    firewall { '990 Allow INPUT IMAP':
      chain   => 'INPUT',
      dport   => ['143','993'],
      proto   => 'tcp',
      action  => 'accept',
    }->
    firewall { '990 Allow INPUT IRC':
      chain   => 'INPUT',
      dport   => ['6667'],
      proto   => 'tcp',
      action  => 'accept',
    }->
    firewall { '990 Allow INPUT HTTP':
      chain   => 'INPUT',
      dport   => ['80','443'],
      proto   => 'tcp',
      action  => 'accept',
    }->
    firewall { '990 Allow INPUT SSH EXTERNAL':
      chain   => 'INPUT',
      dport    => '22',
      proto   => 'tcp',
      action  => 'accept',
    }->
    firewall { '995 Allow ESTABLISHED INPUT SSH':
      chain   => 'INPUT',
      dport   => '22',
      proto   => 'tcp',
      state   => 'ESTABLISHED',
      action  => 'accept',
    }->
    firewall { '996 drop all':
      proto   => 'all',
      action  => 'drop',
      before  => undef,
    }
}
