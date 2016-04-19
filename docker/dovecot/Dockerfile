FROM debian:jessie-backports

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sieve dovecot-managesieved dovecot-antispam dovecot-ldap ca-certificates libpam-ldap && rm -rf /var/lib/apt/lists/*

WORKDIR /

VOLUME [ "/var/mail" ]

EXPOSE 143
EXPOSE 993
EXPOSE 10026

CMD ["dovecot","-F"]
