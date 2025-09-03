#!/bin/bash

# Script de configuration complète du développement pour Winchester Ascendancy
# Installe toutes les dépendances et configure l'environnement

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    error "Ce script doit être exécuté depuis la racine du projet Winchester Ascendancy"
    exit 1
fi

log "🚀 Configuration complète du développement - Winchester Ascendancy"
echo ""

# Étape 1: Vérifier les prérequis
log "🔍 Vérification des prérequis système..."

# Vérifier Docker
if command -v docker &> /dev/null; then
    log "✅ Docker est installé"
else
    error "❌ Docker n'est pas installé"
    error "   Veuillez installer Docker : https://docs.docker.com/get-docker/"
    exit 1
fi

# Vérifier Docker Compose
if command -v docker-compose &> /dev/null; then
    log "✅ Docker Compose est installé"
else
    error "❌ Docker Compose n'est pas installé"
    error "   Veuillez installer Docker Compose : https://docs.docker.com/compose/install/"
    exit 1
fi

# Vérifier Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'.' -f1 | cut -d'v' -f2)
    if [ "$NODE_VERSION" -ge 18 ]; then
        log "✅ Node.js $(node --version) est installé"
    else
        warn "⚠️  Node.js $(node --version) détecté, mais la version 18+ est recommandée"
    fi
else
    warn "⚠️  Node.js n'est pas installé"
    warn "   Certaines fonctionnalités de développement local ne seront pas disponibles"
fi

# Vérifier Git
if command -v git &> /dev/null; then
    log "✅ Git est installé"
else
    error "❌ Git n'est pas installé"
    error "   Veuillez installer Git : https://git-scm.com/downloads"
    exit 1
fi

echo ""

# Étape 2: Initialiser les sous-modules
log "🔧 Initialisation des sous-modules Git..."
if [ ! -d "frontend" ] || [ ! -f "frontend/package.json" ]; then
    warn "⚠️  Sous-module frontend non trouvé"
    ./scripts/submodule-init.sh
else
    log "✅ Sous-modules déjà initialisés"
fi

echo ""

# Étape 3: Configuration des variables d'environnement
log "⚙️  Configuration des variables d'environnement..."

if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env
        warn "⚠️  Fichier .env créé à partir de env.example"
        warn "   Pensez à configurer vos variables d'environnement dans .env"
    else
        warn "⚠️  Fichier env.example non trouvé"
        warn "   Créez un fichier .env manuellement avec vos configurations"
    fi
else
    log "✅ Fichier .env déjà présent"
fi

echo ""

# Étape 4: Installation des dépendances
log "📦 Installation des dépendances..."

# Frontend
if [ -f "frontend/package.json" ]; then
    log "🔧 Installation des dépendances frontend..."
    cd frontend
    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi
    cd ..
    success "✅ Dépendances frontend installées"
else
    warn "⚠️  Sous-module frontend non disponible"
fi

# Backend
if [ -f "backend/package.json" ]; then
    log "🔧 Installation des dépendances backend..."
    cd backend
    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi
    cd ..
    success "✅ Dépendances backend installées"
else
    warn "⚠️  Sous-module backend non disponible"
fi

# Bot
if [ -f "bot/package.json" ]; then
    log "🔧 Installation des dépendances bot..."
    cd bot
    if [ -f "package-lock.json" ]; then
        npm ci
    else
        npm install
    fi
    cd ..
    success "✅ Dépendances bot installées"
else
    warn "⚠️  Sous-module bot non disponible"
fi

echo ""

# Étape 5: Configuration Docker
log "🐳 Configuration Docker..."

# Créer les volumes Docker s'ils n'existent pas
docker volume create winchester_mongo_data 2>/dev/null || true

# Préparer les images Docker
log "🏗️  Construction des images Docker..."
docker-compose build --parallel

success "✅ Images Docker construites"

echo ""

# Étape 6: Démarrage des services de base
log "🚀 Démarrage des services de base..."

# Démarrer seulement MongoDB pour les tests
docker-compose up -d mongodb

# Attendre que MongoDB soit prêt
log "⏳ Attente du démarrage de MongoDB..."
sleep 10

# Tester la connexion MongoDB
if docker-compose exec -T mongodb mongo --eval "db.adminCommand('ismaster')" &>/dev/null; then
    success "✅ MongoDB est opérationnel"
else
    warn "⚠️  MongoDB semble ne pas répondre correctement"
    warn "   Vérifiez les logs : docker-compose logs mongodb"
fi

echo ""

# Étape 7: Résumé et instructions finales
success "🎉 Configuration du développement terminée !"
echo ""
echo "=================================================="
echo "📋 RÉSUMÉ DE LA CONFIGURATION"
echo "=================================================="
echo ""
echo "✅ Prérequis vérifiés"
echo "✅ Sous-modules initialisés"
echo "✅ Variables d'environnement configurées"
echo "✅ Dépendances installées"
echo "✅ Images Docker construites"
echo "✅ Services de base démarrés"
echo ""
echo "=================================================="
echo "🚀 COMMANDES DISPONIBLES"
echo "=================================================="
echo ""
echo "Démarrer l'application complète :"
echo "  docker-compose up -d"
echo ""
echo "Démarrer en mode développement :"
echo "  ./scripts/docker-dev.sh"
echo ""
echo "Arrêter tous les services :"
echo "  docker-compose down"
echo ""
echo "Voir les logs :"
echo "  docker-compose logs -f [service-name]"
echo ""
echo "=================================================="
echo "🌐 ACCÈS AUX SERVICES"
echo "=================================================="
echo ""
echo "Frontend : http://localhost:3000"
echo "Backend  : http://localhost:4000"
echo "API Docs : http://localhost:4000/api/docs"
echo "MongoDB  : localhost:27017"
echo ""
echo "=================================================="
echo "📚 PROCHAINES ÉTAPES"
echo "=================================================="
echo ""
echo "1. Configurez vos applications Discord :"
echo "   https://discord.com/developers/applications"
echo ""
echo "2. Éditez le fichier .env avec vos tokens"
echo ""
echo "3. Démarrez l'application : docker-compose up -d"
echo ""
echo "4. Accédez à http://localhost:3000"
echo ""
echo "Pour plus d'informations, consultez docs/INSTALL.md"
