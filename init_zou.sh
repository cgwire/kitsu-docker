#!/bin/bash

service postgresql start
service redis-server start

zou init_db
zou init_data
zou create_admin manu@autourdeminuit.com

service postgresql stop
service redis-server stop

tar cvjf postgresql.tar.bz2 /var/lib/postgresql
