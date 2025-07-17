# Kitsu Project - Developer Notes

This document outlines the technical structure, setup, and development workflow for working on the open-source Kitsu platform. It is meant to guide new contributors through installation, architecture understanding, and best practices when collaborating on this project.

---

## Table of Contents

1. Project Overview  
2. System Architecture  
3. Docker & Container Breakdown  
4. Installation Steps (Recommended Order)  
5. Common Commands Explained  
6. Development Workflow with Git  

---

## 1. Project Overview

Kitsu is a production tracking system used in animation and VFX pipelines. It is built as a web application consisting of:

- A frontend written in Vue.js  
- A backend API written using Falcon (not FastAPI)  
- A supporting system called Zou which handles the backend logic and database operations  

This repository focuses on the Docker-based deployment of Kitsu for local development purposes.

---

## 2. System Architecture

The system is composed of the following major components:

- **Zou**: The backend service for Kitsu, written in Python using Falcon. It exposes REST APIs to the frontend.  
- **Kitsu frontend**: A Vue.js application that communicates with Zou.  
- **PostgreSQL**: The relational database used to store Kitsu’s core data (projects, tasks, users, etc).  
- **Redis**: An in-memory data store used as a message broker for background jobs.  
- **MailDev (internal webmail)**: A development-only service to catch and view outgoing emails at [http://127.0.0.1:1080](http://127.0.0.1:1080)  
- **Docker Volumes**: Used for persisting data like PostgreSQL files and image previews.  
- **Nginx**: A web server and reverse proxy that serves the frontend and API through port 80.  

---

## 3. Docker & Container Breakdown

Docker is used to containerize the entire stack. Each component runs in its own container, defined and managed using `docker-compose.yml`.

### Example Command

```bash
docker compose up -d
```

**Explanation**:
- `docker`: invokes the Docker CLI  
- `compose`: tells Docker to use the docker-compose tool  
- `up`: builds and starts the containers  
- `-d`: runs them in detached (background) mode  

Once running, you can access:
- Kitsu: [http://127.0.0.1:80](http://127.0.0.1:80)  
- Webmail: [http://127.0.0.1:1080](http://127.0.0.1:1080)

---

## 4. Installation Steps (Recommended Order)

To get the project up and running from scratch (Windows + WSL):

### 1. Install Git  
Download from [https://git-scm.com](https://git-scm.com)

### 2. Install WSL + Ubuntu  
Open PowerShell as Admin and run:  
```bash
wsl --install
```
Reboot and install Ubuntu from the Microsoft Store.

### 3. Install Docker Desktop  
Download from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)  
Ensure **WSL 2 integration** is enabled during installation.

### 4. Install Node.js (optional, for frontend dev)  
Only if you want to run the Vue frontend locally.  
Download from [https://nodejs.org](https://nodejs.org)

### 5. Clone this repository  
Inside Ubuntu:
```bash
mkdir ~/kitsu-project
cd ~/kitsu-project
git clone https://github.com/YOUR_USERNAME/kitsu-docker.git
cd kitsu-docker
```

### 6. Create the `docker-compose.yml` file  
Follow the structure shown in the official README.

### 7. Create persistent storage folder  
```bash
mkdir zou-storage
```

### 8. Launch the system  
```bash
docker compose up -d
```

Login credentials:
- Email: `admin@example.com`
- Password: `mysecretpassword`

---

## 5. Common Docker Commands

```bash
docker compose up -d          # Start containers in background
docker compose down           # Stop and remove containers
docker ps                     # View running containers
docker logs [container]       # View logs for a container
docker exec -ti [container] bash   # Enter container shell
```

Example:
```bash
docker exec -ti kitsu bash
```

You can use this to inspect files, run commands, or update the database schema.

---

## 6. Development Workflow with Git

### Branch Strategy

- `main` (or `master`): stable, production-ready code  
- `project-setup`, `comment-sidebar`, etc: feature or task-specific branches  
- Use pull requests to merge features into main  

### Collaboration

- Only one shared GitHub repo is used  
- Clone via HTTPS or SSH  
- Sync often using `git pull origin main` and push feature work to your own branch  

### Ignoring Local Files

To prevent accidental commits of personal files or temp data, use a `.gitignore`:

```
zou-storage/
notes.md
```

If you want to share notes with your team, **include** `NOTES.md` in Git (do not ignore it).

---

