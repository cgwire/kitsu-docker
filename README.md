# Docker Zou

Docker container for [Zou](https://cg-wire.com) and [Kitsu](https://kitsu.cg-wire.com/).

See [Gazu](https://gazu.cg-wire.com/) for details regarding the Python API towards this interface.

### Usage

```bash
$ docker build -t cgwire .
$ docker run -ti --rm -p 80:80 cgwire
```

In order to enable data persistence, use these bind mounts for database and thumbnails:

```bash
$ docker build -t cgwire .
$ docker run -ti --rm -p 80:80 -v /path/to/local/db:/var/lib/postgresql -v /path/to/local/thumbnails:/opt/zou/zou/thumbnails cgwire
```

Credentials:

* login: admin@example.com
* password: default
