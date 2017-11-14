FROM ubuntu:16.04

USER root

# Add Tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --verify /tini.asc
RUN chmod +x /tini

RUN apt-get update && apt-get install --no-install-recommends -y \
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
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/zou
RUN git clone https://github.com/cgwire/zou.git /opt/zou/zou && \
    git clone -b build https://github.com/cgwire/kitsu.git /opt/zou/kitsu && \
    cd /opt/zou/zou && \
    python3 setup.py install


WORKDIR /opt/zou

# Create database
RUN service postgresql start && \
    su - postgres -c 'createuser root && createdb -T template0 -E UTF8 --owner root zoudb' && \
    service postgresql stop


COPY ./gunicorn /etc/zou/gunicorn.conf
RUN mkdir /opt/zou/logs

WORKDIR /opt/zou
COPY ./gunicorn-events /etc/zou/gunicorn-events.conf

COPY ./nginx /etc/nginx/sites-available/zou
RUN ln -s /etc/nginx/sites-available/zou /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

ENV DB_USERNAME=root DB_HOST=
COPY ./init_zou.sh /opt/zou/
COPY ./start_zou.sh /opt/zou/
RUN chmod +x /opt/zou/init_zou.sh /opt/zou/start_zou.sh

RUN echo Initialising Zou... && \
    /opt/zou/init_zou.sh

EXPOSE 80

ENTRYPOINT ["/tini", "--"]
CMD ["/opt/zou/start_zou.sh"]
