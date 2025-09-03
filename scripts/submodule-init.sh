#!/bin/bash

# Script d'initialisation des sous-modules Git pour Winchester Ascendancy
# Ce script configure tous les sous-modules nécessaires au projet

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage des messages
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    error "Ce script doit être exécuté depuis la racine du projet Winchester Ascendancy"
    error "Fichier docker-compose.yml non trouvé"
    exit 1
fi

log "🚀 Initialisation des sous-modules Git pour Winchester Ascendancy"

# Créer les répertoires des sous-modules s'ils n'existent pas
log "📁 Création des répertoires des sous-modules..."
mkdir -p frontend backend bot

# Initialiser les sous-modules Git
log "🔧 Initialisation des sous-modules Git..."
git submodule init

# Mettre à jour tous les sous-modules
log "📥 Téléchargement des sous-modules..."
git submodule update --recursive

# Vérifier l'état des sous-modules
log "✅ Vérification de l'état des sous-modules..."

if [ -f "frontend/package.json" ]; then
    log "✅ Sous-module frontend initialisé"
else
    warn "⚠️  Sous-module frontend non trouvé ou vide"
    warn "   Vous devrez l'ajouter manuellement :"
    warn "   git submodule add https://github.com/your-username/winchester-frontend.git frontend"
fi

if [ -f "backend/package.json" ]; then
    log "✅ Sous-module backend initialisé"
else
    warn "⚠️  Sous-module backend non trouvé ou vide"
    warn "   Vous devrez l'ajouter manuellement :"
    warn "   git submodule add https://github.com/your-username/winchester-backend.git backend"
fi

if [ -f "bot/package.json" ]; then
    log "✅ Sous-module bot initialisé"
else
    warn "⚠️  Sous-module bot non trouvé ou vide"
    warn "   Vous devrez l'ajouter manuellement :"
    warn "   git submodule add https://github.com/your-username/winchester-bot.git bot"
fi

# Afficher l'état des sous-modules
log "📊 État des sous-modules :"
git submodule status

log "🎉 Initialisation terminée !"
log ""
log "📝 Prochaines étapes :"
log "   1. Configurer vos variables d'environnement : cp env.example .env"
log "   2. Installer les dépendances : ./scripts/setup-dependencies.sh"
log "   3. Démarrer l'application : docker-compose up -d"
log ""
log "📖 Pour plus d'informations, consultez docs/INSTALL.md"
