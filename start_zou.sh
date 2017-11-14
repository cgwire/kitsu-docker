#!/bin/bash

[ "$(ls -A /var/lib/postgresql)" ] && echo "Running with existing database in /var/lib/postgresql" || ( echo 'Populate initial db'; cd /; tar xvjf /opt/zou/postgresql.tar.bz2 )

# create /var/run/postgresql
. /usr/share/postgresql-common/init.d-functions
create_socket_directory

echo Running Zou...
supervisord -c /etc/supervisord.conf
