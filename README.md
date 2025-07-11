**M300: Aufbau einer produktiven und überwachten Service-Umgebung**
===================================================================

Dieses Projekt dokumentiert den Entwurf, die Implementierung und die Überwachung einer containerisierten Service-Infrastruktur. Das Ziel war die Bereitstellung einer stabilen und wartbaren produktiven Umgebung unter Verwendung von Technologien wie Docker, Nextcloud, Prometheus und Grafana.

## Stakeholder

-   **IT-Abteilung:** Die IT-Abteilung ist für die Bereitstellung der Produktivumgebung verantwortlich.
    -   Lev Saminskij

* * * * *

### **Inhaltsverzeichnis**

-   **1\. Analyse und Konzept**
    -   1.1. Projektidee und Ziele (Soll-Konzept)
    -   1.2. Ist-Analyse
    -   1.3. Evaluierte Lösungs-Varianten
    -   1.4. Architektur & Lösungsdesign
-   **2\. Projekttagebuch (Zusammenfassung)**
-   **3\. Umsetzung: Schritt-für-Schritt-Anleitung**
-   **4\. Sicherheitskonzept**
-   **5\. Betrieb und Wartung**
-   **6\. Verwendete Technologien und Hilfsmittel**
-   **7\. Referenzen & Links**

* * * * *

**1\. Analyse und Konzept**
---------------------------

Dieser Abschnitt beschreibt die Planungsphase des Projekts, die getroffenen Entscheidungen und das entworfene Systemkonzept.

### **1.1. Projektidee und Ziele (Soll-Konzept)**

Ziel dieses Projekts ist der Aufbau einer voll funktionsfähigen, sicheren und überwachten Serverumgebung für das Hosting von Web-Services. Alle Dienste sollen containerisiert und durch einen Reverse Proxy mit automatischem HTTPS betrieben werden. Ein zentrales Monitoring mit Prometheus und Grafana soll die Systemgesundheit visualisieren, während Uptime Kuma proaktive Benachrichtigungen bei Ausfällen sicherstellt.

**Hauptziele:**

-   **Containerisierung:** Alle Dienste laufen isoliert in Docker-Containern.
-   **Zentrales Monitoring:** Metriken aller Dienste werden zentral gesammelt und visualisiert.
-   **Proaktives Alerting:** Automatische Benachrichtigung bei Service-Ausfällen.
-   **Sicherheit:** Automatisches HTTPS für alle Endpunkte und sichere Passwort-Verwaltung.
-   **Skalierbarkeit:** Die Architektur soll einfach um weitere Dienste erweiterbar sein.
-   **Wartbarkeit:** Klare Dokumentation für Betrieb und Wartung.

### **1.2. Ist-Analyse**

Die Ausgangslage war ein neu aufgesetzter Server ohne jegliche Konfiguration. Es gab keine standardisierte Methode zur Bereitstellung von Diensten, kein zentrales Monitoring und keine automatisierten Sicherheitsmechanismen wie HTTPS. Jeder neue Dienst hätte manuell konfiguriert und gewartet werden müssen, was ineffizient und fehleranfällig ist.

### **1.3. Evaluierte Lösungs-Varianten**

Im Rahmen der Planung wurden verschiedene Technologien evaluiert, um die Projektziele bestmöglich zu erfüllen. Die Entscheidungen wurden auf Basis von Funktionalität, Einfachheit und dem Status als Industriestandard getroffen.

-   **Reverse Proxy:**
    -   **Caddy:** Gewählt aufgrund seiner revolutionär einfachen Konfiguration und des vollautomatischen Managements von HTTPS-Zertifikaten (inkl. Erneuerung). Dies minimiert den administrativen Aufwand und die Fehleranfälligkeit im Vergleich zu Alternativen.
    -   *Alternativen:*
        -   **Nginx:** Sehr leistungsstark und etabliert, erfordert jedoch eine manuelle Konfiguration von SSL/TLS-Zertifikaten (z.B. über Certbot) und eine komplexere Konfigurationssyntax.
        -   **Traefik:** Speziell für Container-Umgebungen entwickelt und bietet ebenfalls automatische Konfiguration, wurde aber zugunsten der schlankeren und einfacheren Konfigurationsdatei von Caddy verworfen.

