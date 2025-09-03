#!/bin/bash

echo "🚀 Démarrage de la migration des données MongoDB"
echo "==============================================="

# Variables de configuration
LOCAL_MONGO_URI="mongodb://localhost:27017"
DOCKER_MONGO_URI="mongodb://admin:password123@localhost:27017"
BACKUP_DIR="./mongo_backup"

# Créer le répertoire de sauvegarde
mkdir -p $BACKUP_DIR

echo "📤 Export des données depuis MongoDB local..."

# Export des collections depuis la base locale
docker run --rm -v $(pwd)/$BACKUP_DIR:/backup --network host mongo:7-jammy \
  mongodump --uri="$LOCAL_MONGO_URI/dune" --out=/backup

if [ $? -eq 0 ]; then
    echo "✅ Export réussi depuis MongoDB local"
else
    echo "❌ Erreur lors de l'export depuis MongoDB local"
    exit 1
fi

echo "📥 Import des données vers MongoDB Docker..."

# Import vers la base Docker
docker run --rm -v $(pwd)/$BACKUP_DIR:/backup --network host mongo:7-jammy \
  mongorestore --uri="$DOCKER_MONGO_URI/dune" --drop /backup/dune

if [ $? -eq 0 ]; then
    echo "✅ Import réussi vers MongoDB Docker"
else
    echo "❌ Erreur lors de l'import vers MongoDB Docker"
    exit 1
fi

echo "🔍 Vérification des données importées..."

# Vérifier le nombre de documents dans chaque collection
echo "Collections dans MongoDB Docker après import:"
docker exec dune-mongodb mongosh -u admin -p password123 --authenticationDatabase admin dune --eval "
print('📊 Statistiques des collections:');
print('Items:', db.items.countDocuments());
print('Chests:', db.chests.countDocuments());
print('Activity Logs:', db.activity_logs.countDocuments());
print('✅ Migration terminée avec succès!');
"

# Nettoyer le répertoire de sauvegarde
echo "🧹 Nettoyage des fichiers temporaires..."
rm -rf $BACKUP_DIR

echo "🎉 Migration des données terminée !"echo "=================================================="
