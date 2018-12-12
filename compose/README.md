# Docker Zou

Docker container for [Zou](https://zou.cg-wire.com) and [Kitsu](https://kitsu.cg-wire.com/).

See [Gazu](https://gazu.cg-wire.com/) for details regarding the Python API towards this interface.

[![Build badge](https://travis-ci.org/cgwire/cgwire.svg?branch=master)](https://travis-ci.org/cgwire/cgwire)

### Usage

#### Initialization
```bash
$ docker-compose up -d
$ docker-compose exec postgres su - postgres -c "createuser root"
$ docker-compose exec postgres su - postgres -c "createdb -T template0 -E UTF8 --owner root root"
$ docker-compose exec postgres su - postgres -c "createdb -T template0 -E UTF8 --owner root zoudb"
$ docker-compose exec cgwire /opt/zou/init_zou.sh
```

Credentials:

* login: admin@example.com
* password: default


#### Update
```bash
$ docker-compose exec cgwire bash -c "LC_ALL=C.UTF-8 LANG=C.UTF-8 /opt/zou/env/bin/zou upgrade_db"
```


### About authors

This Dockerfile is written by CG Wire, a company based in France. We help small
to midsize CG studios to manage their production and build pipeline
efficiently.

We apply software craftmanship principles as much as possible. We love
coding and consider that strong quality and good developer experience matter a
 lot.
Through our diverse experiences, we allow studios to get better at doing
software and focus more on the artistic work.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)
