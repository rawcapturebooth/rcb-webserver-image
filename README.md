# rcb-webserver — Laufzeit-Abbild

Das Container-Abbild, in dem der **RAWCaptureBooth Selfhosted-Webserver** läuft.

```
ghcr.io/rawcapturebooth/rcb-webserver:latest
```

## Was drin ist — und was nicht

Drin ist Apache mit PHP 8.2 und genau den Erweiterungen, die der Webserver
braucht: GD (mit JPEG und WebP), ZIP, PDO/MySQL und mysqli, dazu `mod_rewrite`,
angehobene Grenzen für Uploads und die Verzeichnisregeln für `/var/www/html`.

**Kein Anwendungscode.** Der Auftritt wird zur Laufzeit hineingereicht, nicht
mitgebacken. Deshalb enthält dieses Abbild auch keine Zugangsdaten, keine
Einstellungen und keine Daten irgendeines Betriebs — alles davon kommt über
Umgebungsvariablen und über das eingehängte Verzeichnis.

Wer das Abbild herunterlädt, bekommt ein vorkonfiguriertes PHP. Sonst nichts.

## Verwendung

```yaml
services:
  photobooth:
    image: ghcr.io/rawcapturebooth/rcb-webserver:latest
    restart: unless-stopped
    ports:
      - "98:80"
    volumes:
      - /var/www/rcb-selfhosted-webserver:/var/www/html
    environment:
      - DB_HOST=db
      # ... weitere Variablen siehe Installationsanleitung
```

Die vollständigen Vorlagen liegen dem Auslieferungspaket des Webservers bei:
`docker/Docker-Compose-Stack.txt` für Portainer und andere Oberflächen,
`docker/Docker-Compose-Stack-Coolify.txt` für Coolify.

**`latest` oder eine feste Nummer.** Ein bloßer Neustart wechselt das Abbild
nicht – das geschieht erst, wenn es ausdrücklich neu geholt wird
(`docker compose pull`, in Portainer „Re-pull image“, in Coolify beim
erneuten Bereitstellen). Wer eine Anlage auf einem Stand festhalten will,
trägt statt `latest` die Nummer ein, etwa `:1.2.0`.

## Dateirechte beim Start

Apache läuft als `www-data`. Hat jemand den Auftritt per SFTP oder über eine
Netzfreigabe abgelegt, gehören die Dateien diesem Zugang – der Webserver kann
dann weder Bilder ablegen noch sich selbst aktualisieren.

Seit 1.2.0 prüft das Abbild beim Start, ob `www-data` in den oberen beiden
Verzeichnisebenen des Auftritts schreiben darf. Fehlt das Recht, setzt es den
Besitzer einmal auf `www-data` und schreibt das ins Protokoll des Containers.
Passt alles, bleibt es bei der Prüfung. Ein Fehlschlag hält den Start nicht auf.

Abschalten lässt sich das mit der Umgebungsvariable `RCB_RECHTE_SETZEN=0`.

## Fassungen

Dieses Abbild zählt eigenständig. Seine Nummer steht in `VERSION` und hat nichts
mit der Fassung des Webservers zu tun: Der Webserver erscheint häufig, das
Abbild nur dann, wenn sich an PHP, den Erweiterungen oder der
Server-Konfiguration etwas ändert.

Eine neue Ausgabe entsteht so:

1. `VERSION` hochzählen.
2. Änderung einchecken.
3. Kennzeichen setzen und schieben: `git tag v1.0.1 && git push origin v1.0.1`

GitHub baut daraufhin für amd64 und arm64 und lädt das Ergebnis hoch. Stimmen
Kennzeichen und `VERSION` nicht überein, bricht der Ablauf ab.

## Selbst bauen

```
docker build -t rcb-webserver:eigen .
```

## Herkunft

Thomas Michael Müller · [rawcapturebooth.app](https://rawcapturebooth.app)

Dieses Repository enthält allein die Beschreibung des Laufzeit-Abbilds. Der
Quelltext des Webservers ist nicht öffentlich.
