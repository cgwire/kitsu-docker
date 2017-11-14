FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-client \
    libpq-dev \
    python3 \
    python3-pip \
    python3-dev \
    libffi-dev \
    libjpeg-dev \
    git \
    nginx \
    redis-server \
    ffmpeg && \
    echo "vm.overcommit_memory = 1" >> /etc/systcl.conf

RUN git clone https://github.com/cgwire/zou.git /opt/zou && \
    git clone -b build https://github.com/cgwire/kitsu.git /opt/kitsu && \
    cd /opt/zou && \
    python3 setup.py install && \
    pip3 install gunicorn && \
    pip3 install gevent

USER postgres

RUN \
    service postgresql start && \
    psql -c 'create database zoudb;' -U postgres && \
    psql --command "ALTER USER postgres WITH PASSWORD 'mysecretpassword';" && \
    service postgresql stop

USER root

COPY ./gunicorn /etc/zou/gunicorn.conf
RUN mkdir /opt/zou/logs

WORKDIR /opt/zou
COPY ./gunicorn-events /etc/zou/gunicorn-events.conf
COPY ./init_zou.sh .
COPY ./start_zou.sh .
RUN chmod +x init_zou.sh start_zou.sh

COPY ./nginx /etc/nginx/sites-available/zou
RUN ln -s /etc/nginx/sites-available/zou /etc/nginx/sites-enabled/

RUN rm /etc/nginx/sites-enabled/default

RUN \
  echo Initialising Zou.. && \
  ./init_zou.sh

EXPOSE 80

ENTRYPOINT \
  /opt/zou/start_zou.sh
