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
