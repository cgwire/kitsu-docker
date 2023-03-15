# Kitsu Docker

Docker container for [Kitsu](https://kitsu.cg-wire.com/).

It is not recommended to use this image in production. It is intended for Kitsu
testing.

For this purpose, to simplify email testing, we include an email catch-all
application to intercept all emails sent by Kitsu. These can be viewed in an
included webmail.

[![Build badge](https://app.travis-ci.com/cgwire/cgwire.svg?branch=master)](https://app.travis-ci.com/cgwire/cgwire)

### Usage

```bash
$ docker build -t cgwire/cgwire . # or sudo docker pull cgwire/cgwire
$ docker run --init -ti --rm -p 80:80 -p 1080:1080 --name cgwire cgwire/cgwire
```

In order to enable data persistence, use a named volume for the database and thumbnails:

```bash
$ docker run --init -ti --rm -p 80:80 -p 1080:1080 --name cgwire -v zou-storage:/var/lib/postgresql -v zou-storage:/opt/zou/previews cgwire/cgwire
```

To run the image as a daemon, add the `-d` flag:

```bash
$ docker run --init -d --rm -p 80:80 -p 1080:1080 --name cgwire cgwire/cgwire
```

Kitsu credentials:

* login: admin@example.com
* password: mysecretpassword

URL:

Kitsu: [http://127.0.0.1:80/](http://127.0.0.1:80/)

Internal webmail: [http://127.0.0.1:1080/](http://127.0.0.1:1080/)

To update the database:

```bash
$ docker exec -ti cgwire sh -c "/opt/zou/env/bin/zou upgrade-db"
```

### Docker Compose

Thanks to our community, for Docker Compose, [an implementation by Mathieu Bouzard](https://gitlab.com/mathbou/docker-cgwire)
is available

### About authors

This Dockerfile is written by CG Wire, a company based in France. We help small
to midsize CG studios to manage their production and build a pipeline
efficiently.

We apply software craftsmanship principles as much as possible. We love
coding and consider that strong quality and good developer experience matter a
 lot.
Through our diverse experiences, we allow studios to get better at doing
software and focus more on  artistic work.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)
