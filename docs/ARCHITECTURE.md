# 🏗️ Architecture - Winchester Ascendancy

## Vue d'Ensemble

Winchester Ascendancy est une application distribuée composée de plusieurs services indépendants qui communiquent entre eux via des APIs REST et WebSocket. L'architecture suit les principes des microservices avec une séparation claire des responsabilités.

## 🏛️ Architecture Générale

```
┌─────────────────────────────────────────────────────────────────┐
│                    Winchester Ascendancy                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 Frontend (Nuxt.js)                     │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │    Interface Utilisateur (SPA)                  │   │   │
│  │  │  • Gestion des coffres                          │   │   │
│  │  │  • Recherche d'items                            │   │   │
│  │  │  • Authentification Discord                     │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   │ HTTP/HTTPS
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Backend (Node.js/TypeScript)                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 API REST                                │   │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │  Routes:                                        │   │   │
│  │  │  • /api/auth    - Authentification              │   │   │
│  │  │  • /api/chests  - Gestion des coffres           │   │   │
│  │  │  • /api/items   - Catalogue d'items             │   │   │
│  │  │  • /api/logs    - Journalisation                │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │  Services:                                       │   │   │
│  │  │  • AuthService   - Gestion auth                 │   │   │
│  │  │  • ChestService  - Logique coffres              │   │   │
│  │  │  • ItemService   - Gestion items                │   │   │
│  │  │  • LogService    - Journalisation               │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   │ MongoDB Protocol
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Base de Données (MongoDB)                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Collections:                                          │   │
│  │  • users      - Utilisateurs Discord                  │   │
│  │  • chests     - Coffres et inventaires                │   │
│  │  • items      - Catalogue d'items                     │   │
│  │  • logs       - Journal des activités                 │   │
│  │  • sessions   - Sessions utilisateur                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Discord API
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Bot Discord (Discord.js)                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Commandes Slash:                                      │   │
│  │  • /chest create   - Créer un coffre                  │   │
│  │  • /chest add      - Ajouter un item                  │   │
│  │  • /chest list     - Lister les coffres               │   │
│  │  • /item search    - Rechercher des items             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🗂️ Structure Détaillée des Composants

### Frontend (Nuxt.js 3)

```
frontend/
├── pages/              # Pages de l'application
│   ├── index.vue       # Redirection vers /chests
│   ├── chests.vue      # Gestion principale des coffres
│   ├── login.vue       # Authentification Discord
│   └── logs.vue        # Consultation des logs
├── components/         # Composants réutilisables
│   ├── AppHeader.vue   # En-tête de navigation
│   ├── ChestPanel.vue  # Panneau de coffre
│   ├── InventoryGrid.vue # Grille d'inventaire
│   ├── SearchPanel.vue # Panneau de recherche
│   └── ...
├── middleware/         # Middlewares Nuxt
│   └── auth.ts         # Protection des routes
├── composables/        # Logique réutilisable
├── assets/             # Ressources statiques
└── public/             # Fichiers publics
```

#### Fonctionnalités Frontend
- **Interface réactive** avec Vue 3 Composition API
- **Thème steampunk** personnalisé avec Tailwind CSS
- **Authentification** via Discord OAuth2
- **Gestion d'état** avec Pinia (optionnel)
- **Internationalisation** prête (i18n)

### Backend (Node.js/TypeScript)

```
backend/
├── src/
│   ├── routes/         # Définition des routes API
│   │   ├── auth.ts     # Authentification
│   │   ├── chests.ts   # Gestion des coffres
│   │   ├── items.ts    # Catalogue d'items
│   │   └── logs.ts     # Logs d'activité
│   ├── services/       # Logique métier
│   │   ├── authService.ts
│   │   ├── chestService.ts
│   │   ├── itemService.ts
│   │   └── logService.ts
│   ├── middleware/     # Middlewares Express
│   │   ├── auth.ts     # Authentification JWT
│   │   ├── roleCheck.ts # Vérification des rôles
│   │   └── cors.ts     # Configuration CORS
│   ├── models/         # Modèles de données
│   │   ├── User.ts     # Utilisateur Discord
│   │   ├── Chest.ts    # Modèle de coffre
│   │   ├── Item.ts     # Modèle d'item
│   │   └── ActivityLog.ts # Log d'activité
│   ├── config/         # Configuration
│   │   ├── database.ts # Configuration MongoDB
│   │   └── discord.ts  # Configuration Discord
│   ├── utils/          # Utilitaires
│   └── types/          # Types TypeScript
├── tests/              # Tests unitaires/intégration
├── scripts/            # Scripts utilitaires
└── Dockerfile          # Configuration Docker
```

#### API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `GET` | `/health` | État de santé du service |
| `POST` | `/auth/discord` | Initiation OAuth Discord |
| `GET` | `/auth/discord/callback` | Callback OAuth Discord |
| `GET` | `/api/chests` | Liste des coffres |
| `POST` | `/api/chests` | Créer un coffre |
| `PUT` | `/api/chests/:id` | Modifier un coffre |
| `DELETE` | `/api/chests/:id` | Supprimer un coffre |
| `GET` | `/api/items` | Catalogue d'items |
| `GET` | `/api/items/:id` | Détails d'un item |
| `GET` | `/api/logs` | Logs d'activité |
| `POST` | `/api/logs` | Créer un log |

### Bot Discord

```
bot/
├── index.js           # Point d'entrée principal
├── commands/          # Commandes slash
│   ├── chest.js       # Commandes de gestion des coffres
│   └── item.js        # Commandes de recherche d'items
├── events/            # Gestionnaires d'événements
├── utils/             # Utilitaires
├── config/            # Configuration
└── Dockerfile         # Configuration Docker
```

#### Commandes Disponibles

| Commande | Description | Paramètres |
|----------|-------------|------------|
| `/chest create` | Créer un nouveau coffre | `name`, `description` |
| `/chest add` | Ajouter un item | `chest_id`, `item_id`, `quantity` |
| `/chest remove` | Retirer un item | `chest_id`, `item_id`, `quantity` |
| `/chest list` | Lister les coffres | `user_id` (optionnel) |
| `/item search` | Rechercher des items | `query`, `category` |
| `/help` | Afficher l'aide | - |

### Base de Données (MongoDB)

#### Collections Principales

```javascript
// Collection: users
{
  _id: ObjectId,
  discordId: String,
  username: String,
  discriminator: String,
  avatar: String,
  roles: [String],
  createdAt: Date,
  updatedAt: Date
}

