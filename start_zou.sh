#!/bin/bash

# create /var/run/postgresql
. /usr/share/postgresql-common/init.d-functions
create_socket_directory

echo Running Zou...
supervisord -c /etc/supervisord.conf
