#!/bin/bash

[ "$(ls -A /var/lib/postgresql)" ] && echo "Running with existing database in /var/lib/postgresql" || ( echo 'Populate initial db'; cd /; tar xvjf /opt/zou/postgresql.tar.bz2 )

service nginx start
service redis-server start
service postgresql start
echo Running Zou..
gunicorn  -c /etc/zou/gunicorn.conf -b 127.0.0.1:5000 wsgi:application & \
gunicorn -c /etc/zou/gunicorn-events.conf -b 127.0.0.1:5001 zou.event_stream:app