-   **Monitoring-Stack:**
    -   **Prometheus & Grafana:** Diese Kombination wurde als De-facto-Industriestandard für metrikbasiertes Monitoring gewählt. Prometheus ist extrem effizient in der Sammlung und Speicherung von Zeitreihendaten. Grafana ist unübertroffen in der flexiblen und mächtigen Visualisierung dieser Daten.
    -   *Alternativen:*
        -   **ELK-Stack (Elasticsearch, Logstash, Kibana):** Eher auf das Sammeln und Analysieren von Logs spezialisiert (Log-Aggregation) und weniger auf systemische Metriken.
        -   **InfluxDB & Telegraf:** Eine starke Alternative, aber der Prometheus-Ansatz mit seinem Pull-Modell und der Service Discovery wurde für diese dynamische Container-Umgebung als passender erachtet.

-   **Uptime-Monitoring:**
    -   **Uptime Kuma:** Eine einfache, selbst-hostbare Lösung, die perfekt für das "Black-Box-Monitoring" geeignet ist. Sie prüft die Erreichbarkeit von Endpunkten von aussen und bietet vielfältige Benachrichtigungsmöglichkeiten.
    -   *Alternativen:*
        -   **Externe Dienste (z.B. Pingdom, UptimeRobot):** Bieten ähnliche Funktionalität, erzeugen aber eine Abhängigkeit von einem externen Anbieter und potenziell zusätzliche Kosten. Die Self-Hosting-Option wurde bevorzugt.

### **1.4. Architektur & Lösungsdesign**

<img src="./Architekturdiagramm.svg" alt="Alt-Text: Architekturdiagramm" width="800" />

#### **1.4.1\. Orchestrierung mit Docker Compose**

Die Grundlage des gesamten Systems bildet **Docker Compose**. Diese Entscheidung wurde getroffen, da es eine deklarative Methode bietet, um eine komplexe Multi-Container-Anwendung zu definieren und zu verwalten. Anstatt einzelne `docker run`-Befehle manuell auszuführen, definiert die `docker-compose.yml`-Datei alle Services, ihre Abhängigkeiten, Netzwerke und Volumes an einem zentralen Ort. Dies garantiert eine **reproduzierbare und konsistente Bereitstellung** auf jedem beliebigen Host und vereinfacht den gesamten Lebenszyklus der Anwendung (Start, Stopp, Update) erheblich.

#### **1.4.2\. Gateway und Sicherheit mit Caddy**

Als zentraler Einstiegspunkt und Reverse Proxy wurde bewusst **Caddy** gewählt. Im Gegensatz zu Alternativen wie Nginx bietet Caddy eine entscheidende Funktion "out-of-the-box": **automatisches HTTPS**. Caddy bezieht und erneuert vollautomatisch TLS-Zertifikate für alle in der `Caddyfile` definierten Domains. Dies erhöht nicht nur die Sicherheit massiv, sondern reduziert auch den administrativen Aufwand auf null.

Caddy agiert als einziger nach aussen exponierter Dienst (auf den Ports 80 und 443) und leitet den Traffic basierend auf der angefragten Subdomain sicher an die internen Backend-Dienste weiter. Der Zugriff auf sensitive Endpunkte wie Prometheus wird zusätzlich über eine **Basic Authentication** auf Ebene des Proxys abgesichert.

#### **1.4.3\. Die Kernanwendung: Eine entkoppelte Nextcloud-Suite**

Die Hauptanwendung, Nextcloud, wurde nicht als monolithischer Block, sondern als eine Gruppe von zusammenarbeitenden, entkoppelten Diensten implementiert, um Performance und Skalierbarkeit zu maximieren:

