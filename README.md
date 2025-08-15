# Symfony Docker Boilerplate

Ce projet fournit un conteneur Docker de base pour démarrer un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.

## Structure

- `.docker/` : contient le Dockerfile pour le conteneur Symfony
- `docker-compose.yml` : configuration des services pour Symfony
- `.env` : variables d'environnement pour la base de données et Traefik

## Prérequis

- Docker & Docker Compose
- Réseau Docker `web` (externe, utilisé par Traefik)
- Réseau Docker `mysql_network` (externe, utilisé par MariaDB/PMA)

## Variables d'environnement

Exemple `.env` pour Symfony :

```env
PROJECT_NAME=project_name
DOMAIN=project_name.dev.local
DATABASE_URL="mysql://MYSQL_USER:MYSQL_PASSWORD@mariadb:3306/MYSQL_DATABASE"
```

## Services
- app : conteneur Symfony
- mariadb : conteneur MariaDB
- phpmyadmin : conteneur PHPMyAdmin
- traefik : reverse proxy

## Démarrage
__1.__ Lancer MariaDB + PHPMyAdmin + Traefik si ce n’est pas déjà fait :

```bash
docker compose -f ../path-to-pma-traefik/docker-compose.yml up -d
```

__2.__ Lancer le conteneur Symfony :

```bash
docker compose up -d --build
```
__3.__ Ajouter le domaine au fichier hosts du système :

```text
127.0.0.1   project_name.dev.local
````


__4.__ Installer Symfony (si nécessaire) à l’intérieur du conteneur :

```bash
docker exec -it app bash
composer create-project symfony/skeleton .
```

__5.__ Accéder au projet :

```text
http://project_name.dev.local
````

## Notes
- Ne contient pas NodeJS
- Ce conteneur sert de squelette de projet Symfony, sans Symfony installé par défaut.
- Compatible avec Traefik pour le routage HTTP et MariaDB/PMA pour la base de données.