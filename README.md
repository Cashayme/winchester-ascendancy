# 🛡️ Winchester Ascendancy

> **Gestionnaire de coffres et inventaires pour Dune Awakening**

[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)
[![Discord](https://img.shields.io/badge/Discord-Bot-purple.svg)](https://discord.com/)

Winchester Ascendancy est une suite complète d'outils pour gérer vos coffres et inventaires dans Dune Awakening. L'application offre une interface web moderne avec un thème steampunk, une API REST complète, et un bot Discord intégré.

## 📁 Structure du Projet

Ce repository principal contient l'orchestration complète du projet. Les composants sont organisés en sous-modules Git :

```
winchester-ascendancy/
├── frontend/           # Application web Nuxt.js (submodule)
├── backend/            # API REST Node.js/TypeScript (submodule)
├── bot/               # Bot Discord (submodule)
├── docker/            # Configuration Docker & Compose
├── docs/              # Documentation complète
├── scripts/           # Scripts utilitaires
└── .github/           # Workflows CI/CD
```

## 🚀 Démarrage Rapide

### Prérequis
- Docker & Docker Compose
- Node.js 18+ (pour le développement local)
- Git

### Installation

1. **Cloner le repository principal :**
```bash
git clone https://github.com/your-username/winchester-ascendancy.git
cd winchester-ascendancy
```

2. **Initialiser les sous-modules :**
```bash
git submodule update --init --recursive
```

3. **Configuration de l'environnement :**
```bash
cp env.example .env
# Éditer .env avec vos configurations
```

4. **Démarrer avec Docker :**
```bash
docker-compose up -d
```

L'application sera disponible sur :
- **Frontend** : http://localhost:3000
- **Backend API** : http://localhost:4000
- **Base de données** : MongoDB sur le port 27017

## 🏗️ Architecture

### Frontend (Nuxt.js)
- Interface web moderne avec thème steampunk
- Gestion des coffres et inventaires
- Authentification Discord OAuth2
- Responsive design avec Tailwind CSS

### Backend (Node.js/TypeScript)
- API REST complète
- Authentification et autorisation
- Gestion des données MongoDB
- Logging des activités
- Intégration Discord

### Bot Discord
- Commandes slash pour la gestion des coffres
- Authentification utilisateur
- Synchronisation temps réel

### Base de Données
- MongoDB avec authentification
- Schémas TypeScript
- Migrations automatiques

## 📚 Documentation

- [📖 Guide d'installation](./docs/INSTALL.md)
- [🏗️ Architecture](./docs/ARCHITECTURE.md)
- [🔧 Configuration](./docs/CONFIGURATION.md)
- [🚀 Déploiement](./docs/DEPLOYMENT.md)
- [🤖 API Reference](./docs/API.md)
- [🎮 Utilisation du Bot](./docs/BOT.md)

## 🛠️ Développement

### Structure des sous-modules

```bash
# Cloner un sous-module spécifique
git submodule add https://github.com/your-username/winchester-frontend.git frontend
git submodule add https://github.com/your-username/winchester-backend.git backend
git submodule add https://github.com/your-username/winchester-bot.git bot
```

### Scripts disponibles

```bash
# Gestion des sous-modules
./scripts/submodule-init.sh     # Initialiser tous les sous-modules
./scripts/submodule-update.sh   # Mettre à jour tous les sous-modules
./scripts/submodule-status.sh   # Vérifier l'état des sous-modules

# Développement
./scripts/dev-setup.sh          # Configuration complète du développement
./scripts/docker-dev.sh         # Démarrage en mode développement
./scripts/test-all.sh           # Lancer tous les tests
```

## 🔧 Technologies Utilisées

- **Frontend** : Nuxt.js 3, Vue 3, TypeScript, Tailwind CSS
- **Backend** : Node.js, Express, TypeScript, MongoDB
- **Bot** : Discord.js
- **Base de données** : MongoDB
- **Conteneurisation** : Docker & Docker Compose
- **CI/CD** : GitHub Actions
- **Qualité** : ESLint, Prettier, Husky

## 📋 Fonctionnalités

### ✅ Interface Web
- [x] Thème steampunk complet
- [x] Gestion des coffres avec drag & drop
- [x] Recherche et filtrage avancés
- [x] Authentification Discord
- [x] Interface responsive

### ✅ API Backend
- [x] Endpoints REST complets
- [x] Gestion des utilisateurs et rôles
- [x] Logging des activités
- [x] Validation des données
- [x] Gestion des erreurs

### ✅ Bot Discord
- [x] Commandes slash intégrées
- [x] Gestion des coffres
- [x] Authentification sécurisée
- [x] Messages d'aide interactifs

### ✅ Docker & Déploiement
- [x] Conteneurisation complète
- [x] Configuration multi-environnements
- [x] Health checks
- [x] Logs centralisés

## 🤝 Contribution

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](./CONTRIBUTING.md) pour les guidelines.

### Processus de développement :
1. Fork le repository principal
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](./LICENSE) pour plus de détails.

## 🙏 Remerciements

- **Dune Awakening** pour l'inspiration du thème
- **Nuxt.js** pour le framework frontend
- **Discord** pour l'API et la plateforme
- **MongoDB** pour la base de données

## 📞 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/your-username/winchester-ascendancy/issues)
- 💬 **Discussions** : [GitHub Discussions](https://github.com/your-username/winchester-ascendancy/discussions)
- 📧 **Email** : support@winchester-ascendancy.dev

---

<div align="center">
  <p><strong>Fait avec ❤️ pour la communauté Dune Awakening</strong></p>
  <p>
    <a href="#-winchester-ascendancy">Retour en haut</a> •
    <a href="./docs/INSTALL.md">Installation</a> •
    <a href="./docs/API.md">API</a>
  </p>
</div>
