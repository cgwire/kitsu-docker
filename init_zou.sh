#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

service postgresql start
service redis-server start

. /opt/zou/env/bin/activate

zou init_db
zou init_data
zou create_admin admin@example.com

service postgresql stop
service redis-server stop
