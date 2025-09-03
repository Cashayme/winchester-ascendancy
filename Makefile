# Makefile for Dune Awakening Docker Management

.PHONY: help start stop restart logs status clean rebuild shell db backup

# Default target
help:
	@echo "Dune Awakening Docker Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make start     - Start all services"
	@echo "  make stop      - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make logs      - Show all logs"
	@echo "  make status    - Show status of services"
	@echo "  make clean     - Remove containers, volumes and images"
	@echo "  make rebuild   - Rebuild all services"
	@echo "  make shell     - Open shell (make shell SERVICE=backend)"
	@echo "  make db        - Connect to MongoDB"
	@echo "  make backup    - Create database backup"

# Check if .env exists
check-env:
	@if not exist ".env" ( \
		echo "Error: .env file not found!" && \
		echo "Copy env.example to .env and configure your variables" && \
		exit 1 \
	)

# Start all services
start: check-env
	docker-compose up --build -d
	@echo "Waiting for services to be ready..."
	@timeout /t 10 /nobreak >nul
	docker-compose ps

# Stop all services
stop:
	docker-compose down

# Restart all services
restart:
	docker-compose restart

# Show logs
logs:
	@if "$(SERVICE)"=="" ( \
		docker-compose logs -f \
	) else ( \
		docker-compose logs -f $(SERVICE) \
	)

# Show status
status:
	docker-compose ps

# Clean everything
clean:
	@echo "This will remove all containers, volumes, and images"
	@choice /c YN /m "Are you sure? (Y/N): "
	@if %errorlevel% equ 1 ( \
		docker-compose down -v --remove-orphans && \
		docker image prune -f && \
		docker volume prune -f \
	)

# Rebuild all services
rebuild: check-env
	docker-compose down
	docker-compose up --build -d

# Open shell in service
shell:
	@if "$(SERVICE)"=="" ( \
		echo "Usage: make shell SERVICE=<service>" && \
		echo "Available services: backend, frontend, bot, mongodb" \
	) else ( \
		docker-compose exec $(SERVICE) sh \
	)

# Connect to MongoDB
db:
	docker-compose exec mongodb mongosh -u admin -p password123 dune_awakening

# Create backup
backup:
	@echo "Creating database backup..."
	@if not exist "backups" mkdir backups
	@for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
	@for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
	@set TIMESTAMP=%DATE%_%TIME: =0%
	docker-compose exec mongodb mongodump --username admin --password password123 --db dune_awakening --out /backup
	docker cp $$(docker-compose ps -q mongodb):/backup/. ./backups/backup_%TIMESTAMP%
	docker-compose exec mongodb rm -rf /backup
	@echo "Backup created: ./backups/backup_%TIMESTAMP%"
