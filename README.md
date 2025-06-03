# M300 Git

## Setup

```bash
docker compose --project-directory app --project-name myapp  --env-file app/.env  -f app/docker-compose.traefik.yml up -d

docker compose --project-directory app --project-name myapp  --env-file app/.env  -f app/docker-compose.portainer.yml up -d

```