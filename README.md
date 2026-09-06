# rcb-webserver — Laufzeit-Abbild

Das Container-Abbild, in dem der **RAWCaptureBooth Selfhosted-Webserver** läuft.

```
ghcr.io/rawcapturebooth/rcb-webserver:1.0.0
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
    image: ghcr.io/rawcapturebooth/rcb-webserver:1.0.0
    restart: unless-stopped
    ports:
      - "98:80"
    volumes:
      - /var/www/rcb-selfhosted-webserver:/var/www/html
    environment:
      - DB_HOST=db
      # ... weitere Variablen siehe Installationsanleitung
```

Die vollständige Vorlage liegt dem Auslieferungspaket des Webservers bei
(`docker/Docker-Compose-Stack.txt`).

**Nummer festhalten, nicht `latest` verwenden.** Sonst wechselt beim nächsten
Neustart unbemerkt der Unterbau unter einer laufenden Anlage.

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
