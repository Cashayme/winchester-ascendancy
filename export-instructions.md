# 📤 Instructions pour exporter les données MongoDB locales

## Méthode 1: Via MongoDB Compass (Recommandé)

1. **Ouvrez MongoDB Compass**
2. **Connectez-vous à votre base MongoDB locale** (localhost:27017)
3. **Sélectionnez la base de données `dune`**
4. **Pour chaque collection**, faites un clic droit et sélectionnez "Export Collection":
   - `items` → Exporter en JSON
   - `chests` → Exporter en JSON
   - `activity_logs` → Exporter en JSON

## Méthode 2: Via MongoDB Shell

Si vous avez accès au shell MongoDB, exécutez ces commandes:

```bash
# Se connecter à MongoDB local
mongosh localhost:27017/dune

# Exporter les collections
mongoexport --db=dune --collection=items --out=items.json --jsonArray
mongoexport --db=dune --collection=chests --out=chests.json --jsonArray
mongoexport --db=dune --collection=activity_logs --out=activity_logs.json --jsonArray
```

## Méthode 3: Via Studio 3T

1. Connectez-vous à votre base locale
2. Clic droit sur chaque collection
3. "Export" → "As JSON"

## 📥 Une fois les fichiers exportés:

Placez les fichiers JSON (`items.json`, `chests.json`, `activity_logs.json`) dans ce dossier, puis exécutez:

```powershell
.\import-json-data.ps1
```

## 🔧 Si vous avez des problèmes d'authentification:

Si votre MongoDB local nécessite une authentification, utilisez:

```bash
mongoexport --username=your_username --password=your_password --authenticationDatabase=admin --db=dune --collection=items --out=items.json --jsonArray
```
