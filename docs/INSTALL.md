# 📖 Guide d'Installation - Winchester Ascendancy

## Prérequis Système

Avant de commencer l'installation, assurez-vous que votre système dispose des éléments suivants :

### Logiciels Requis
- **Docker** 20.10+ et **Docker Compose** 2.0+
- **Node.js** 18+ (uniquement pour le développement local)
- **Git** 2.30+
- **PowerShell** ou **Bash** (pour les scripts)

### Ressources Matérielles
- **RAM** : Minimum 4GB, recommandé 8GB+
- **Disque** : 5GB d'espace libre
- **CPU** : Architecture x64/AMD64

## 🚀 Installation Rapide (Docker)

### 1. Clonage du Repository

```bash
# Cloner le repository principal
git clone https://github.com/your-username/winchester-ascendancy.git
cd winchester-ascendancy

# Initialiser les sous-modules
git submodule update --init --recursive
```

### 2. Configuration de l'Environnement

```bash
# Copier le fichier d'exemple d'environnement
cp env.example .env

# Éditer le fichier .env avec vos valeurs
nano .env  # ou code .env sur Windows
```

**Variables d'environnement importantes :**
```env
# Discord Configuration
DISCORD_CLIENT_ID=your_discord_client_id
DISCORD_CLIENT_SECRET=your_discord_client_secret
DISCORD_BOT_TOKEN=your_discord_bot_token

# Database
MONGODB_URI=mongodb://winchester:password@localhost:27017/winchester?authSource=admin

# Application
NODE_ENV=production
JWT_SECRET=your_jwt_secret_here
```

### 3. Démarrage de l'Application

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier que tout fonctionne
docker-compose ps
```

### 4. Accès aux Services

Une fois démarré, l'application sera accessible sur :
- **Frontend** : http://localhost:3000
- **Backend API** : http://localhost:4000
- **Documentation API** : http://localhost:4000/api/docs
- **Base de données** : localhost:27017 (MongoDB)

## 🛠️ Installation pour le Développement

### Configuration des Sous-modules

```bash
# Initialiser tous les sous-modules
./scripts/submodule-init.sh

# Ou manuellement pour chaque composant
git submodule add https://github.com/your-username/winchester-frontend.git frontend
git submodule add https://github.com/your-username/winchester-backend.git backend
git submodule add https://github.com/your-username/winchester-bot.git bot
```

### Installation des Dépendances

```bash
# Frontend
cd frontend
npm install

# Backend
cd ../backend
npm install

# Bot
cd ../bot
npm install
```

### Démarrage en Mode Développement

```bash
# Démarrer tous les services
./scripts/docker-dev.sh

# Ou manuellement :
docker-compose -f docker-compose.dev.yml up -d

# Puis démarrer les applications locales
cd frontend && npm run dev
cd ../backend && npm run dev
cd ../bot && npm run dev
```

## 🔧 Configuration Avancée

### Configuration Discord

1. **Créer une application Discord** sur [Discord Developer Portal](https://discord.com/developers/applications)
2. **Ajouter un bot** à votre application
3. **Configurer les permissions** du bot :
   - `bot` (pour les commandes slash)
   - `applications.commands` (pour les commandes slash globales)
4. **Ajouter les URLs de redirection** :
   - `http://localhost:4000/auth/discord/callback` (développement)
   - `https://your-domain.com/auth/discord/callback` (production)

### Configuration MongoDB

```javascript
// Configuration par défaut dans docker/mongo-init/init-mongo.js
db.createUser({
  user: 'winchester',
  pwd: 'password',
  roles: [
    {
      role: 'readWrite',
      db: 'winchester'
    }
  ]
});
```

### Variables d'Environnement Détaillées

