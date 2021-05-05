FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update && apt-get install --no-install-recommends -y software-properties-common
RUN apt-get update && apt-get install --no-install-recommends -q -y \
    bzip2 \
    ffmpeg \
    git \
    gcc \
    nginx \
    postgresql \
    postgresql-client \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    libjpeg-dev \
    redis-server \
    supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

RUN mkdir -p /opt/zou /var/log/zou /opt/zou/previews

RUN git config --global --add advice.detachedHead false
RUN git clone -b 0.12.68-build --single-branch --depth 1 https://github.com/cgwire/kitsu.git /opt/zou/kitsu

# setup.py will read requirements.txt in the current directory
WORKDIR /opt/zou/zou
RUN python3 -m venv /opt/zou/env && \
    /opt/zou/env/bin/pip install --upgrade pip setuptools wheel && \
    /opt/zou/env/bin/pip install zou==0.12.70 && \
    rm -rf /root/.cache/pip/

WORKDIR /opt/zou

# Create database
USER postgres

RUN service postgresql start && \
    createuser root && createdb -T template0 -E UTF8 --owner root root && \
    createdb -T template0 -E UTF8 --owner root zoudb && \
    service postgresql stop

USER root

# Wait for the startup or shutdown to complete
ENV PG_VERSION=12
COPY --chown=postgres:postgres pg_ctl.conf /etc/postgresql/${PG_VERSION}/main/pg_ctl.conf
RUN chmod 0644 /etc/postgresql/${PG_VERSION}/main/pg_ctl.conf
COPY --chown=postgres:postgres postgresql-log.conf /etc/postgresql/${PG_VERSION}/main/conf.d/postgresql-log.conf
RUN chmod 0644 /etc/postgresql/${PG_VERSION}/main/conf.d/postgresql-log.conf


COPY ./gunicorn /etc/zou/gunicorn.conf
COPY ./gunicorn-events /etc/zou/gunicorn-events.conf

COPY ./nginx.conf /etc/nginx/sites-available/zou
RUN ln -s /etc/nginx/sites-available/zou /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

ADD supervisord.conf /etc/supervisord.conf

ENV DB_USERNAME=root DB_HOST=
COPY ./init_zou.sh /opt/zou/
COPY ./start_zou.sh /opt/zou/
RUN chmod +x /opt/zou/init_zou.sh /opt/zou/start_zou.sh

RUN echo Initialising Zou... && \
    /opt/zou/init_zou.sh

EXPOSE 80
VOLUME ["/var/lib/postgresql", "/opt/zou/previews"]
CMD ["/opt/zou/start_zou.sh"]
