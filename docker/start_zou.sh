#!/bin/bash

if [[ -z "${SECRET_KEY:-}" ]]; then
  export SECRET_KEY="$(python3 -c 'import secrets; print(secrets.token_hex(32))')"
  echo "Generated a temporary SECRET_KEY for this container."
fi

# create /var/run/postgresql
. /usr/share/postgresql-common/init.d-functions
create_socket_directory

echo Running Zou...
supervisord -c /etc/supervisord.conf
