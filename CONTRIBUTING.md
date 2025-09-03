# 🤝 Guide de Contribution - Winchester Ascendancy

Bienvenue dans le guide de contribution de Winchester Ascendancy ! Nous sommes ravis que vous souhaitiez contribuer à ce projet. Ce document explique comment contribuer efficacement au projet.

## 📋 Table des Matières

- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Configuration de l'Environnement](#configuration-de-lenvironnement)
- [Structure du Projet](#structure-du-projet)
- [Workflow de Développement](#workflow-de-développement)
- [Standards de Code](#standards-de-code)
- [Tests](#tests)
- [Documentation](#documentation)
- [Pull Requests](#pull-requests)
- [Signaler des Bugs](#signaler-des-bugs)
- [Demander des Fonctionnalités](#demander-des-fonctionnalités)

## 🤟 Code de Conduite

Ce projet adhère au [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). En participant, vous acceptez de respecter ce code.

### Règles de Base
- **Respect** : Traitez tout le monde avec respect et courtoisie
- **Inclusivité** : Le projet est ouvert à tous, indépendamment de l'expérience
- **Constructif** : Les retours sont toujours constructifs et utiles
- **Responsable** : Assumez la responsabilité de vos actions

## 🚀 Comment Contribuer

### Types de Contributions

1. **🐛 Corrections de bugs**
2. **✨ Nouvelles fonctionnalités**
3. **📚 Amélioration de la documentation**
4. **🎨 Améliorations UI/UX**
5. **🔧 Optimisations de performance**
6. **🧪 Tests supplémentaires**
7. **🌐 Traductions**

### Premiers Pas

1. **Fork** le repository principal
2. **Clone** votre fork localement
3. **Créez une branche** pour votre contribution
4. **Faites vos modifications**
5. **Testez vos changements**
6. **Soumettez une Pull Request**

## 🛠️ Configuration de l'Environnement

### Prérequis
- Docker & Docker Compose
- Node.js 18+ (optionnel pour le développement local)
- Git

### Installation Automatisée

```bash
# Cloner et configurer automatiquement
git clone https://github.com/your-username/winchester-ascendancy.git
cd winchester-ascendancy
./scripts/dev-setup.sh
```

### Installation Manuelle

```bash
# 1. Cloner le repository
git clone https://github.com/your-username/winchester-ascendancy.git
cd winchester-ascendancy

# 2. Initialiser les sous-modules
./scripts/submodule-init.sh

# 3. Configurer l'environnement
cp env.example .env
# Éditer .env avec vos configurations

# 4. Installer les dépendances
cd frontend && npm install
cd ../backend && npm install
cd ../bot && npm install

# 5. Démarrer l'application
docker-compose up -d
```

## 🏗️ Structure du Projet

```
winchester-ascendancy/
├── frontend/              # Application Nuxt.js (submodule)
│   ├── pages/            # Pages de l'application
│   ├── components/       # Composants réutilisables
│   ├── middleware/       # Middlewares Nuxt
│   ├── assets/           # Ressources statiques
│   └── public/           # Fichiers publics
├── backend/              # API Node.js/TypeScript (submodule)
│   ├── src/
│   │   ├── routes/       # Définition des routes API
│   │   ├── services/     # Logique métier
│   │   ├── models/       # Modèles de données
│   │   └── utils/        # Utilitaires
│   └── tests/            # Tests
├── bot/                  # Bot Discord (submodule)
│   ├── commands/         # Commandes slash
│   ├── events/           # Gestionnaires d'événements
│   └── utils/            # Utilitaires
├── docker/               # Configuration Docker
├── docs/                 # Documentation complète
├── scripts/              # Scripts utilitaires
└── .github/              # Workflows CI/CD
```

## 🔄 Workflow de Développement

### Branches

Nous utilisons le modèle Git Flow :

- **`main`** : Code de production (stable)
- **`develop`** : Développement en cours
- **`feature/*`** : Nouvelles fonctionnalités
- **`bugfix/*`** : Corrections de bugs
- **`hotfix/*`** : Corrections urgentes

### Processus de Développement

```bash
# 1. Créer une branche pour votre travail
git checkout -b feature/amazing-feature

# 2. Développer votre fonctionnalité
# Écrire du code, ajouter des tests, mettre à jour la doc

# 3. Commiter régulièrement
git add .
git commit -m "feat: add amazing feature"

# 4. Pousser votre branche
git push origin feature/amazing-feature

# 5. Créer une Pull Request
# Aller sur GitHub et créer une PR vers develop
```

### Conventions de Commit

Nous utilisons [Conventional Commits](https://conventionalcommits.org/) :

```
type(scope): description

Types disponibles :
- feat: Nouvelle fonctionnalité
- fix: Correction de bug
- docs: Documentation
- style: Formatage (pas de logique)
- refactor: Refactoring du code
- test: Tests
- chore: Maintenance
```

Exemples :
```
feat(auth): add Discord OAuth login
fix(api): resolve chest creation bug
docs(readme): update installation guide
```

## 📏 Standards de Code

### JavaScript/TypeScript

- **ESLint** : Respecter les règles définies
- **Prettier** : Formatage automatique du code
- **TypeScript** : Typage strict obligatoire
- **Imports** : Utiliser des imports absolus

```typescript
// ✅ Bon
import type { User } from '~/types/user'
import { createChest } from '~/services/chestService'

// ❌ Mauvais
import { createChest } from '../../../services/chestService'
```

### Vue.js/Nuxt

- **Composition API** : Préférée à l'Options API
- **TypeScript** : Utiliser `<script setup lang="ts">`
- **Naming** : PascalCase pour les composants
- **Props** : Définir le type et les valeurs par défaut

```vue
<script setup lang="ts">
interface Props {
  chestId: string
  isPublic?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isPublic: false
})
</script>
```

### CSS/Tailwind

- **Utility-first** : Préférer les classes Tailwind
- **Responsive** : Utiliser les breakpoints appropriés
- **Thème** : Respecter les couleurs définies

```vue
<!-- ✅ Bon -->
<div class="bg-slate-900 text-blood-400 rounded-lg p-4">

<!-- ❌ Mauvais -->
<div style="background-color: #0f172a; color: #dc2626;">
```

## 🧪 Tests

### Types de Tests

- **Unitaires** : Fonctions individuelles
- **Intégration** : Composants et APIs
- **E2E** : Parcours utilisateur complet

### Exécution des Tests

```bash
# Tests unitaires
npm run test:unit

# Tests d'intégration
npm run test:integration

# Tests E2E
npm run test:e2e

# Tous les tests
npm run test
```

### Écriture de Tests

```typescript
// Test unitaire - backend/src/services/chestService.test.ts
import { describe, it, expect } from 'vitest'
import { createChest } from './chestService'

describe('ChestService', () => {
  describe('createChest', () => {
    it('should create a chest with valid data', async () => {
      const chestData = { name: 'Test Chest', ownerId: 'user123' }
      const result = await createChest(chestData)

      expect(result).toHaveProperty('_id')
      expect(result.name).toBe('Test Chest')
    })
  })
})
```

## 📚 Documentation

### Mise à Jour de la Documentation

1. **READMEs** : Mettre à jour les READMEs des composants
2. **API Docs** : Documenter les nouveaux endpoints
3. **Guides** : Créer des guides pour les nouvelles fonctionnalités

### Standards de Documentation

- **README.md** : Présentation et installation rapide
- **docs/** : Documentation détaillée
- **JSDoc** : Commentaires pour les fonctions complexes
- **Exemples** : Code d'exemple dans les READMEs

## 🔄 Pull Requests

### Création d'une PR

1. **Titre clair** décrivant la fonctionnalité
2. **Description détaillée** :
   - Problème résolu
   - Solution implémentée
   - Breaking changes éventuels
   - Tests ajoutés
3. **Labels appropriés** :
   - `enhancement`, `bug`, `documentation`
   - `frontend`, `backend`, `bot`
   - `breaking-change` si applicable

### Checklist PR

Avant de soumettre votre PR :

- [ ] Code testé localement
- [ ] Tests ajoutés/modifiés
- [ ] Documentation mise à jour
- [ ] Linting passé
- [ ] Commits suivent les conventions
- [ ] PR vers la bonne branche (`develop`)
- [ ] Conflits de merge résolus

### Review Process

1. **Auto-review** : Vérifiez votre propre code
2. **Peer review** : Au moins un reviewer
3. **Tests CI** : Tous les tests doivent passer
4. **Merge** : Squash and merge ou rebase

## 🐛 Signaler des Bugs

### Template de Bug Report

```
**Description du bug**
Description claire du problème

**Étapes de reproduction**
1. Aller sur '...'
2. Cliquer sur '...'
3. Voir l'erreur

**Comportement attendu**
Description de ce qui devrait se passer

**Screenshots**
Si applicable

**Informations système**
- OS: [Windows/Mac/Linux]
- Navigateur: [Chrome/Firefox/Safari]
- Version: [1.0.0]

**Contexte supplémentaire**
Toute information utile
```

## 💡 Demander des Fonctionnalités

### Template de Feature Request

```
**Résumé**
Brève description de la fonctionnalité

**Problème résolu**
Quel problème cette fonctionnalité résout-elle ?

**Solution proposée**
Description de la solution souhaitée

**Alternatives envisagées**
Autres solutions possibles

**Contexte supplémentaire**
Maquettes, exemples, etc.
```

## 🎯 Bonnes Pratiques

### Performance
- **Lazy loading** pour les composants
- **Optimisation des images**
- **Cache approprié**
- **Pagination** pour les listes

### Sécurité
- **Validation des entrées**
- **Authentification sécurisée**
- **Gestion des secrets**
- **Headers de sécurité**

### Accessibilité
- **Contraste des couleurs**
- **Navigation au clavier**
- **Labels appropriés**
- **Texte alternatif**

### Maintenance
- **Code modulaire**
- **Tests automatisés**
- **Documentation à jour**
- **Logs appropriés**

## 📞 Support

Besoin d'aide ?

- **Documentation** : [docs/](./docs/)
- **Issues** : [Créer une issue](https://github.com/your-username/winchester-ascendancy/issues)
- **Discussions** : [Forum communautaire](https://github.com/your-username/winchester-ascendancy/discussions)
- **Discord** : [Serveur communautaire](https://discord.gg/winchester-ascendancy)

## 🙏 Remerciements

Merci de contribuer à Winchester Ascendancy ! Votre aide est précieuse pour la communauté.

---

<div align="center">
  <p><strong>Prêt à contribuer ?</strong></p>
  <p>
    <a href="README.md">← Retour à l'accueil</a> •
    <a href="docs/INSTALL.md">Installation</a> •
    <a href="docs/ARCHITECTURE.md">Architecture</a>
  </p>
</div>
