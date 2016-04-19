FROM debian:jessie-backports

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install opensmtpd opensmtpd-extras ca-certificates libpam-ldap && rm -rf /var/lib/apt/lists/*

#FROM alpine:3.3
#RUN apk add --no-cache opensmtpd

WORKDIR /

# The spool should be a volume
VOLUME [ "/var/spool/smtpd" ]

EXPOSE 25

CMD ["smtpd","-d"]