// Collection: chests
{
  _id: ObjectId,
  name: String,
  description: String,
  owner: ObjectId, // Référence vers users
  items: [{
    itemId: String,
    itemMongoId: ObjectId, // Référence vers items
    quantity: Number,
    slotIndex: Number,
    addedAt: Date
  }],
  maxSlots: Number,
  isPublic: Boolean,
  createdAt: Date,
  updatedAt: Date
}

// Collection: items
{
  _id: ObjectId,
  name: String,
  description: String,
  category: String,
  rarity: String,
  imageUrl: String,
  gameData: Object, // Données spécifiques au jeu
  createdAt: Date,
  updatedAt: Date
}

// Collection: activity_logs
{
  _id: ObjectId,
  userId: ObjectId, // Référence vers users
  action: String, // 'create_chest', 'add_item', etc.
  targetType: String, // 'chest', 'item'
  targetId: ObjectId,
  details: Object,
  ipAddress: String,
  userAgent: String,
  createdAt: Date
}
```

## 🔄 Flux de Données

### Authentification Utilisateur

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant F as Frontend
    participant B as Backend
    participant D as Discord
    participant DB as Database

    U->>F: Clic "Se connecter"
    F->>B: GET /auth/discord
    B->>D: Redirection OAuth
    D->>U: Formulaire Discord
    U->>D: Authentification
    D->>B: Callback avec code
    B->>D: Échange code ↔ token
    B->>DB: Créer/Mettre à jour user
    B->>F: Redirection avec JWT
    F->>U: Accès à l'application
```