-   **Nextcloud:** Der eigentliche Applikations-Container, der die Logik enthält.
-   **MySQL:** Als Datenbank wurde MySQL anstelle einer einfacheren Lösung wie SQLite gewählt, da es für den produktiven Einsatz mit mehreren Benutzern eine deutlich höhere Performance, Transaktionssicherheit und bessere Nebenläufigkeit bietet.
-   **Redis:** Dieser In-Memory-Cache wird für das "File Locking" und das Caching von Sessions genutzt. Dies entlastet die Datenbank und die Hauptanwendung erheblich und sorgt für eine spürbar schnellere Benutzererfahrung.
-   **Garage (S3-Speicher):** Anstatt die Dateien direkt im Dateisystem des Containers zu speichern, wurde der Objektspeicher **Garage** über das **S3-Protokoll** angebunden. Diese Entscheidung ist architektonisch entscheidend: Sie entkoppelt die Daten von der Anwendung, was eine unabhängige Skalierung des Speichers ermöglicht und Backup-Strategien vereinfacht.

#### **1.4.4\. Umfassendes Monitoring und Observability**

Das Monitoring-System ist das Herzstück der Observability-Strategie und besteht aus mehreren Schichten:

-   **Prometheus (Metrik-Sammlung):** Als industrieller Standard für die Metrik-Sammlung verfolgt Prometheus einen **Pull-basierten Ansatz**. Er fragt aktiv (scraped) Metrik-Endpunkte ab, die von den verschiedenen Diensten bereitgestellt werden.
-   **Die Exporter (Datentiefe):** Um Prometheus aussagekräftige Daten zu liefern, wird eine Reihe spezialisierter Exporter eingesetzt:
    -   **Node Exporter:** Liefert Metriken über den Host-Server selbst (CPU, RAM, Festplatten-IO, Netzwerk).
    -   **cAdvisor (Container Advisor):** Stellt detaillierte Live-Metriken für jeden einzelnen laufenden Docker-Container bereit.
    -   **MySQLd, Redis, Nextcloud Exporter:** Bieten anwendungsspezifische Metriken, die einen tiefen Einblick in den Zustand und die Leistung der Kerndienste ermöglichen (z.B. Datenbank-Abfragen pro Sekunde, Cache-Trefferquote).
-   **Grafana (Visualisierung):** Grafana ist an Prometheus als Datenquelle angebunden und dient zur Erstellung von Dashboards. Diese visualisieren die gesammelten Metriken und ermöglichen es, den Systemzustand und Leistungsengpässe auf einen Blick zu erkennen.

#### **1.4.5\. Proaktives Alerting mit Uptime Kuma**

Während Prometheus und Grafana das "White-Box-Monitoring" (den inneren Zustand des Systems) abdecken, übernimmt **Uptime Kuma** das **"Black-Box-Monitoring"**. Es prüft die Erreichbarkeit der Dienste von aussen, so wie es ein Benutzer tun würde. Bei einem Ausfall (z.B. wenn eine Webseite nicht mehr antwortet) versendet Uptime Kuma eine **sofortige Benachrichtigung** (z.B. an Telegram). Dieser proaktive Ansatz schliesst die Überwachungsschleife und ermöglicht eine schnelle Reaktion auf Störungen, bevor sie von Benutzern bemerkt werden.

**2\. Projekttagebuch (Zusammenfassung)**
-----------------------------------------

Dieses Tagebuch fasst den Projektverlauf und die wöchentlichen Fortschritte zusammen. Genauere Informationen zu den einzelnen Tagen findest du in den [Arbeitsjournalen](./Arbeitsjournal/README.md).

-   **Woche 1 (13.05.2025):** Projektstart, Definition der Ziele und erste Recherche zu Technologien wie Docker, Prometheus und Grafana. Entscheidung für das grundlegende Technologie-Stack.
-   **Woche 2 (20.05.2025):** Beginn der praktischen Umsetzung. Aufsetzen des Servers, Installation von Docker und Erstellung der grundlegenden Ordnerstruktur.
-   **Woche 3 (27.05.2025):** Erstellung der initialen `docker-compose.yml`. Konfiguration von Caddy als Reverse Proxy und Einrichtung der ersten DNS-Einträge.
-   **Woche 4 (03.06.2025):** Konfiguration von Prometheus und dem MySQL-Exporter. Erste Versuche, Metriken zu sammeln.
-   **Woche 5 (10.06.2025):** Aufsetzen von Grafana und Anbindung an die Prometheus-Datenquelle. Erstellung erster einfacher Dashboards.
-   **Woche 6 (17.06.2025):** Implementierung von Garage als S3-kompatiblen Speicher und Konfiguration von Nextcloud. Integration von Uptime Kuma für das Healthcheck-Monitoring.
-   **Woche 7 (24.06.2025):** Implementierung von Garage als S3-kompatiblen Speicher und Konfiguration von Nextcloud.
-   **Woche 8 (01.07.2025):** Finale Konfiguration der Services, Einrichtung der Uptime-Benachrichtigungen via Telegram und detaillierte Ausarbeitung der Grafana-Dashboards. Abschluss der Dokumentation.

