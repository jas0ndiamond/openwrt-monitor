FROM debian:buster-20220316
MAINTAINER jason.a.diamond@gmail.com
ENV TZ="America/Vancouver"

USER root

#docker run --name openwrt-monitor -p 20000:20000 -p 28086:8086 -p 25826:25826/udp jas0ndiamond/openwrt-monitor

RUN mkdir /opt/openwrt-monitor

#core os setup
RUN /usr/bin/apt-get -y update && /usr/bin/apt-get -y upgrade && /usr/bin/apt-get -y install apt apt-utils apt-transport-https readline-common libterm-readline-gnu-perl libreadline-dev

RUN /usr/bin/apt-get -y update && /usr/bin/apt-get -y install gpg software-properties-common curl dirmngr coreutils ca-certificates procps

#grapfana
RUN /usr/bin/add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
RUN /usr/bin/curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/grafana.gpg
RUN /usr/bin/apt-get -y update
RUN /usr/bin/apt-get -y install grafana

#os setup for influxdb
RUN /usr/bin/apt-get -y install influxdb influxdb-client

#rsyslog and logrotate
RUN /usr/bin/apt-get -y install rsyslog logrotate

#debug tools
RUN /usr/bin/apt-get -y install nano vim telnet less

#clean up apt
RUN /usr/bin/apt-get clean && rm -rf /var/lib/apt/lists

###############
#ports

#influxdb collectd bind-address port
EXPOSE 25826

#influx http port
EXPOSE 28086

#grafana http port
EXPOSE 20000

#expose rsyslog tcp port
EXPOSE 514


################
#deploy configured influx db

RUN mkdir -p /usr/local/share/collectd/

COPY types.db /usr/local/share/collectd/

COPY influxdb.conf /etc/influxdb/influxdb.conf

COPY start.sh /opt/openwrt-monitor

#db started in entrypoint

#################
#deploy configured grafana

COPY grafana.ini /etc/grafana/grafana.ini

RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/grafana-server

#################
#deploy configured rsyslog

COPY rsyslog.conf /etc/rsyslog.conf

#################
#deploy configured logrotate

COPY logrotate.conf /etc/logrotate.conf

################
#run start.sh as the container entrypoint

ENTRYPOINT /bin/bash /opt/openwrt-monitor/start.sh
