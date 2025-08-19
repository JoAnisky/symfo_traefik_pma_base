# Symfony (Docker) + Traefik + MariaDB/PMA Boilerplate

Ce repo fournit un boilerplate Docker générique pour démarrer rapidement un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.

[Repo Traefik](https://github.com/JoAnisky/traefik)

[Repo PHPMyAdmin/MariaDB](https://github.com/JoAnisky/phpmyadmin-mariadb)

## Structure

- `.docker/` : contient le Dockerfile Symfony et le fichier de config `php.ini` (OPTIONNEL)
- `docker-compose.yml` : configuration de base commune
- `.gitignore` : ignore les fichiers sensibles et générés

> ⚠️ Les fichiers `.env.dev` , `.env.prod` et `php.ini` **ne doivent pas être commités**.  
Ils contiennent les variables sensibles (mots de passe, domaines, etc.) ou spécifiques à l'environnement.

## Prérequis

- Docker & Docker Compose
- Réseau Docker `web` (externe, utilisé par Traefik)
- Réseau Docker `mysql_network` (externe, utilisé par MariaDB/PMA)

## Variables d’environnement

- `.env.dev` : utilisé en développement local
- `.env.prod` : utilisé en production
- `.env` (Symfony) : généré par `symfony new` ou `composer create-project`

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

## Makefile
```makefile
# Lancer le projet Symfony en dev
up-dev:
	cp .env.dev .env
	docker compose up -d --build

# Lancer le projet Symfony en prod
up-prod:
	cp .env.prod .env
	docker compose up -d --build

# Stopper et nettoyer (utilise le .env courant)
down:
	docker compose down -v

# Afficher les logs du conteneur app
logs:
	docker compose logs -f app
```

## Démarrage
### 1. Créer un projet Symfony

```bash
symfony new my_project_directory --version="7.3.x" --no-git
# ou avec Composer
composer create-project symfony/skeleton my_project_directory "7.3.*"
```

### 2. Copier le boilerplate

Copier les dossiers `.docker` et `traefik` + les fichiers `docker-compose.yml` et `Makefile` depuis ce repo dans le projet Symfony.

### 3. Configurer les variables d’environnement
Créer un `.env.dev` (ou `.env.prod` pour la prod).

Exemple `.env.dev` :

```dotenv
# Symfony DEV
PROJECT_NAME=appname
APP_ENV=dev
APP_DEBUG=1

DOMAIN=appname.dev.local
DATABASE_URL="mysql://root:root@mariadb:3306/appname?serverVersion=10.11&charset=utf8mb4"
VOLUME_OPTION=:delegated
```

Exemple `.env.prod` :

```dotenv
# Symfony PROD

PROJECT_NAME=my_symfony_app
APP_ENV=prod
APP_DEBUG=0
DOMAIN=my_symfony_app.fr
DATABASE_URL=mysql://user:password@mysql:3306/dbname
VOLUME_OPTION=
BASIC_AUTH_USERS=admin:$apr1$somehash$hashhere
LETSENCRYPT_EMAIL=admin@mydomain.fr
```

### 4. Ajouter le domaine au `/etc/hosts`

```text
127.0.0.1   appname.dev.local
````

### 5. Lancer MariaDB/PHPMyAdmin + Traefik si ce n’est pas déjà fait

### 6. Démarrer les services

En développement : 
```bash
make up-dev
```
En production :
```bash
make up-prod
```

### 7. Accéder à l’application

```text
http://project_name.dev.local
````

## Notes
- Le projet Symfony est initialisé en local avant Docker.
- Ne contient pas NodeJS par défaut.
- Compatible avec Traefik pour le routage HTTP et MariaDB/PHPMyAdmin.