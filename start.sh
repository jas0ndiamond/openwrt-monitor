#!/bin/bash

echo "Starting influxdb..."

sleep 10

#seeing errors here but the database is up
#need to explicitly start the influxdb service with '/usr/sbin/service influxdb start'
#TODO: figure this out
/usr/sbin/service influxdb start &> /dev/null

#echo $(/bin/ps -ef |grep influx | grep -v grep)

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
/usr/sbin/service grafana-server start &> /dev/null

#echo $(/bin/ps -ef |grep grafana | grep -v grep)

echo "openwrt-monitor running..."

sleep infinity
