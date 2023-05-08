local:
	cd server/bin && ./start_server.sh
up:
	docker-compose up -d --build
down:
	docker-compose down
logs:
	docker-compose logs -f -t
