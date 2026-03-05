# n8n Docker Compose

A production-ready, secure, self-hosted [n8n](https://n8n.io) workflow-automation environment running on Docker Compose with PostgreSQL.

> **Security first** – n8n is bound to `127.0.0.1` (localhost only).  
> No traffic from outside your machine can reach it.

---

## Table of Contents

1. [What's Included](#whats-included)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Platform-Specific Setup](#platform-specific-setup)
   - [Linux](#linux)
   - [macOS](#macos)
   - [Windows](#windows)
5. [Credentials](#credentials)
6. [Directory Structure](#directory-structure)
7. [Environment Variables Reference](#environment-variables-reference)
8. [Common Operations](#common-operations)
9. [Security Notes](#security-notes)
10. [CI/CD Pipeline](#cicd-pipeline)
11. [Troubleshooting](#troubleshooting)

---

## What's Included

| Service    | Image                  | Purpose                               |
|------------|------------------------|---------------------------------------|
| `n8n`      | `n8nio/n8n:latest`     | Workflow automation engine (UI + API) |
| `postgres` | `postgres:15-alpine`   | Persistent workflow database          |

**Key features of this setup**

- Bound to `127.0.0.1:5678` – zero external exposure
- Basic Authentication enabled out of the box
- Encryption key for credential storage
- Named Docker volumes for data persistence across restarts
- Health checks so n8n waits for PostgreSQL before starting
- GitHub Actions CI that blocks merges on any failure

---

## Prerequisites

| Tool              | Minimum version | Check command              |
|-------------------|-----------------|----------------------------|
| Docker Engine     | 24.x            | `docker --version`         |
| Docker Compose V2 | 2.20.x          | `docker compose version`   |
| `openssl`         | any             | `openssl version`          |

> **Docker Desktop** (Windows/macOS) bundles both Docker Engine and Docker Compose V2. Install it from <https://docs.docker.com/desktop/>.

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/daveshow/n8n-docker.git
cd n8n-docker

# 2. Create your local environment file
cp .env.example .env

# 3. Generate a secure encryption key
openssl rand -hex 32

# 4. Open .env and replace REPLACE_WITH_OUTPUT_OF_openssl_rand_-hex_32
#    with the key you just generated.
#    Optionally change passwords.

# 5. Start the stack
docker compose up -d

# 6. Open n8n in your browser
#    URL:       http://localhost:5678
#    Username:  admin          (N8N_BASIC_AUTH_USER in .env)
#    Password:  n8nAdmin2024!  (N8N_BASIC_AUTH_PASSWORD in .env)
```

---

## Platform-Specific Setup

### Linux

<details>
<summary>Click to expand Linux instructions</summary>

#### Step 1 – Install Docker Engine and Compose plugin

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Compose plugin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Allow your user to run Docker without sudo (log out and back in after)
sudo usermod -aG docker $USER
```

> For other distros (Fedora, CentOS, Arch) follow the official guide:
> <https://docs.docker.com/engine/install/>

#### Step 2 – Clone and configure

```bash
git clone https://github.com/daveshow/n8n-docker.git
cd n8n-docker
cp .env.example .env
```

Edit `.env` with your preferred editor:

```bash
nano .env   # or: vim .env
```

Replace `REPLACE_WITH_OUTPUT_OF_openssl_rand_-hex_32` with:

```bash
openssl rand -hex 32
```

#### Step 3 – Start

```bash
docker compose up -d
```

#### Step 4 – Verify

```bash
# Check both containers are running
docker compose ps

# Follow live logs
docker compose logs -f

# Test with curl
curl -u admin:n8nAdmin2024! http://localhost:5678/
```

#### What to avoid on Linux

- Do **not** expose port `5678` in firewall rules (`ufw`, `iptables`) to external IPs.
  The port is bound to `127.0.0.1` which prevents external connections by default.
- Do **not** commit `.env` to Git.
  It is already in `.gitignore`, but double-check with `git status`.

</details>

---

### macOS

<details>
<summary>Click to expand macOS instructions</summary>

#### Step 1 – Install Docker Desktop

1. Download Docker Desktop from <https://docs.docker.com/desktop/install/mac-install/>.
2. Choose the correct chip installer (**Apple Silicon** M1/M2/M3 or **Intel**).
3. Open the `.dmg` and drag Docker to Applications.
4. Launch **Docker Desktop** from Applications and complete the onboarding.
5. Verify:

```bash
docker --version
docker compose version
```

#### Step 2 – Clone and configure

```bash
git clone https://github.com/daveshow/n8n-docker.git
cd n8n-docker
cp .env.example .env
```

Generate an encryption key:

```bash
openssl rand -hex 32
```

Open `.env`:

```bash
open -e .env    # TextEdit
# or:
nano .env
```

Replace the placeholder `N8N_ENCRYPTION_KEY` value with the key you generated.

#### Step 3 – Start

```bash
docker compose up -d
```

#### Step 4 – Verify

```bash
docker compose ps
open http://localhost:5678
```

Login with:

| Field    | Value           |
|----------|-----------------|
| Username | `admin`         |
| Password | `n8nAdmin2024!` |

#### What to avoid on macOS

- Do **not** use Docker Toolbox (legacy). Use Docker Desktop only.
- Do **not** share the `.env` file via AirDrop, iCloud Drive, or email.
- Do **not** expose the port in macOS Firewall settings; it is already restricted to localhost.

</details>

---

### Windows

<details>
<summary>Click to expand Windows instructions</summary>

#### Step 1 – Enable WSL 2 (required)

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Restart your computer when prompted.

> If WSL is already installed, ensure you are on WSL 2:
> `wsl --set-default-version 2`

#### Step 2 – Install Docker Desktop

1. Download Docker Desktop from <https://docs.docker.com/desktop/install/windows-install/>.
2. Run the installer and ensure **"Use WSL 2 instead of Hyper-V"** is checked.
3. Launch **Docker Desktop** and complete the initial setup.
4. Verify in PowerShell or Windows Terminal:

```powershell
docker --version
docker compose version
```

#### Step 3 – Clone and configure

Open **PowerShell** or **Windows Terminal** (not Command Prompt):

```powershell
git clone https://github.com/daveshow/n8n-docker.git
cd n8n-docker
Copy-Item .env.example .env
```

Generate an encryption key:

```powershell
# Option A – using openssl bundled with Git for Windows
openssl rand -hex 32

# Option B – using PowerShell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Max 256) })
```

Edit `.env`:

```powershell
notepad .env
```

Replace the placeholder `N8N_ENCRYPTION_KEY` value with the 64-character hex string.
Save and close Notepad.

#### Step 4 – Start

```powershell
docker compose up -d
```

#### Step 5 – Verify

```powershell
docker compose ps
Start-Process "http://localhost:5678"
```

Login with:

| Field    | Value           |
|----------|-----------------|
| Username | `admin`         |
| Password | `n8nAdmin2024!` |

#### What to avoid on Windows

- Do **not** use Command Prompt (`cmd.exe`). Use **PowerShell** or **Windows Terminal**.
- Do **not** edit `.env` with Notepad if it inserts Windows line endings (CRLF).
  If you see parse errors, open the file in VS Code and set the line ending to **LF**.
- Do **not** commit `.env` to Git – it contains secrets.
- Do **not** allow Windows Firewall to open port `5678` externally.
  Docker binds it to `127.0.0.1` inside WSL 2, so external access is already blocked.

</details>

---

## Credentials

All default credentials are defined in `.env.example` and copied to `.env` during setup.

| Setting               | Default value        | Where to change                   |
|-----------------------|----------------------|-----------------------------------|
| n8n username          | `admin`              | `N8N_BASIC_AUTH_USER` in `.env`   |
| n8n password          | `n8nAdmin2024!`      | `N8N_BASIC_AUTH_PASSWORD` in `.env` |
| PostgreSQL database   | `n8n`                | `POSTGRES_DB` in `.env`           |
| PostgreSQL user       | `n8n_user`           | `POSTGRES_USER` in `.env`         |
| PostgreSQL password   | `PgPassword2024!`    | `POSTGRES_PASSWORD` in `.env`     |
| Encryption key        | *(must be generated)*| `N8N_ENCRYPTION_KEY` in `.env`    |

> **You must replace `N8N_ENCRYPTION_KEY`** with a real random value before first launch.
> Changing it later will invalidate all stored credentials in n8n.

> **Security warning:** The default passwords (`n8nAdmin2024!`, `PgPassword2024!`) are provided
> for convenience only. **Change them to strong, unique values before first launch.**
> Generate strong passwords with: `openssl rand -base64 18`

---

## Directory Structure

```
n8n-docker/
├── .env.example          # Template – copy to .env and fill in values
├── .gitignore            # Excludes .env and OS artefacts
├── docker-compose.yml    # Service definitions (n8n + postgres)
├── README.md             # This file
└── .github/
    └── workflows/
        └── ci.yml        # GitHub Actions CI/CD pipeline
```

---

## Environment Variables Reference

| Variable                  | Required | Description                                        |
|---------------------------|----------|----------------------------------------------------|
| `N8N_BASIC_AUTH_USER`     | Yes      | Username to log in to n8n                          |
| `N8N_BASIC_AUTH_PASSWORD` | Yes      | Password to log in to n8n                          |
| `N8N_ENCRYPTION_KEY`      | Yes      | 64-char hex key for encrypting stored credentials  |
| `POSTGRES_DB`             | Yes      | Name of the PostgreSQL database                    |
| `POSTGRES_USER`           | Yes      | PostgreSQL username                                |
| `POSTGRES_PASSWORD`       | Yes      | PostgreSQL password                                |
| `TIMEZONE`                | No       | IANA timezone (default: `UTC`)                     |

---

## Common Operations

```bash
# Start in background
docker compose up -d

# Stop (keep data)
docker compose stop

# Stop and remove containers (keep volume data)
docker compose down

# Stop and remove containers AND all data (destructive!)
docker compose down --volumes

# Follow live logs
docker compose logs -f

# Follow n8n logs only
docker compose logs -f n8n

# Upgrade n8n to the latest release
docker compose pull n8n
docker compose up -d n8n
```

---

## Security Notes

| Topic              | Detail                                                                        |
|--------------------|-------------------------------------------------------------------------------|
| Port binding       | `127.0.0.1:5678` – only processes on the same machine can connect             |
| Authentication     | HTTP Basic Auth enforced on every request                                     |
| Secrets            | All secrets live in `.env`, which is `.gitignore`d                            |
| Encryption key     | Encrypts all n8n credentials at rest in the database                          |
| Database isolation | `postgres` is on an internal Docker network; it has no host-port binding      |
| No root            | n8n runs as the `node` user inside the container                              |

---

## CI/CD Pipeline

The `.github/workflows/ci.yml` workflow runs on every push and pull request to `main`.
**Pull requests cannot be merged if any job fails.**

| Job              | What it checks                                      | Failure reason                         |
|------------------|-----------------------------------------------------|----------------------------------------|
| `lint-compose`   | `docker-compose.yml` syntax; both services declared | Invalid YAML or missing service        |
| `validate-env`   | All required variables present in `.env.example`    | A variable was removed or renamed      |
| `security-check` | `.env` in `.gitignore`; port bound to `127.0.0.1`   | Secrets risk or external exposure      |
| `integration`    | Stack starts; n8n returns 200; Basic Auth returns 401 | Container crash, bad config, or auth misconfiguration |

### How to fix a CI failure

1. Click the failing job in the **Actions** tab on GitHub.
2. Expand the failing step to read the error message.
3. Common fixes:

| Error message                                    | Fix                                                                     |
|--------------------------------------------------|-------------------------------------------------------------------------|
| `'n8n' service missing`                          | Restore the `n8n:` block in `docker-compose.yml`                        |
| `'postgres' service missing`                     | Restore the `postgres:` block in `docker-compose.yml`                   |
| `'N8N_ENCRYPTION_KEY' is missing from .env.example` | Add the variable back to `.env.example`                              |
| `.env is NOT listed in .gitignore`               | Add `.env` to `.gitignore`                                              |
| `n8n port is not bound to 127.0.0.1`             | Change `"5678:5678"` to `"127.0.0.1:5678:5678"` in `docker-compose.yml` |
| `Expected 401 Unauthorized`                      | Ensure `N8N_BASIC_AUTH_ACTIVE: "true"` is set in `docker-compose.yml`  |
| `Login with preset credentials failed`           | Check that `N8N_BASIC_AUTH_USER`/`_PASSWORD` match `.env.example`       |
| `n8n did not become healthy`                     | Check `docker compose logs` for database connection errors              |

---

## Troubleshooting

**n8n fails to start – database connection error**

```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

PostgreSQL is not yet ready. n8n has a `depends_on` health check, but if it still fails:

```bash
docker compose restart n8n
```

**Port 5678 is already in use**

Change the host port in `docker-compose.yml`:

```yaml
ports:
  - "127.0.0.1:5679:5678"
```

**Forgot the n8n password**

Update `N8N_BASIC_AUTH_PASSWORD` in `.env`, then restart:

```bash
docker compose restart n8n
```

**Data not persisting after `docker compose down`**

Use `docker compose down` (without `--volumes`) to keep data.
Check volumes exist:

```bash
docker volume ls | grep n8n
```

**`docker compose` command not found**

Install the Docker Compose V2 plugin (see [Prerequisites](#prerequisites)).
Older installs may use `docker-compose` (with a hyphen) – upgrade to Compose V2.