**3\. Umsetzung: Schritt-für-Schritt-Anleitung**
------------------------------------------------

Die Umsetzung des Projekts folgte einer "Lift and Shift"-Strategie. Die gesamte Umgebung wurde zuerst vollständig auf einer lokalen Maschine entwickelt und getestet, bevor sie auf die produktive Hetzner Cloud-Infrastruktur "gehoben" wurde.

Dieser Ansatz wurde aus mehreren strategischen Gründen gewählt:
-   **Kosten-Effizienz:** Die lokale Entwicklung verursacht keine laufenden Kosten für Cloud-Ressourcen. Server und Services müssen nur für die finale Bereitstellung und den produktiven Betrieb gemietet werden.
-   **Vereinfachtes Testen:** In einer lokalen Umgebung können Tests schneller und ohne Netzwerk-Latenz durchgeführt werden. Fehler und Konfigurationsprobleme lassen sich so agiler identifizieren und beheben, ohne die Stabilität einer Live-Umgebung zu gefährden.
-   **Reproduzierbarkeit:** Durch die Entwicklung mit Docker Compose wird sichergestellt, dass die exakt gleiche Konfiguration, die lokal funktioniert, auch in der Cloud zuverlässig läuft.

Die detaillierte technische Dokumentation für beide Phasen findet sich in den folgenden Anleitungen:

-   **1. Lokale Entwicklung:** [Anleitung zum Aufbau der lokalen Testumgebung](./docs/AUFBAU_LOCAL.md)
-   **2. Produktive Bereitstellung:** [Anleitung zum Aufbau der produktiven Umgebung](./docs/AUFBAU_PROD.md)

**4\. Sicherheitskonzept**
-------------------------

Ein robustes Sicherheitskonzept ist entscheidend für den stabilen Betrieb. Die folgenden Massnahmen wurden umgesetzt:

-   **Transportverschlüsselung:** Caddy sorgt für eine automatische und erzwungene HTTPS-Verschlüsselung für alle externen Endpunkte.
-   **Secret Management:** Alle sensiblen Daten wie Passwörter und API-Keys werden ausschliesslich über eine `.env`-Datei verwaltet und sind via `.gitignore` von der Versionskontrolle ausgeschlossen.
-   **Zugriffsbeschränkung:** Administrative Endpunkte (z.B. Prometheus UI) sind durch eine zusätzliche Basic Authentication auf Reverse-Proxy-Ebene geschützt.
-   **Minimale Angriffsfläche:** Nur die Ports 80 und 443 sind öffentlich exponiert. Alle anderen Dienste kommunizieren in einem internen Docker-Netzwerk.
-   **Regelmässige Updates:** Das Host-System und die Container-Images sollten regelmässig aktualisiert werden, um Sicherheitslücken zu schliessen.

