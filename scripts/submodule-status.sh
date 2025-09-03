#!/bin/bash

# Script de vérification de l'état des sous-modules Git
# Affiche l'état détaillé de tous les sous-modules

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

info() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    error "Ce script doit être exécuté depuis la racine du projet Winchester Ascendancy"
    exit 1
fi

log "📊 Vérification de l'état des sous-modules Git"

echo "=================================================="
echo "ÉTAT DES SOUS-MODULES"
echo "=================================================="

# Afficher l'état détaillé des sous-modules
git submodule status --recursive

echo ""
echo "=================================================="
echo "DÉTAILS DES SOUS-MODULES"
echo "=================================================="

# Vérifier chaque sous-module
check_submodule() {
    local name=$1
    local path=$2
    local expected_file=$3

    echo ""
    echo "🔍 Vérification de $name ($path) :"

    if [ -d "$path" ]; then
        if [ -f "$path/$expected_file" ]; then
            echo "  ✅ Présent et configuré"
            cd "$path"

            # Afficher la branche actuelle
            if git branch --show-current >/dev/null 2>&1; then
                echo "  📋 Branche : $(git branch --show-current)"
            fi

            # Afficher le dernier commit
            echo "  🔗 Dernier commit : $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
            echo "  📅 Dernière modification : $(git log -1 --format=%cd --date=short 2>/dev/null || echo 'N/A')"

            # Vérifier s'il y a des changements locaux
            if git diff --quiet --ignore-submodules; then
                echo "  ✅ Aucun changement local"
            else
                warn "  ⚠️  Changements locaux détectés"
            fi

            cd - >/dev/null
        else
            warn "  ⚠️  Répertoire présent mais fichier $expected_file manquant"
        fi
    else
        error "  ❌ Répertoire $path non trouvé"
    fi
}

# Vérifier chaque sous-module
check_submodule "Frontend" "frontend" "package.json"
check_submodule "Backend" "backend" "package.json"
check_submodule "Bot" "bot" "package.json"

echo ""
echo "=================================================="
echo "RECOMMANDATIONS"
echo "=================================================="

# Vérifier si tous les sous-modules sont présents
missing_count=0
if [ ! -f "frontend/package.json" ]; then ((missing_count++)); fi
if [ ! -f "backend/package.json" ]; then ((missing_count++)); fi
if [ ! -f "bot/package.json" ]; then ((missing_count++)); fi

if [ $missing_count -gt 0 ]; then
    warn "⚠️  $missing_count sous-module(s) manquant(s)"
    warn "   Exécutez : ./scripts/submodule-init.sh"
else
    log "✅ Tous les sous-modules sont configurés"
fi

# Vérifier les changements locaux
if ! git diff --quiet --ignore-submodules; then
    warn "⚠️  Des changements locaux ont été détectés"
    warn "   Pensez à les commiter : git add . && git commit -m 'Update'"
fi

log "📋 Vérification terminée"