### Gestion des Coffres

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant F as Frontend
    participant B as Backend
    participant DB as Database

    U->>F: Action sur coffre
    F->>B: POST /api/chests
    B->>DB: Validation & Sauvegarde
    DB->>B: Confirmation
    B->>F: Réponse avec données
    F->>U: Mise à jour interface

    Note over B,DB: Logging automatique de l'activité
```

## 🐳 Configuration Docker

### Services Définis

```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "4000:4000"
    depends_on:
      - mongodb
    environment:
      - NODE_ENV=production

  bot:
    build: ./bot
    depends_on:
      - backend
    environment:
      - NODE_ENV=production

  mongodb:
    image: mongo:7.0
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
      - ./docker/mongo-init:/docker-entrypoint-initdb.d

volumes:
  mongo_data:
```

### Variables d'Environnement

```env
# Application
NODE_ENV=production
PORT=4000

# Database
MONGODB_URI=mongodb://winchester:password@mongodb:27017/winchester?authSource=admin

# Discord
DISCORD_CLIENT_ID=your_client_id
DISCORD_CLIENT_SECRET=your_client_secret
DISCORD_BOT_TOKEN=your_bot_token

# Security
JWT_SECRET=your_jwt_secret
SESSION_SECRET=your_session_secret
```

## 🔒 Sécurité

### Mesures de Sécurité Implémentées

- **Authentification JWT** avec expiration
- **Validation des entrées** avec Joi/Zod
- **Rate limiting** pour prévenir les abus
- **CORS configuré** pour les origines autorisées
- **Logs d'activité** complets pour audit
- **Validation des rôles** Discord
- **Protection CSRF** sur les formulaires
- **Headers de sécurité** (HSTS, CSP, etc.)

### Bonnes Pratiques

- **Principe du moindre privilège** pour les rôles
- **Chiffrement** des données sensibles
- **Sanitisation** des entrées utilisateur
- **Gestion des erreurs** sécurisée
- **Mises à jour régulières** des dépendances

## 📈 Performance

### Optimisations Implémentées

- **Indexation MongoDB** sur les champs fréquemment interrogés
- **Cache Redis** pour les données fréquemment accédées (optionnel)
- **Compression Gzip** des réponses API
- **Lazy loading** des images et composants
- **Pagination** pour les listes volumineuses
- **CDN** pour les ressources statiques

### Métriques Monitorées

- **Temps de réponse** des APIs
- **Utilisation CPU/Mémoire** des conteneurs
- **Nombre de connexions** actives
- **Taux d'erreur** par endpoint
- **Performance des requêtes** MongoDB

## 🔄 Déploiement et CI/CD

### Pipeline CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [ main ]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Build application
        run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          echo "Déploiement en production..."
```

### Stratégies de Déploiement

- **Blue/Green Deployment** pour zéro downtime
- **Rolling updates** pour les mises à jour progressives
- **Health checks** avant de basculer le trafic
- **Rollback automatique** en cas d'échec

## 📊 Monitoring et Observabilité

### Outils de Monitoring

- **Logs centralisés** avec Winston
- **Métriques applicatives** avec Prometheus
- **Dashboard Grafana** pour la visualisation
- **Alertes automatiques** sur Discord/Slack

### Points de Monitoring

- **Santé des services** (health checks)
- **Performance base de données** (slow queries)
- **Utilisation ressources** (CPU, RAM, disque)
- **Taux d'erreur** par service
- **Temps de réponse** des APIs

## 🎯 Évolutivité

### Architecture Horizontalement Scalable

- **Stateless services** pour faciliter la scalabilité
- **Load balancing** avec Nginx/Traefik
- **Cache distribué** avec Redis Cluster
- **Base de données** avec réplication MongoDB

### Optimisations Futures

- **Microservices additionnels** (service de notifications, etc.)
- **Edge computing** avec Cloudflare Workers
- **Machine Learning** pour recommandations d'items
- **Real-time features** avec WebSockets/Socket.io

---

<div align="center">
  <p><strong>Comprendre l'architecture ?</strong></p>
  <p>
    <a href="../README.md">← Retour à l'accueil</a> •
    <a href="./INSTALL.md">Installation</a> •
    <a href="./CONFIGURATION.md">Configuration</a>
  </p>
</div>
