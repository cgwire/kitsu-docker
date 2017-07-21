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
    nginx

RUN git clone https://github.com/cgwire/zou.git /opt/zou && \
    git clone -b build https://github.com/cgwire/kitsu.git /opt/kitsu && \
    cd /opt/zou && \
    python3 setup.py install && \
    pip3 install \
        gunicorn \
        gevent

COPY gunicorn /etc/zou/gunicorn.conf
COPY nginx /etc/nginx/sites-available/zou

RUN useradd --home /opt/zou zou && \
    mkdir /opt/zou/logs && \
    chown zou: /opt/zou/logs && \
    chown -R zou:www-data /opt/kitsu && \
    chown -R zou:www-data /opt/zou && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/zou /etc/nginx/sites-enabled

USER postgres

RUN service postgresql start && \
    psql --command "create database zoudb;" -U postgres && \
    psql --command "ALTER USER postgres WITH PASSWORD 'mysecretpassword';"

USER root
WORKDIR /opt/zou

# About Gunicorn and port 5000
# Gunicorn is being reverse-proxied through Nginx,
# which is ultimately the process serving port 80
ENTRYPOINT \
    service nginx start && \
    service postgresql start && \
    zou init_db && \
    zou init_data && \
    zou create_admin && \
    echo Running Zou.. && \
    gunicorn \
        -c /etc/zou/gunicorn.conf \
        -b 0.0.0.0:5000 \
        wsgi:application 