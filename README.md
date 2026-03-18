# Kitsu Docker

[![Docker](https://github.com/cgwire/kitsu-docker/actions/workflows/docker.yml/badge.svg)](https://github.com/cgwire/kitsu-docker/actions/workflows/docker.yml)

Docker container for [Kitsu](https://kitsu.cg-wire.com/).

If you like the project, please add a star to the [Kitsu repository](https://github.com/cgwire/kitsu).

It is not recommended to use this image in production. It is intended for Kitsu
testing.

For this purpose, to simplify email testing, we include an email catch-all
application to intercept all emails sent by Kitsu. These can be viewed in an
included webmail.

### Usage

```bash
docker build --build-arg KITSU_VERSION=1.0.17 --build-arg ZOU_VERSION=1.0.18 -t cgwire/cgwire .
docker run --init -ti --rm -p 80:80 -p 1080:1080 --name cgwire cgwire/cgwire
```

In order to enable data persistence, use a named volume for the database and thumbnails:

```bash
docker run --init -ti --rm -p 80:80 -p 1080:1080 --name cgwire \
  -v zou-storage:/var/lib/postgresql \
  -v zou-storage:/opt/zou/previews \
  cgwire/cgwire
```

To run the image as a daemon, add the `-d` flag:

```bash
docker run --init -d --rm -p 80:80 -p 1080:1080 --name cgwire cgwire/cgwire
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
docker exec -ti cgwire sh -c "/opt/zou/env/bin/zou upgrade-db"
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
* Run `docker compose up -d`.

Also [an implementation by Mathieu Bouzard](https://gitlab.com/mathbou/docker-cgwire)
is available.

### Versioning

Versions are defined in a single file: [`versions.env`](versions.env).

```
KITSU_VERSION=1.0.17
ZOU_VERSION=1.0.18
INDEX_VERSION=01
```

Docker image tags follow the pattern: `cgwire/cgwire:<KITSU>-<ZOU>-<INDEX>` (e.g. `cgwire/cgwire:1.0.17-1.0.18-01`).

### Development with just

[just](https://github.com/casey/just) is used as a command runner. Install it with `brew install just` or `cargo install just`.

| Command | Description |
|---|---|
| `just versions` | Show current versions |
| `just update-versions` | Fetch latest versions from GitHub and update `versions.env` |
| `just build` | Build the Docker image locally (single platform) |
| `just build-push` | Build and push multi-platform image to Docker Hub |
| `just start arm64` | Start a container for a given platform (`arm64` or `amd64`) |
| `just start-all` | Start both platforms (arm64 on port 8590, amd64 on port 8591) |
| `just stop arm64` | Stop a container for a given platform |
| `just stop-all` | Stop both platforms |
| `just test arm64` | Run tests against a running container |
| `just test-all` | Test both platforms |
| `just check arm64` | Start, test, and stop a container for a given platform |
| `just check-all` | Start, test, and stop both platforms |
| `just push-tags` | Add alias tags (`latest` + `KITSU_VERSION`) to the pushed image |
| `just release` | Commit `versions.env`, tag, and push to trigger CI |
| `just hub` | Open Docker Hub tags page |
| `just all` | Full local workflow: update, build, check, release |

#### Typical workflow

To bump versions and let CI build/test/push the image:

```bash
just update-versions  # fetch latest versions from GitHub
just release          # commit, tag, push -> CI does the rest
```

To build and test locally before pushing:

```bash
just update-versions
just build
just check-all
just release
```

### CI/CD

A [GitHub Actions workflow](.github/workflows/docker.yml) runs on every push to `master`:

1. Loads and validates versions from `versions.env`
2. Builds the multi-platform image (amd64 + arm64) and pushes it to Docker Hub
3. Tests both architectures with `cgwire/kitsu-checker`
4. Creates alias tags (`latest` and `KITSU_VERSION`)

Required GitHub secrets: `DOCKER_USERNAME` and `DOCKER_PASSWORD`.

The workflow can also be triggered manually via `workflow_dispatch`.

### About authors

This Dockerfile is written by CGWire, a company based in France. We help
animation and VFX studios to collaborate better through efficient tooling.

More than 100 studios around the world use Kitsu for their projects.

Visit [cg-wire.com](https://cg-wire.com) for more information.

[![CGWire Logo](https://zou.cg-wire.com/cgwire.png)](https://cgwire.com)
