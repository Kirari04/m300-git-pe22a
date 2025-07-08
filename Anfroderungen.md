# Anforderungen

## Anforderungsbeschreibung für 3 P.

### Ermittlung erforderlicher Services
- Bedarfserhebung für das Projekt
- technische Anforderungen
- Zu berücksichtigende Aspekte: **Effizienz** (Rechenleistung / Kosten), **Sicherheit** (A1: Zugriffskontrollen, Secrets-Management, Verschlüsselung), **Skalierbarkeit**, **Flexibilität**
- Theoretisches Verständnis ist erkennbar (Begründung warum was wie gemacht wird)

### Entwicklung eines Integrationskonzepts
- Planung: Anforderungen erfassen, Netzwerkdesign entwickeln
- Implementierung (B1): Auswahl geeigneter Werkzeuge/Tools, Entwicklung, Testfälle (Unit-Tests, Integrationstests) planen
- Planung für Bereitstellung und Betrieb / Deployment (Monitoring, Wartung und Pflege)

### Konfiguration, Funktionsprüfung und Monitoring von (Cloud-)Services
- Datenmigration planen und durchführen
- Änderungen verwalten (Changemanagement)
- Services und Systeme optimieren (C1: z. B. Performance, Ressourcenverbrauch, Security)
- Verwendung von Konfigurationsmanagement (z. B. zentrale Variablen, Secrets-Verwaltung, Umgebungsprofile)

## Punkte Selbsteinschätzung
### P: 0-3

### Netzwerkverbindungen konfigurieren und testen
- Netzwerkverbindungen gemäss Dokumentation konfigurieren (D1)
- Konnektivität testen und dokumentieren

### Integration verschiedener Services und Plattformen
- Einsatz von Orchestrierung und Microservices (E1)
- Trennung (Kapselung) von verschiedenen Services / Funktionalitäten (API / Schnittstellen)
- Automatisierung der Bereitstellung (CI/CD)

### Betrieb und Überwachung von Services
- Überwachung des Betriebszustands (E2: Monitoring, Metriken, Logging)
- Implementierung von Alarmierung / Benachrichtigungen
- Vorkehrungen für Wartung, Updates und Verfügbarkeit
- Geplante Skalierung bei Lastanstieg (optional)
- Backup- und Wiederherstellungskonzepte (wo sinnvoll)

### Fehleranalyse und Protokollierung
- Fehler systematisch dokumentieren (F1: Kategorisierung, Priorisierung)
- Fehleranalyse anhand von Logfiles, Systemausgaben, Umgebungsinformationen

### Dokumentation des Gesamtsystems
- Visualisierung des Gesamtsystems (I1: Datenfluss, technologische Aspekte, Securityaspekte)
- Beschreibung der Funktionalität
- Netzwerkdiagramm
- Prozessvisualisierung (Flussdiagramm, Programmablaufplan, Struktogramm für Automatisierung)
- Rollenkonzept dokumentieren