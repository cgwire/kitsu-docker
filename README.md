# Docker Zou

Docker container for [Zou](https://cg-wire.com) and [Kitsu](https://kitsu.cg-wire.com/).

See [Gazu](https://gazu.cg-wire.com/) for details regarding the Python API towards this interface.

### Usage

```bash
$ docker build -t cgwire .
$ docker run -ti --rm -p 80:80 --name cgwire cgwire
```

In order to enable data persistence, use a named volume for database and thumbnails:

```bash
$ docker build -t cgwire .
$ docker run -ti --rm -p 80:80 --name cgwire -v zou-storage:/var/lib/postgresql -v zou-storage:/opt/zou/zou/thumbnails cgwire
```

Credentials:

* login: admin@example.com
* password: default
