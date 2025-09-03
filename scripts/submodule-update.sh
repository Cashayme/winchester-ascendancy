#!/bin/bash

# Script de mise à jour des sous-modules Git pour Winchester Ascendancy
# Met à jour tous les sous-modules vers leur dernière version

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    error "Ce script doit être exécuté depuis la racine du projet Winchester Ascendancy"
    exit 1
fi

log "🔄 Mise à jour des sous-modules Git pour Winchester Ascendancy"

# Mettre à jour tous les sous-modules
log "📥 Téléchargement des dernières versions..."
git submodule update --remote --recursive

# Afficher l'état après mise à jour
log "📊 État des sous-modules après mise à jour :"
git submodule status

log "✅ Mise à jour terminée !"

# Vérifier s'il y a des changements à commiter
if git diff --quiet; then
    log "📝 Aucun changement détecté dans les sous-modules"
else
    warn "⚠️  Des changements ont été détectés dans les sous-modules"
    warn "   Pensez à commiter ces changements :"
    warn "   git add . && git commit -m 'Update submodules'"
fi
