# Lokale Test Umgebung 

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

```bash
docker compose --env-file .env exec -it garage /garage status
docker compose --env-file .env exec -it garage /garage layout assign -z dc1 -c 1G <node_id>
docker compose --env-file .env exec -it garage /garage layout apply --version 1

docker compose --env-file .env exec -it garage /garage bucket create nextcloud-bucket
docker compose --env-file .env exec -it garage /garage bucket info nextcloud-bucket

docker compose --env-file .env exec -it garage /garage key create nextcloud-app-key
docker compose --env-file .env exec -it garage /garage key info nextcloud-app-key

docker compose --env-file .env exec -it garage /garage bucket allow --read --write --owner nextcloud-bucket --key nextcloud-app-key

```

## Domains


| Domain       | URL           |
| ------------ | ------------- |
| portainer-m300.local | http://portainer-m300.local |
| nextcloud-m300.local | http://nextcloud-m300.local |
| minio-api-m300.local | http://minio-api-m300.local |
| minio-web-m300.local | http://minio-web-m300.local |
| minio-console-m300.local | http://minio-console-m300.local |
| prometheus-m300.local | http://prometheus-m300.local |
| grafana-m300.local | http://grafana-m300.local |