```env
# === APPLICATION ===
NODE_ENV=production
PORT=4000
API_BASE_URL=http://localhost:4000

# === DATABASE ===
MONGODB_URI=mongodb://winchester:password@localhost:27017/winchester?authSource=admin
MONGODB_TEST_URI=mongodb://winchester:password@localhost:27017/winchester_test?authSource=admin

# === DISCORD ===
DISCORD_CLIENT_ID=your_client_id
DISCORD_CLIENT_SECRET=your_client_secret
DISCORD_BOT_TOKEN=your_bot_token
DISCORD_GUILD_ID=your_guild_id  # Pour les commandes slash en développement

# === SECURITY ===
JWT_SECRET=your_super_secure_jwt_secret_min_32_chars
SESSION_SECRET=your_session_secret
BCRYPT_ROUNDS=12

# === LOGGING ===
LOG_LEVEL=info
LOG_FILE=logs/app.log

# === CORS ===
CORS_ORIGIN=http://localhost:3000,https://your-domain.com

# === RATE LIMITING ===
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# === FILE UPLOAD ===
MAX_FILE_SIZE=10485760  # 10MB
UPLOAD_PATH=./uploads

# === CACHE ===
REDIS_URL=redis://localhost:6379  # Optionnel
CACHE_TTL=3600  # 1 heure
```

## 🐛 Dépannage

### Problèmes Courants

#### Le conteneur ne démarre pas
```bash
# Vérifier les logs
docker-compose logs [service-name]

# Redémarrer les services
docker-compose restart

# Reconstruire les images
docker-compose build --no-cache
```

#### Erreur de connexion à MongoDB
```bash
# Vérifier que MongoDB est démarré
docker-compose ps mongodb

# Vérifier les logs MongoDB
docker-compose logs mongodb

# Test de connexion
docker-compose exec backend npm run test:db
```

#### Le bot Discord ne répond pas
```bash
# Vérifier les permissions du bot
# S'assurer que le bot a accès au serveur
# Vérifier le token dans les variables d'environnement

# Logs du bot
docker-compose logs bot
```

#### Erreur 502 Bad Gateway
```bash
# Le backend ne répond pas
docker-compose logs backend

# Vérifier la santé du backend
curl http://localhost:4000/health

# Redémarrer le backend
docker-compose restart backend
```

### Commandes Utiles

```bash
# Arrêter tous les services
docker-compose down

# Supprimer les volumes (⚠️ supprime les données)
docker-compose down -v

# Voir l'utilisation des ressources
docker stats

# Accéder à un conteneur
docker-compose exec backend sh
docker-compose exec mongodb mongo

# Nettoyer les images non utilisées
docker image prune -f
```

## 🔄 Mise à Jour

### Mise à jour des Sous-modules

```bash
# Mettre à jour tous les sous-modules
git submodule update --remote

# Ou utiliser le script
./scripts/submodule-update.sh
```

### Migration de Base de Données

```bash
# Créer un backup avant la migration
./scripts/backup-db.sh

# Exécuter les migrations
docker-compose exec backend npm run migrate

# Restaurer en cas de problème
./scripts/restore-db.sh
```

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** : `docker-compose logs`
2. **Consultez la documentation** : [Dépannage](./TROUBLESHOOTING.md)
3. **Créez une issue** : [GitHub Issues](https://github.com/your-username/winchester-ascendancy/issues)
4. **Rejoignez la communauté** : [Discord Server](https://discord.gg/winchester-ascendancy)

## 🎯 Prochaines Étapes

Une fois l'installation terminée :

1. [Configurer votre serveur Discord](./BOT.md)
2. [Personnaliser l'interface](./CONFIGURATION.md)
3. [Déployer en production](./DEPLOYMENT.md)
4. [Ajouter des fonctionnalités](./CONTRIBUTING.md)

---

<div align="center">
  <p><strong>Installation terminée ?</strong></p>
  <p>
    <a href="../README.md">← Retour à l'accueil</a> •
    <a href="./ARCHITECTURE.md">Architecture</a> •
    <a href="./CONFIGURATION.md">Configuration</a>
  </p>
</div>
