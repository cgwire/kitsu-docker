FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV PG_VERSION=12
ENV DB_USERNAME=root DB_HOST=
# https://github.com/cgwire/zou/tags
ARG ZOU_VERSION=0.18.8
# https://github.com/cgwire/kitsu/tags
ARG KITSU_VERSION=0.18.12

USER root

# hadolint ignore=DL3008
RUN mkdir -p /opt/zou/zou /var/log/zou /opt/zou/previews && \
    apt-get update && \
    apt-get install --no-install-recommends -q -y \
    bzip2 \
    build-essential \
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
    libpq-dev \
    redis-server \
    software-properties-common \
    supervisor \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create database
USER postgres

# hadolint ignore=DL3001
RUN service postgresql start && \
    createuser root && createdb -T template0 -E UTF8 --owner root root && \
    createdb -T template0 -E UTF8 --owner root zoudb && \
    service postgresql stop

# hadolint ignore=DL3002
USER root

# Wait for the startup or shutdown to complete
COPY --chown=postgres:postgres --chmod=0644 ./docker/pg_ctl.conf /etc/postgresql/${PG_VERSION}/main/pg_ctl.conf
COPY --chown=postgres:postgres --chmod=0644 ./docker/postgresql-log.conf /etc/postgresql/${PG_VERSION}/main/conf.d/postgresql-log.conf
# hadolint ignore=DL3013
RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf && \
    git config --global --add advice.detachedHead false && \
    wget -q -O /tmp/kitsu.tgz https://github.com/cgwire/kitsu/releases/download/v${KITSU_VERSION}/kitsu-${KITSU_VERSION}.tgz && \
    mkdir -p /opt/zou/kitsu && tar xvzf /tmp/kitsu.tgz -C /opt/zou/kitsu && rm /tmp/kitsu.tgz && \
    python3 -m venv /opt/zou/env && \
    /opt/zou/env/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/zou/env/bin/pip install --no-cache-dir zou==${ZOU_VERSION} && \
    pip install --no-cache-dir sendria && \
    rm /etc/nginx/sites-enabled/default

WORKDIR /opt/zou

COPY ./docker/gunicorn.py /etc/zou/gunicorn.py
COPY ./docker/gunicorn-events.py /etc/zou/gunicorn-events.py
COPY ./docker/nginx.conf /etc/nginx/sites-enabled/zou
COPY docker/supervisord.conf /etc/supervisord.conf
COPY --chmod=0755 ./docker/init_zou.sh /opt/zou/
COPY --chmod=0755 ./docker/start_zou.sh /opt/zou/

RUN echo Initialising Zou... && \
    /opt/zou/init_zou.sh

EXPOSE 80
EXPOSE 1080
VOLUME ["/var/lib/postgresql", "/opt/zou/previews"]
CMD ["/opt/zou/start_zou.sh"]
