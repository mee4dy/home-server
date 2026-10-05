.PHONY: up down restart token uninstall status

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

token:
	@bash ./scripts/token.sh

uninstall:
	@bash ./scripts/uninstall.sh

status:
	@bash ./scripts/status.sh
