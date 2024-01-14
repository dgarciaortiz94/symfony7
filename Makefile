OS = $(shell uname)
UID = $(shell id -u)
DOCKER_BE = symfony7-code
NAMESERVER_IP = $(shell ip address \ grep docker0)

help:
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

build:
	docker-compose up -d --remove-orphans --build
	@echo "Waiting for containers to start..."
	@while [ $$(docker ps --filter "status=running" --format "{{.Names}}" | grep -c "symfony7") -eq 0 ]; do \
		sleep 3; \
	done
	docker exec symfony7 sh -c "cd /var/www/html/symfony7 && chmod 777 -R ."
	cp ./.env.example ./.env.local
	cp ./.env.example ./.env
	docker exec symfony7 sh -c "cd /var/www/html/symfony7 && composer install"

start:
	docker-compose up -d --remove-orphans

stop:
	docker-compose down --remove-orphans

delete:
	docker rm -f symfony7

test:
	docker exec symfony7 sh -c "cd /var/www/html/symfony7 && php bin/phpunit"

cs-fix:
	docker exec symfony7 sh -c "cd /var/www/html/symfony7 && vendor/bin/php-cs-fixer fix"
	