Detaillierte Informationen finden sich im [Sicherheitskonzept in der Aufbau-Anleitung](./docs/AUFBAU_PROD.md#10-sicherheitskonzept).

**5\. Betrieb und Wartung**
---------------------------

Die Wartbarkeit der Umgebung wurde durch folgende Punkte sichergestellt:

-   **Zweistufige Backup-Strategie:**
    -   **Hetzner VM-Snapshots:** Tägliche Snapshots des gesamten Servers dienen als Desaster-Recovery-Lösung. Sie ermöglichen eine schnelle Wiederherstellung der kompletten VM im Falle eines schwerwiegenden Systemfehlers, sind jedoch nicht für granulare Restores geeignet.
    -   **Duplicati Backups:** Zusätzlich zu den Snapshots sichert Duplicati täglich die Anwendungsdaten (z.B. Konfigurationen, Datenbanken) auf einen externen Cloud-Speicher. Diese Backups sind ideal für granulare Wiederherstellungen, beispielsweise wenn versehentlich eine einzelne Datei oder Konfiguration gelöscht wurde, ohne den gesamten Server zurücksetzen zu müssen.
-   **Definierte Update-Prozesse:** Eine klare Anleitung zur Aktualisierung der einzelnen Container-Services.
-   **Zentrales Logging und Monitoring:** Ermöglicht eine schnelle Fehleranalyse.
-   **Wiederherstellungsprozess:** Die Dokumentation beschreibt die notwendigen Schritte zur Wiederherstellung der Umgebung aus einem Backup.

Detaillierte Anleitungen finden sich im Kapitel [Wartung und Betrieb in der Aufbau-Anleitung](./docs/AUFBAU_PROD.md#11-wartung-und-betrieb).

**6\. Verwendete Technologien und Hilfsmittel**
-----------------------------------------------

-   **Betriebssystem:** Ubuntu 24.04
-   **Containerisierung:** Docker & Docker Compose
-   **Webserver/Reverse Proxy:** Caddy
-   **Monitoring:** Prometheus, Grafana, Uptime Kuma, Diverse Prometheus Exporter
-   **Services:** Nextcloud
-   **Speicher** Garage (S3-Speicher)
-   **Datenbank:** MySql (für Nextcloud)
-   **Backups:** Duplicati und Hetzner VM Snapshots
-   **Benachrichtigungen:** Telegram
-   **Entwicklungsumgebung:** VS Code (mit Docker- und SSH-Erweiterungen)
-   **Versionskontrolle:** Git

**7\. Referenzen & Links**
---------------------------

- **Nextcloud Docker Dokumentation** [https://github.com/nextcloud/docker?tab=readme-ov-file#auto-configuration-via-environment-variables](https://github.com/nextcloud/docker?tab=readme-ov-file#auto-configuration-via-environment-variables)
- **Nextcloud Prometheus Exporter Dokumentation** [https://github.com/xperimental/nextcloud-exporter](https://github.com/xperimental/nextcloud-exporter)
- **Garage Docker Dokumentation** [https://garagehq.deuxfleurs.fr/documentation/cookbook/real-world/](https://garagehq.deuxfleurs.fr/documentation/cookbook/real-world/)
- **Garage WebUI Docker Dokumentation** [https://github.com/kostko/garage-webui](https://github.com/kostko/garage-webui)
- **Redis Dokumentation** [https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/docker/](https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/docker/)
- **Redis Prometheus Exporter Dokumentation** [https://github.com/oliver006/redis_exporter](https://github.com/oliver006/redis_exporter)
- **Mysql Dokumentation** [https://hub.docker.com/_/mysql/](https://hub.docker.com/_/mysql/)
- **Mysql Prometheus Exporter Dokumentation** [https://hub.docker.com/r/prom/mysqld-exporter](https://hub.docker.com/r/prom/mysqld-exporter)
- **Caddy Dokumentation** [https://caddyserver.com/docs/caddyfile/concepts](https://caddyserver.com/docs/caddyfile/concepts)
- **Caddy Prometheus Metrics Dokumentation** [https://caddyserver.com/docs/metrics](https://caddyserver.com/docs/metrics)
- **Portainer Dokumentation** [https://docs.portainer.io/start/install-ce/server/docker/linux](https://docs.portainer.io/start/install-ce/server/docker/linux)
- **Prometheus Dokumentation** [https://prometheus.io/docs/prometheus/latest/configuration/configuration/](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- **Grafana Dokumentation** [https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)
- **Grafana Dashboard Configuration** [https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/create-dashboard/](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/create-dashboard/)
-   **Uptime Kuma Dokumentation** [https://github.com/louislam/uptime-kuma/wiki/%F0%9F%94%A7-How-to-Install](https://github.com/louislam/uptime-kuma/wiki/%F0%9F%94%A7-How-to-Install)
-   **Prometheus Node Exporter Dokumentation** [https://github.com/prometheus/node_exporter](https://github.com/prometheus/node_exporter)
-   **Prometheus CAdvisor Dokumentation** [https://github.com/google/cadvisor](https://github.com/google/cadvisor)