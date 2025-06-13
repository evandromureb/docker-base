up:
	docker compose up -d

upb:
	docker compose up -d --build

down:
	docker compose down

downv:
	docker compose down -v

build:
	docker compose build

bash:
	docker compose exec php bash

composer-install:
	docker compose exec php composer install

npm-install:
	docker compose exec php npm install

migrate:
	docker compose exec php php artisan migrate

migrate-fresh:
	docker compose exec php php artisan migrate:fresh --seed

seed:
	docker compose exec php php artisan db:seed

logs:
	docker compose logs -f

permission:
	sudo chmod -R 777 ./
