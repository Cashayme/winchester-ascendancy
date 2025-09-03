# 🐳 Dune Awakening - Docker Setup

Ce guide explique comment déployer l'application Dune Awakening complète avec Docker et Docker Compose.

## 📋 Prérequis

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- Ports 27017, 3000, 4000 disponibles

## 🚀 Démarrage rapide

### 1. Configuration des variables d'environnement

```bash
# Copiez le fichier d'exemple
cp env.example .env

# Éditez le fichier .env avec vos valeurs
nano .env
```

Variables requises :
```env
DISCORD_CLIENT_ID=your_discord_client_id_here
DISCORD_CLIENT_SECRET=your_discord_client_secret_here
DISCORD_BOT_TOKEN=your_discord_bot_token_here
SESSION_SECRET=your_super_secret_session_key_here
```

### 2. Construction et démarrage

```bash
# Construction et démarrage de tous les services
docker-compose up --build

# Ou en arrière-plan
docker-compose up --build -d
```

### 3. Vérification

```bash
# Vérifier que tous les services sont démarrés
docker-compose ps

# Consulter les logs
docker-compose logs

# Logs d'un service spécifique
docker-compose logs backend
docker-compose logs frontend
docker-compose logs bot
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │      Bot        │
│   (Nuxt.js)     │◄──►│  (Node.js/TS)   │◄──►│  (Discord.js)   │
│   Port: 3000    │    │   Port: 4000    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   MongoDB       │
                    │   Port: 27017   │
                    └─────────────────┘
```

## 📊 Services

### MongoDB
- **Image**: `mongo:7-jammy`
- **Port**: `27017`
- **Base de données**: `dune_awakening`
- **Utilisateur**: `admin`
- **Mot de passe**: `password123`

### Backend API
- **Port**: `4000`
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /api/chests` - Gestion des coffres
  - `GET /api/items` - Gestion des items
  - `POST /auth/discord` - Authentification Discord

### Frontend
- **Port**: `3000`
- **Framework**: Nuxt.js 3
- **UI**: Nuxt UI + Tailwind CSS

### Bot Discord
- **Framework**: Discord.js v14
- **Commandes**:
  - `/chest manage` - Gestion des coffres
  - `/item search` - Recherche d'items

## 🛠️ Commandes utiles

```bash
# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Reconstruire un service spécifique
docker-compose up --build backend

# Accéder à un conteneur
docker-compose exec backend sh
docker-compose exec mongodb mongosh

# Consulter les logs en temps réel
docker-compose logs -f

# Nettoyer les images non utilisées
docker image prune -f
```

## 🔧 Configuration avancée

### Variables d'environnement personnalisées

```bash
# Ports personnalisés
BACKEND_PORT=4001
FRONTEND_PORT=3001

# Configuration MongoDB personnalisée
MONGODB_URI=mongodb://user:pass@host:port/db

# Mode développement
NODE_ENV=development
```

### Volumes persistants

```bash
# Données MongoDB
mongodb_data:/data/db

# Logs du backend
./backend/logs:/app/logs
```

### Healthchecks

Chaque service a un healthcheck configuré :
- **MongoDB**: Test de connexion MongoDB
- **Backend**: Test HTTP sur `/health`
- **Frontend**: Test HTTP sur la page d'accueil

## 🐛 Dépannage

### Problèmes courants

#### 1. Port déjà utilisé
```bash
# Vérifier les ports utilisés
netstat -tlnp | grep -E ':(27017|3000|4000)'

# Changer les ports dans docker-compose.yml
ports:
  - "3001:3000"  # Port hôte:port conteneur
```

#### 2. Erreur de build
```bash
# Nettoyer le cache Docker
docker system prune -f

# Reconstruire sans cache
docker-compose build --no-cache
```

#### 3. Problème de mémoire
```bash
# Augmenter la mémoire Docker
# Docker Desktop: Settings > Resources > Memory
```

#### 4. Bot ne se connecte pas
```bash
# Vérifier les variables d'environnement
docker-compose exec bot env | grep DISCORD

# Consulter les logs du bot
docker-compose logs bot
```

### Logs de débogage

```bash
# Logs détaillés de tous les services
docker-compose logs -f --tail=100

# Logs avec timestamps
docker-compose logs -f -t

# Sauvegarder les logs
docker-compose logs > logs_$(date +%Y%m%d_%H%M%S).txt
```

## 🔒 Sécurité

### Variables sensibles

- **Ne commitez jamais** le fichier `.env` dans Git
- **Utilisez des mots de passe forts** pour MongoDB
- **Changez les ports** si nécessaire pour éviter les conflits

### Production

Pour un déploiement en production :
1. Utilisez des secrets Docker au lieu de variables d'environnement
2. Configurez HTTPS avec un reverse proxy (nginx, traefik)
3. Utilisez un réseau Docker sécurisé
4. Activez l'authentification MongoDB
5. Configurez les logs et la surveillance

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Documentation Nuxt.js](https://nuxt.com/docs)
- [Documentation Discord.js](https://discord.js.org/)

---

## 🚀 Prêt à déployer !

Une fois configuré, votre application sera accessible sur :
- **Frontend**: http://localhost:3000
- **API**: http://localhost:4000
- **Base de données**: localhost:27017

Bonne utilisation ! 🎮⚡
