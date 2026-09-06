# Laufzeit-Abbild fuer den RAWCaptureBooth Selfhosted-Webserver.
#
# Diese Datei ist die massgebliche Fassung. Im Repository des Webservers liegt
# unter 'Docker-Image/Dockerfile' eine Kopie, die dem Auslieferungspaket
# beiliegt, damit ein Betreiber ohne Zugang zur Registry selbst bauen kann.
# Aenderungen gehoeren zuerst hierher.
#
# Bewusst enthaelt das Abbild keinen Anwendungscode: Der Auftritt wird zur
# Laufzeit eingehaengt. Deshalb kann es oeffentlich stehen.

FROM php:8.2-apache

# uploads.ini vorab kopieren (wie im Original-Image)
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Original-Build-Schritte (rekonstruiert aus `docker history` des bestehenden
# fotobox-bilder:1.0) plus pdo_mysql/mysqli fuer MariaDB/MySQL-Anbindung.
RUN apt-get update && apt-get install -y \
        libzip-dev \
        zip \
        libpng-dev \
        libjpeg-dev \
        libgif-dev \
        libwebp-dev \
        default-mysql-client \
    --no-install-recommends && \
    # WebP gehoert dazu, seit die Fotobox Animationen auch als WebP
    # ausliefern kann. Ohne diese Option kann GD solche Dateien nicht
    # oeffnen, ein unbewegtes WebP bekaeme kein Vorschaubild - und ohne
    # Vorschaubild keine Bildangaben, weshalb die Galerie die Aufnahme
    # wortlos ueberspraenge.
    docker-php-ext-configure gd --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd zip pdo_mysql mysqli && \
    a2enmod rewrite && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Die Regeln fuer das Webverzeichnis gehoeren in die Serverkonfiguration,
# nicht in die .htaccess: 'Options' ist auf gemietetem Webspace fast ueberall
# gesperrt und wuerde dort jede Seite mit einem Fehler 500 beantworten. Die
# .htaccess im Auftritt kommt deshalb ohne aus - hier, wo der Server uns
# gehoert, steht die Angabe richtig.
#
#   -Indexes         Keine Verzeichnislisten.
#   +FollowSymLinks  Voreinstellung des Grundbildes, bleibt erhalten.
#   AllowOverride    Die .htaccess-Dateien des Auftritts sollen greifen; sie
#                    sperren /uploads/ und die Zugangsdaten.
RUN printf '%s\n' \
        '<Directory /var/www/html>' \
        '    Options -Indexes +FollowSymLinks' \
        '    AllowOverride All' \
        '    Require all granted' \
        '</Directory>' \
        > /etc/apache2/conf-available/rcb.conf && \
    a2enconf rcb

WORKDIR /var/www/html
