# Docker Zou

Docker container for [Zou](https://cg-wire.com) and [Kitsu](https://kitsu.cg-wire.com/).

See [Gazu](https://gazu.cg-wire.com/) for details regarding the Python API towards this interface.

### Usage

```bash
$ docker build -t zou .
$ docker run -ti --rm -p 80:80 zou
```
If you want the postgresql folder persistent:

```bash
$ docker build -t zou .
$ docker run -ti --rm -p 80:80 -v /path/to/local/folder:/var/lib/postgresql zou
```

Credentials:

* login: admin@example.com
* password: default
