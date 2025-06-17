# M300 Git

## Setup

```
openssl rand -hex 32
```

```bash
docker compose --env-file .env up -d
```

```bash
docker compose --env-file .env exec -u www-data -it nextcloud php occ config:app:set serverinfo token --value "6b23104a8d96fd1fe3b238e122944af5b11593205b5162fa6790cce1a5c419da"
```