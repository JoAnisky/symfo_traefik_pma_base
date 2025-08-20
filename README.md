# Symfony (Docker) + Traefik + MariaDB/PMA Boilerplate

Ce repo fournit un boilerplate Docker générique pour démarrer rapidement un projet Symfony, prêt à être utilisé avec Traefik et MariaDB/PHPMyAdmin.
__Le projet Symfony est initialisé en local avant Docker.__
[Repo Traefik](https://github.com/JoAnisky/traefik)

[Repo PHPMyAdmin/MariaDB](https://github.com/JoAnisky/phpmyadmin-mariadb)

----

## Prérequis

- Docker & Docker Compose
- Traefik avec réseau Docker `web` (externe
- MariaDB/PMA avec réseau Docker `mysql_network` (externe)

--- 

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

---

## 🚫 Fichiers à ajouter au `.gitignore`
Ces fichiers contiennent des secrets ou dépendent de l’environnement :

```text
# Docker
.docker/.env.docker.dev
.docker/.env.docker.prod
.docker/php.ini

# Symfony
.env.local
.env.prod
/var/
/vendor/
/node_modules/
```

---

## Fichiers Symfony à vérifier / créer

- __Par défaut Symfony fournit uniquement `.env.`__
- Il faut créer :
  - `.env.prod` → configuration spécifique à la prod
  - `.env.dev` pour override spécifique au dev local

💡 Il n'ya pas besoin de toucher au .env Symfony global.
Il faut juste utiliser `.env.prod`/`.env.local` pour surcharger certains paramètres (ex. APP_SECRET, DATABASE_URL).

---

## Variables d’environnement Docker

`.docker/.env.docker.dev`
```dotenv
PROJECT_NAME=boilerplate_test
DOMAIN=boilerplate_test.dev.local
VOLUME_OPTION=:delegated
APP_ENV=dev
APP_DEBUG=1
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

---

## Variables Symfony (`.env`, `.env.prod`)

Exemple `.env.prod` (à créer) :
```dotenv
APP_ENV=prod
APP_SECRET=ChangeMeToASecureSecret
DATABASE_URL="mysql://user:password@mariadb:3306/mydb?serverVersion=10.11&charset=utf8mb4"
```

--- 
## Configuration PHP

Vous pouvez ajouter un fichier `php.ini` dans le dossier `.docker` pour surcharger les réglages PHP par défaut du conteneur Symfony.  
Exemple de réglages utiles pour le développement :

```ini
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
display_errors = On
```
---

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

# Logs du conteneur app
logs:
	docker compose logs -f app
```
---
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

---
## Notes
- `.env` Symfony reste versionné → il sert de base.
- `.env.prod` doit être créé mais non commité.
- `.docker/.env.docker.*` permettent de piloter l’infra selon l’environnement.
- Ne contient pas NodeJS par défaut.
- Compatible avec Traefik pour le routage HTTP et MariaDB/PHPMyAdmin.