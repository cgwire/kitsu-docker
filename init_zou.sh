#!/bin/bash

service postgresql start
service redis-server start

. /opt/zou/env/bin/activate

zou init_db
zou init_data
zou create_admin admin@example.com

service postgresql stop
service redis-server stop
