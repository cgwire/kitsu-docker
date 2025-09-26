# Kitsu Docker

Docker container for [Kitsu](https://kitsu.cg-wire.com/).

If you like the project, please add a star to the [Kitsu repository](https://github.com/cgwire/kitsu).

It is not recommended to use this image in production. It is intended for Kitsu
testing.

For this purpose, to simplify email testing, we include an email catch-all
application to intercept all emails sent by Kitsu. These can be viewed in an
included webmail.

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

Update the profile settings with a working email address to try all features.

URL:

Kitsu: [http://127.0.0.1:80/](http://127.0.0.1:80/)

Internal webmail: [http://127.0.0.1:1080/](http://127.0.0.1:1080/)

### Update

After updating the image, you have to update the database schema. For that run:

```bash
$ docker exec -ti cgwire sh -c "/opt/zou/env/bin/zou upgrade-db"
```

### Docker Compose

`docker-compose.yml`
---
```yml
services:
  cgwire:
    image: cgwire/cgwire:latest
    container_name: kitsu
    init: true
    tty: true
    stdin_open: true
    ports:
      - 8012:80 # Change the port 8012 to your desired port.
      - 1080:1080
    volumes:
      - zou-storage:/var/lib/postgresql
      - zou-storage:/opt/zou/previews

volumes:
  zou-storage:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: './zou-storage'
```
* Save this in a file and name it `docker-compose.yml`.
* Create the folder `zou-storage` in the same folder as the `docker-compose.yml`.
* Open the terminal in the same folder.
* Run `docker compose up-d`.
* Done...... (Hopefully 🤞🤞)

Please test if the data is persisting after reboot or recreation. (Only tested in windows.)

Also [an implementation by Mathieu Bouzard](https://gitlab.com/mathbou/docker-cgwire)
is available.

### About authors

This Dockerfile is written by CGWire, a company based in France. We help 
animation and VFX studios to collaborate better through efficient tooling.

More than 100 studios around the world use Kitsu for their projects.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)
