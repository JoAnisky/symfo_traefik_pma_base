# Symfony (Docker) Traefik/PMA/MariaDB boilerplate

Ce projet fournit un conteneur Docker de base pour démarrer un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.

## Structure

- `.docker/` : contient le Dockerfile pour le conteneur Symfony
- `docker-compose.yml` : configuration des services pour Symfony
- `.env` : variables d'environnement pour la base de données et Traefik
- `my_project_directory/` : projet Symfony créé via `symfony new` ou `composer create-project`

## Prérequis

- Docker & Docker Compose
- Réseau Docker `web` (externe, utilisé par Traefik)
- Réseau Docker `mysql_network` (externe, utilisé par MariaDB/PMA)

## Variables d'environnement

Exemple `.env` pour Symfony avec MySQL/MariaDB :

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
__1.__ Créer le projet Symfony en local (hors conteneur) :

```bash
symfony new my_project_directory --version="7.3.x" --no-git
# ou avec Composer
composer create-project symfony/skeleton my_project_directory "7.3.*"
```

__2.__ Copier le dossier `.docker` et le `docker-compose.yml` de ce repo dans le projet. 

__3.__ Reporter les variables d'environnement dans le `.env` généré par Symfony.


__4.__ Ajouter le domaine au fichier hosts du système :

```text
127.0.0.1   project_name.dev.local
````

__5.__ Lancer MariaDB/PHPMyAdmin + Traefik si ce n’est pas déjà fait

__6.__ Lancer le conteneur Symfony :
```bash
docker compose up -d --build
```

__7.__ Accéder au projet depuis le navigateur :

```text
http://project_name.dev.local
````

## Notes
- Le projet Symfony est initialisé en local avant Docker.
- Ne contient pas NodeJS par défaut.
- Ce conteneur sert de squelette pour Symfony, compatible Traefik pour le routage HTTP et MariaDB/PMA pour la base de données.