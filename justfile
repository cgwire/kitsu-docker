# Load versions from the single source of truth
set dotenv-filename := "versions.env"

KITSU_VERSION := env_var('KITSU_VERSION')
ZOU_VERSION := env_var('ZOU_VERSION')
INDEX_VERSION := env_var('INDEX_VERSION')

image := "cgwire/cgwire"
tag := KITSU_VERSION + "-" + ZOU_VERSION + "-" + INDEX_VERSION

# List available commands
default:
    @just --list

# Show current versions
versions:
    @echo "KITSU_VERSION={{ KITSU_VERSION }}"
    @echo "ZOU_VERSION={{ ZOU_VERSION }}"
    @echo "INDEX_VERSION={{ INDEX_VERSION }}"
    @echo "Tag: {{ tag }}"

# Fetch latest versions from GitHub and update versions.env
update-versions:
    #!/usr/bin/env bash
    set -euo pipefail
    KITSU_VERSION=$(curl -s https://api.github.com/repos/cgwire/kitsu/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    ZOU_VERSION=$(curl -s https://api.github.com/repos/cgwire/zou/tags | jq -r '.[0].name' | sed 's/^v//')
    echo "Latest Kitsu: ${KITSU_VERSION}"
    echo "Latest Zou:   ${ZOU_VERSION}"
    sed -i'' -e "s/^KITSU_VERSION=.*/KITSU_VERSION=${KITSU_VERSION}/" versions.env
    sed -i'' -e "s/^ZOU_VERSION=.*/ZOU_VERSION=${ZOU_VERSION}/" versions.env
    echo "Updated versions.env:"
    cat versions.env
    GIT_PAGER="" git diff versions.env

# Build the Docker image locally (single platform)
build:
    docker build \
        --build-arg KITSU_VERSION={{ KITSU_VERSION }} \
        --build-arg ZOU_VERSION={{ ZOU_VERSION }} \
        -t {{ image }}:{{ tag }} \
        .

# Build and push multi-platform image to Docker Hub
build-push:
    docker buildx build \
        --push --no-cache \
        --platform=linux/amd64,linux/arm64 \
        --build-arg KITSU_VERSION={{ KITSU_VERSION }} \
        --build-arg ZOU_VERSION={{ ZOU_VERSION }} \
        -t {{ image }}:{{ tag }} \
        .

# Start a container for a given platform (arm64 or amd64)
start platform="arm64":
    #!/usr/bin/env bash
    set -euo pipefail
    CONTAINER_NAME=cgwire-{{ platform }}
    LOCAL_PORT={{ if platform == "arm64" { "8590" } else { "8591" } }}
    echo "Starting ${CONTAINER_NAME} on port ${LOCAL_PORT}..."
    echo "docker container run --platform=linux/{{ platform }} -d --init -p 127.0.0.1:${LOCAL_PORT}:80 --rm --name \"${CONTAINER_NAME}\" {{ image }}:{{ tag }}"
    docker container run --platform=linux/{{ platform }} -d --init -p ${LOCAL_PORT}:80 --rm --name "${CONTAINER_NAME}" {{ image }}:{{ tag }}
    echo "${CONTAINER_NAME} started on http://127.0.0.1:${LOCAL_PORT}"

# Start both platforms
start-all: (start "arm64") (start "amd64")

# Stop and remove a container for a given platform (arm64 or amd64)
stop platform="arm64":
    -docker kill cgwire-{{ platform }}

# Stop both platforms
stop-all: (stop "arm64") (stop "amd64")

# Run tests against a running container (arm64 or amd64)
test platform="arm64":
    #!/usr/bin/env bash
    set -euo pipefail
    LOCAL_PORT={{ if platform == "arm64" { "8590" } else { "8591" } }}
    echo "====== Test Kitsu: {{ KITSU_VERSION }}, Zou: {{ ZOU_VERSION }}, index: {{ INDEX_VERSION }} on {{ platform }}"
    KITSU_URL="http://127.0.0.1:${LOCAL_PORT}" \
    KITSU_VERSION="{{ KITSU_VERSION }}" \
    ZOU_VERSION="{{ ZOU_VERSION }}" \
    TIMEOUT=30 \
    WAIT=1 \
      uvx --from 'cgwire-checks @ git+https://github.com/cgwire/kitsu-checker.git' cgwire_checks
    echo "====== Tests passed for {{ platform }}"

# Test both platforms
test-all: (test "arm64") (test "amd64")

# Start, test, and stop a container for a given platform (arm64 or amd64)
check platform="arm64": (start platform)
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'just stop {{ platform }}' EXIT
    just test {{ platform }}

# Start, test, and stop both platforms
check-all: start-all
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'just stop-all' EXIT
    just test-all

# Add alias tags (latest + kitsu version) to the pushed image
push-tags:
    docker buildx imagetools create \
        {{ image }}:{{ tag }} \
        --tag {{ image }}:{{ KITSU_VERSION }} \
        --tag {{ image }}:latest

# Commit versions.env, tag, and push to trigger CI
release:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Releasing {{ tag }}"
    git add versions.env
    git commit -m "Bump Kitsu and Zou versions ({{ KITSU_VERSION }} and {{ ZOU_VERSION }})"
    git tag {{ tag }}
    git push origin master --tags

# Open Docker Hub tags page
hub:
    open https://hub.docker.com/r/cgwire/cgwire/tags

# Full local workflow: update versions, build, check, release
all: update-versions build check-all release
