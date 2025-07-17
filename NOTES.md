# Kitsu Dev Notes
_Last updated: 2025-07-17_

## 🧠 Project Purpose & Structure
We are working on customizing Kitsu (an open-source animation production tracker) for internal use at our company.
- We are not using Kitsu for production data, just local development and UI/UX improvements.
- Our main goal is to improve the frontend layout, especially around comment handling during animation reviews.
- Components:
  - **Kitsu**: Vue.js frontend
  - **Zou**: Python backend (FastAPI)
  - **Docker**: Used to spin up Kitsu, Zou, Postgres, Redis, and a test mail server as isolated services
  - **Gazu**: Python wrapper/client for the Kitsu API (not critical for UI work but useful if we build Python tools)

## ⚙️ Setup Process
1. Installed Docker Desktop
2. Cloned the following repos:
   - `kitsu`
   - `zou`
   - `kitsu-docker`
3. Inside `kitsu-docker`, created and committed a `docker-compose.yml` file based on official docs
4. Ran `docker compose up -d` to spin up containers
   - Access Kitsu at: http://127.0.0.1:80
   - Access MailDev at: http://127.0.0.1:1080
5. (Optional) Enabled hybrid mode for frontend development:
   - Ran backend in Docker
   - Ran frontend locally via:
     ```bash
     cd kitsu
     npm install
     npm run serve
     ```
   - This allows hot-reloading with real backend data

## 🐳 Docker Notes
- Each major service (frontend, backend, DB, Redis, mail server) is isolated in its own container
- `zou-storage/` is used to persist DB and preview data; it's ignored via `.gitignore`
- Mail server is for local-only email testing (e.g., password resets)
- Docker volumes are not committed — everything is ephemeral unless explicitly mounted

## 📋 Project Workflow & Git Standards
- We are using **feature branches** to keep work clean
- Master/main should remain stable
- All work (even notes and setup) starts from branches like `project-setup`, `comment-sidebar`, etc.
- Feature branch naming convention:
  - `feature/comment-sidebar`
  - `bugfix/video-scaling`
- Team flow:
  - Romeo clones the shared repo
  - Both developers work on separate branches
  - Pull requests are created for merging back into main

## 🧪 Upcoming Features to Build
- Sidebar layout for comment display next to animation player (currently full screen only)
- Filter system for displaying animators differently
- Show comment history below each comment (chronological thread view)

## 🧰 Useful Commands (Non-Git)
- Start containers:
  ```bash
  docker compose up -d
  ```
- Shut everything down:
  ```bash
  docker compose down
  ```
- Upgrade DB schema after image update:
  ```bash
  docker exec -ti kitsu sh -c "/opt/zou/env/bin/zou upgrade-db"
  ```
- View logs (optional):
  ```bash
  docker compose logs -f
  ```
