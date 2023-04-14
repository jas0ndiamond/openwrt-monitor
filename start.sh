#!/bin/bash

echo "Starting openwrt-monitor..."

#mostly sure this sleep is necessary
sleep 10

echo "Starting influxdb..."
/usr/sbin/service influxdb start &> /dev/null

#buy time for the database to start up - necessary
sleep 5

#TODO: check if the database exists and only create OPENWRT_MON if it doesn't
/usr/bin/influx -execute 'CREATE DATABASE "OPENWRT_MON"'
/usr/bin/influx -execute 'DROP RETENTION POLICY "autogen" ON "OPENWRT_MON"'
/usr/bin/influx -execute 'CREATE RETENTION POLICY "one_month" ON "OPENWRT_MON" DURATION 730h0m REPLICATION 1 DEFAULT'

#grafana seems to configure itself to start on package install
#echo "================="
echo "Starting grafana-server..."

#seeing errors here but the grafana ui is up
#need to explicitly start the grafana service with '/usr/sbin/service grafana-server start'
#TODO: figure this out
#/etc/init.d/grafana-server enable

/usr/sbin/service grafana-server start &> /dev/null


#logrotate is a cronjob (not a service) 
#configured as /etc/cron.daily/logrotate by default

echo "Starting rsyslog..."

/usr/sbin/service rsyslog start &> /dev/null

echo "================="
echo "openwrt-monitor running..."

sleep infinity
