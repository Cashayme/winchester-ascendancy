#!/bin/bash

# Docker Helper Script for Dune Awakening
# Usage: ./docker-helper.sh [command]

set -e

PROJECT_NAME="dune-awakening"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to check if .env file exists
check_env() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        print_info "Copy env.example to .env and configure your environment variables"
        print_info "cp env.example .env"
        exit 1
    fi
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running or not accessible"
        exit 1
    fi
}

# Function to wait for services to be healthy
wait_for_services() {
    print_info "Waiting for services to be healthy..."

    # Wait for MongoDB
    print_info "Waiting for MongoDB..."
    docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1
    while [ $? -ne 0 ]; do
        sleep 2
        docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1
    done
    print_status "MongoDB is ready!"

    # Wait for Backend
    print_info "Waiting for Backend..."
    while ! curl -f http://localhost:4000/health >/dev/null 2>&1; do
        sleep 2
    done
    print_status "Backend is ready!"

    # Wait for Frontend
    print_info "Waiting for Frontend..."
    while ! curl -f http://localhost:3000 >/dev/null 2>&1; do
        sleep 2
    done
    print_status "Frontend is ready!"

    print_status "All services are ready! 🎉"
}

# Main command handling
case "${1:-help}" in
    "start")
        print_info "Starting Dune Awakening..."
        check_env
        check_docker
        docker-compose up --build -d
        wait_for_services
        print_status "Application started successfully!"
        print_info "Frontend: http://localhost:3000"
        print_info "API: http://localhost:4000"
        print_info "MongoDB: localhost:27017"
        ;;

    "stop")
        print_info "Stopping Dune Awakening..."
        docker-compose down
        print_status "Application stopped!"
        ;;

    "restart")
        print_info "Restarting Dune Awakening..."
        docker-compose restart
        wait_for_services
        print_status "Application restarted!"
        ;;

    "logs")
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f
        fi
        ;;

    "status")
        docker-compose ps
        ;;

    "clean")
        print_warning "This will remove all containers, volumes, and images"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v --remove-orphans
            docker image prune -f
            docker volume prune -f
            print_status "Cleanup completed!"
        fi
        ;;

    "rebuild")
        print_info "Rebuilding all services..."
        check_env
        check_docker
        docker-compose down
        docker-compose up --build -d
        wait_for_services
        print_status "Rebuild completed!"
        ;;

    "shell")
        if [ -n "$2" ]; then
            docker-compose exec "$2" sh
        else
            echo "Usage: $0 shell <service>"
            echo "Available services: backend, frontend, bot, mongodb"
        fi
        ;;

    "db")
        print_info "Connecting to MongoDB..."
        docker-compose exec mongodb mongosh -u admin -p password123 dune_awakening
        ;;

    "backup")
        print_info "Creating database backup..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_DIR="./backups"
        mkdir -p "$BACKUP_DIR"

        docker-compose exec mongodb mongodump \
            --username admin \
            --password password123 \
            --db dune_awakening \
            --out "/backup"

        docker cp "$(docker-compose ps -q mongodb)":/backup/. "$BACKUP_DIR/backup_$TIMESTAMP"
        docker-compose exec mongodb rm -rf /backup

        print_status "Backup created: $BACKUP_DIR/backup_$TIMESTAMP"
        ;;

    "help"|*)
        echo "Dune Awakening Docker Helper"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  start     Start all services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  logs      Show logs (use 'logs <service>' for specific service)"
        echo "  status    Show status of all services"
        echo "  clean     Remove all containers, volumes, and images"
        echo "  rebuild   Rebuild all services"
        echo "  shell     Open shell in service (shell <service>)"
        echo "  db        Connect to MongoDB shell"
        echo "  backup    Create database backup"
        echo "  help      Show this help"
        echo ""
        echo "Services: backend, frontend, bot, mongodb"
        ;;
esac
