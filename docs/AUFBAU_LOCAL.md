# Lokale Testumgebung

Dieses Dokument beschreibt, wie die gesamte Service-Umgebung auf einem lokalen Rechner für Entwicklungs- und Testzwecke eingerichtet wird. Die lokale Konfiguration ist so gestaltet, dass sie die Produktivumgebung widerspiegelt und ein reibungsloses "Lift and Shift" in die Cloud ermöglicht.

## Voraussetzungen

-   **Docker** und **Docker Compose** müssen installiert sein.
-   **openssl** zur Generierung von sicheren Passwörtern.

## 1. Umgebungsvariablen einrichten (`.env` Datei)

Alle sicherheitsrelevanten Informationen wie Passwörter, API-Schlüssel und Konfigurationsparameter werden in einer `.env`-Datei gespeichert. Diese Datei wird von Git ignoriert, um zu verhindern, dass sensible Daten in die Versionskontrolle gelangen.

**Schritte:**

1.  **Kopieren Sie die Vorlage:**
    ```bash
    cp .example.env .env
    ```

2.  **Generieren und ersetzen Sie die Secrets:**
    Öffnen Sie die neu erstellte `.env`-Datei und ersetzen Sie alle Platzhalterwerte. Für die Erstellung sicherer, zufälliger Werte können Sie den folgenden Befehl verwenden:
    ```bash
    openssl rand -hex 32
    ```
    Führen Sie diesen Befehl für jedes Secret in der `.env`-Datei aus und kopieren Sie den generierten Wert.

## 2. Umgebung starten

Sobald die `.env`-Datei konfiguriert ist, können alle Dienste mit einem einzigen Befehl gestartet werden:

```bash
docker compose --env-file .env up -d
```

Dieser Befehl liest die `docker-compose.yaml`, lädt die benötigten Container-Images herunter und startet alle Dienste im Hintergrund (`-d` für "detached").

## 3. Services konfigurieren (Nach dem ersten Start)

Einige Dienste erfordern nach dem ersten Start eine einmalige Konfiguration.

### 3.1 Nextcloud Exporter Token

Damit der `nextcloud-exporter` Metriken für Prometheus sammeln kann, benötigt er einen Authentifizierungs-Token.

```bash
# Ersetzen Sie den Wert durch ein sicheres, zufälliges Token
docker compose --env-file .env exec -u www-data -it nextcloud php occ config:app:set serverinfo token --value "GENERATED_TOKEN"
```
Der hier gesetzte Token muss mit dem `NEXTCLOUD_AUTH_TOKEN`-Wert in Ihrer `.env`-Datei übereinstimmen.

### 3.2 Garage S3 Storage

Der S3-kompatible Speicher `Garage` muss initialisiert werden.

```bash
# Status prüfen, um die Node-ID zu erhalten
docker compose --env-file .env exec -it garage /garage status

# Layout zuweisen (ersetzen Sie <node_id> mit der ID aus dem vorherigen Befehl)
docker compose --env-file .env exec -it garage /garage layout assign -z dc1 -c 1G <node_id>
docker compose --env-file .env exec -it garage /garage layout apply --version 1

# S3-Bucket und Zugriffs-Key für Nextcloud erstellen
docker compose --env-file .env exec -it garage /garage bucket create nextcloud-bucket
docker compose --env-file .env exec -it garage /garage key create nextcloud-app-key

# Dem Key die notwendigen Rechte für den Bucket geben
docker compose --env-file .env exec -it garage /garage bucket allow --read --write --owner nextcloud-bucket --key nextcloud-app-key
```

## 4. Lokale Domains und Services

Der **Caddy** Reverse Proxy macht alle Weboberflächen der Dienste über lokale Domains mit automatischem HTTPS verfügbar.

### 4.1 `/etc/hosts` anpassen

Damit Ihr lokaler Rechner diese Domains auflösen kann, müssen sie in Ihrer `/etc/hosts`-Datei (unter Linux/macOS) oder `C:\Windows\System32\drivers\etc\hosts` (unter Windows) auf `127.0.0.1` verweisen.

```
127.0.0.1 portainer-m300.local nextcloud-m300.local minio-api-m300.local minio-web-m300.local minio-console-m300.local prometheus-m300.local grafana-m300.local uptime-m300.local bck-m300.local
```

**Hinweis:** Caddy verwendet intern generierte, selbstsignierte TLS-Zertifikate (`tls internal`). Ihr Browser wird daher eine Sicherheitswarnung anzeigen, die Sie manuell akzeptieren müssen.

### 4.2 Service-Übersicht

| Domain | URL | Service | Zweck |
| :--- | :--- | :--- | :--- |
| `portainer-m300.local` | `https://portainer-m300.local` | Portainer | Grafische Oberfläche zur Verwaltung der Docker-Container. |
| `nextcloud-m300.local` | `https://nextcloud-m300.local` | Nextcloud | Die Hauptanwendung für File-Sharing und Kollaboration. |
| `minio-api-m300.local` | `https://minio-api-m300.local` | Garage (S3 API) | S3-API-Endpunkt für den Nextcloud-Objektspeicher. |
| `minio-web-m300.local` | `https://minio-web-m300.local` | Garage (S3 Web) | Web-Endpunkt für den direkten Zugriff auf S3-Objekte. |
| `minio-console-m300.local`| `https://minio-console-m300.local`| Garage UI | Web-Oberfläche zur Verwaltung des Garage S3-Speichers. |
| `prometheus-m300.local` | `https://prometheus-m300.local` | Prometheus | Sammelt Metriken von allen Services. |
| `grafana-m300.local` | `https://grafana-m300.local` | Grafana | Visualisiert die in Prometheus gesammelten Metriken. |
| `uptime-m300.local` | `https://uptime-m300.local` | Uptime Kuma | Überwacht die Erreichbarkeit der einzelnen Dienste. |
| `bck-m300.local` | `https://bck-m300.local` | Duplicati | Web-Oberfläche für die Konfiguration der Backups. |
