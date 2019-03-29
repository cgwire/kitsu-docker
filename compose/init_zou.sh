#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

. /opt/zou/env/bin/activate

zou upgrade_db
zou init_data
zou create_admin admin@example.com --password mysecretpassword
