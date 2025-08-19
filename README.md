# Symfony (Docker) + Traefik + MariaDB/PMA Boilerplate

Ce repo fournit un boilerplate Docker générique pour démarrer rapidement un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.

[Repo Traefik](https://github.com/JoAnisky/traefik)

[Repo PHPMyAdmin/MariaDB](https://github.com/JoAnisky/phpmyadmin-mariadb)

## Structure

- `.docker/` : contient le Dockerfile Symfony et le fichier de config `php.ini`
- `docker-compose.yml` : configuration de base commune
- `docker-compose.override.yml` : override pour l’environnement local
- `docker-compose.prod.yml` : override pour l’environnement de production
- `.gitignore` : ignore les fichiers sensibles et générés

> ⚠️ Les fichiers `.env.docker.local` , `.env.docker.prod` et `php.ini` **ne doivent pas être commités**.  
Ils contiennent les variables sensibles (mots de passe, domaines, etc.) ou spécifiques à l'environnement.

## Prérequis

- Docker & Docker Compose
- Réseau Docker `web` (externe, utilisé par Traefik)
- Réseau Docker `mysql_network` (externe, utilisé par MariaDB/PMA)

## Variables d’environnement

- `.env.docker.local` : utilisé en développement local
- `.env.docker.prod` : utilisé en production
- `.env` (Symfony) : généré par `symfony new` ou `composer create-project`

Exemple `.env.docker.local` :

```env
PROJECT_NAME=project_name
DOMAIN=project_name.dev.local

APP_ENV=dev
APP_DEBUG=1
DATABASE_URL="mysql://root:root@mariadb:3306/project_name?serverVersion=10.11&charset=utf8mb4"

MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=project_name
MYSQL_USER=project_user
MYSQL_PASSWORD=project_pass
```
## Configuration PHP

Vous pouvez ajouter un fichier `php.ini` dans le dossier `.docker` pour surcharger les réglages PHP par défaut du conteneur Symfony.  
Exemple de réglages utiles pour le développement :

```ini
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
display_errors = On
```

## Services
- app : conteneur Symfony
- mariadb : conteneur MariaDB
- phpmyadmin : conteneur PHPMyAdmin
- traefik : reverse proxy

## Démarrage
### 1. Créer un projet Symfony

```bash
symfony new my_project_directory --version="7.3.x" --no-git
# ou avec Composer
composer create-project symfony/skeleton my_project_directory "7.3.*"
```

### 2. Copier le boilerplate

Copier le dossier `.docker` + les fichiers `docker-compose.*.yml` depuis ce repo dans le projet Symfony.

### 3. Configurer les variables d’environnement
Créer un `.env.docker.local` (ou `.env.docker.prod` en prod).

### 4. Ajouter le domaine au `/etc/hosts`

```text
127.0.0.1   project_name.dev.local
````

### 5. Lancer MariaDB/PHPMyAdmin + Traefik si ce n’est pas déjà fait

### 6. Démarrer les services
Local : 
```bash
docker compose --env-file .env.docker.local up -d --build
```
Production :
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.docker.prod up -d --build
```

### 7. Accéder à l’application

```text
http://project_name.dev.local
````

## Notes
- Le projet Symfony est initialisé en local avant Docker.
- Ne contient pas NodeJS par défaut.
- Compatible avec Traefik pour le routage HTTP et MariaDB/PHPMyAdmin.