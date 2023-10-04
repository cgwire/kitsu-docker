#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

service postgresql start
service redis-server start

. /opt/zou/env/bin/activate

zou upgrade-db
zou init-data
zou create-admin admin@example.com --password mysecretpassword

service postgresql stop
service redis-server stop
