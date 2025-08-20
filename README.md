# Symfony (Docker) + Traefik + MariaDB/PMA Boilerplate

Ce repo fournit un boilerplate Docker générique pour démarrer rapidement un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.  
- Permet de gérer les environnements dev/prod grâce au `Makefile` et aux fichiers d'environnement docker

>__Le projet Symfony doit être initialisé en local avant Docker.__

[Repo Traefik](https://github.com/JoAnisky/traefik)

[Repo PHPMyAdmin/MariaDB](https://github.com/JoAnisky/phpmyadmin-mariadb)


## Prérequis

- Docker & Docker Compose
- Traefik avec réseau Docker `web` (externe) `docker network create web` à créer avant de monter le conteneur Traefik
- MariaDB/PMA avec réseau Docker `mysql_network` (externe) se créé automatiquement avec le conteneur PMA/Mariadb,sinon `docker network create mysql_network`


## 📂 Structure
```text
.
├── .docker/
│   ├── Dockerfile              # Dockerfile pour Symfony
│   ├── php.ini                 # (optionnel) overrides PHP
│   ├── .env.docker.dev         # variables spécifiques Docker DEV
│   ├── .env.docker.prod        # variables spécifiques Docker PROD
│   └── traefik/
│       ├── traefik.dev.yml     # config Traefik DEV (HTTP only)
│       ├── traefik.prod.yml    # config Traefik PROD (HTTPS + Let's Encrypt)
│       └── dynamic/            # (optionnel, config additionnelle)
│           ├── middlewares.yml
│           └── tls.yml
├── docker-compose.yml
├── Makefile
├── .gitignore
├── .env                        # généré par Symfony (gitignore)
├── .env.local                  # Symfony local override (gitignore)
├── .env.prod                   # Symfony PROD (à créer, gitignore)
└── src/                        # code source Symfony
```


## 🚫 Fichiers à ignorer 
### `.gitignore`
Ces fichiers contiennent des secrets ou dépendent de l’environnement.  
Reporter ces variables dans le fichier généré par Symfony :

```text
# Docker
.docker/.env.docker.dev
.docker/.env.docker.prod
.docker/php.ini
```

### `.dockerignore` 

Le fichier `.dockerignore` permet d’exclure certains fichiers du build Docker, pour réduire la taille de l’image et éviter d’inclure des fichiers inutiles ou sensibles :
```text
.git
.gitignore
node_modules
var/*
docker-compose.override.yml

# IDE / OS
.idea
.vscode
.DS_Store
```

- Les fichiers listés ne seront pas copiés dans l’image Docker.
- Évite d’envoyer les dépendances locales, les fichiers temporaires ou les configs d’IDE dans l’image.
- Les patterns peuvent être différents du `.gitignore` : par exemple, on inclut ici `docker-compose.override.yml` qui n’est pas pertinent pour la prod.

## Fichiers Symfony à vérifier / créer

- __Par défaut Symfony fournit uniquement `.env.`__
- Il faut créer :
  - `.env.prod` → configuration spécifique à la prod
  - `.docker/.env.docker.dev`
  - `.docker/.env.docker.prod`

💡 Utiliser `.env.prod`/`.env.local` pour surcharger certains paramètres (ex : DATABASE_URL).

## Variables d’environnement Docker

`.docker/.env.docker.dev`
```dotenv
PROJECT_NAME=boilerplate_test
DOMAIN=boilerplate_test.dev.local
VOLUME_OPTION=:delegated
APP_ENV=dev
APP_DEBUG=1
UID=1000
GID=1000
```

`.docker/.env.docker.prod`
```dotenv
# Symfony PROD
PROJECT_NAME=my_symfony_app
APP_ENV=prod
APP_DEBUG=0
DOMAIN=my_symfony_app.fr
VOLUME_OPTION=
BASIC_AUTH_USERS=admin:$apr1$somehash$hashhere
LETSENCRYPT_EMAIL=admin@mydomain.fr
```
### Gestion des UID/GID et multi-environnement

Pour éviter les problèmes de permissions sur les volumes montés, configurer l’utilisateur du conteneur dans le fichier `.docker/.env.docker.dev` :
```dotenv
UID=1000
GID=1000
```
- En __dev__, ces valeurs servent à créer l’utilisateur __dev__ dans le conteneur.
- En __production__ en l'absence de valeur (dans `.env.docker.prod`), l’utilisateur par défaut sera __www-data__ .

💡 Cela garantit que les fichiers créés dans le conteneur ont les bonnes permissions sur l’hôte, et permet de travailler sans sudo ni conflit de droits.

## Variables Symfony (`.env`, `.env.prod`)

Exemple `.env.prod` (à créer) :
```dotenv
APP_ENV=prod
APP_SECRET=ChangeMeToASecureSecret
DATABASE_URL="mysql://user:password@mariadb:3306/mydb?serverVersion=10.11&charset=utf8mb4"
```

## Configuration PHP

Le fichier `php.ini` dans le dossier `.docker` se copie dans le conteneur pour surcharger les réglages PHP par défaut du conteneur Symfony.  
Exemple de réglages utiles pour le développement :

```ini
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
display_errors = On
```

## Structure du Dockerfile

Le Dockerfile est multi-stage et s’adapte automatiquement selon `APP_ENV` grâce aux commandes du `Makefile`
   
> `make up-prod` -> charge `.env.docker.prod`  
> `make up-dev` -> charge `.env.docker.dev`  

- `dev` → build pour le développement avec tous les outils et dépendances nécessaires, création de l’utilisateur `dev` avec UID/GID configurable.
- `prod` → build optimisé pour la production, uniquement les dépendances nécessaires, utilisateur `www-data`.

### Résumé des stages :

1. __Base__ : PHP, Apache, extensions PHP, Composer, Symfony CLI.
2. __Dependencies__ : installation des dépendances Symfony/Composer, cache pour accélérer les builds.
3. __Dev__ : copie du projet complet, installation des dépendances de développement.
4. __Prod__ : copie du projet complet pour www-data, optimisation des dépendances et autoloader.

💡 Avantage : un seul Dockerfile pour dev et prod, avec des images légères pour la production.

## Makefile
```makefile
# Lancer le projet Symfony en dev
up-dev:
	docker compose --env-file .docker/.env.docker.dev up -d --build

# Lancer le projet Symfony en prod
up-prod:
	docker compose --env-file .docker/.env.docker.prod up -d --build

# Stopper et nettoyer en dev
down-dev:
	docker compose --env-file .docker/.env.docker.dev down -v

# Stopper en prod
down-prod:
	docker compose --env-file .docker/.env.docker.prod down

# Afficher les logs du conteneur app en dev
logs-dev:
	docker compose --env-file .docker/.env.docker.dev logs -f app

# Afficher les logs du conteneur app en prod
logs-prod:
	docker compose --env-file .docker/.env.docker.prod logs -f app
```

## Démarrage
### 1. Créer un projet Symfony

```bash
symfony new my_project_directory --version="7.3.x" --no-git
# ou avec Composer
composer create-project symfony/skeleton my_project_directory "7.3.*"
```

### 2. Copier le boilerplate

Copier `.docker/`, `traefik/`, `docker-compose.yml` et `Makefile` dans le projet Symfony.

### 3. Configurer les variables d’environnement
Éditer `.docker/.env.docker.dev` et `.docker/.env.docker.prod`.

### 4. Ajouter le domaine au `/etc/hosts`

```text
127.0.0.1   boilerplate_test.dev.local
````

### 5. Lancer MariaDB/PHPMyAdmin + Traefik si ce n’est pas déjà fait

### 6. Démarrer Symfony

En développement : 
```bash
make up-dev
```
En production :
```bash
make up-prod
```

### 7. Accéder à l’application

- Dev → http://boilerplate_test.dev.local

- Prod → https://my_symfony_app.fr

## Notes
- `.env` Symfony reste versionné → il sert de base.
- `.env.prod` doit être créé mais non commité.
- `.docker/.env.docker.*` permettent de piloter l’infra selon l’environnement.
- Ne contient pas NodeJS par défaut. A ajouter au Dockerfile si besoin
- Compatible avec Traefik pour le routage HTTP et MariaDB/PHPMyAdmin.