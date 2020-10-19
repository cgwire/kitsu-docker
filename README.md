# Kitsu Docker

Docker container for [Kitsu](https://kitsu.cg-wire.com/).

It is not recommended to use this image in production. It is aimed at testing
purposes.

[![Build badge](https://travis-ci.org/cgwire/cgwire.svg?branch=master)](https://travis-ci.org/cgwire/cgwire)

### Usage

```bash
$ docker build -t cgwire/cgwire . # or sudo docker pull cgwire/cgwire
$ docker run -ti --rm -p 80:80 --name cgwire cgwire/cgwire
```

In order to enable data persistence, use a named volume for the database and thumbnails:

```bash
$ docker run -ti --rm -p 80:80 --name cgwire -v zou-storage:/var/lib/postgresql -v zou-storage:/opt/zou/previews cgwire/cgwire
```

To run the image as a daemon, add the `-d` flag:

```bash
$ docker run -d --rm -p 80:80 --name cgwire cgwire/cgwire
```

Credentials:

* login: admin@example.com
* password: mysecretpassword

To update the database:

```bash
$ docker exec -ti cgwire sh -c "zou upgrade_db"
```

Latest stable version: 0.11.0

### Docker Compose

Thanks to our community, for Docker Compose, two different implementations are available:

* Mathieu Bouzard's [repo](https://gitlab.com/mathbou/docker-cgwire)
* Manuel Rais's [contribution](https://github.com/cgwire/cgwire/tree/master/compose)

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
