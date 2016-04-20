FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install amavisd-new spamassassin clamav-daemon pyzor razor libnet-dns-perl libmail-spf-perl && rm -rf /var/lib/apt/lists/*

COPY ./conf.d /etc/amavis/conf.d

RUN su - amavis -s /bin/bash && razor-admin -create && razor-admin -register && pyzor discover

WORKDIR /

EXPOSE 10024

CMD ["/usr/sbin/amavisd-new", "debug"]

