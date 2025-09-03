@echo off
echo 🚀 Démarrage de la migration des données MongoDB
echo ===============================================

REM Variables de configuration
set LOCAL_MONGO_URI=mongodb://localhost:27017
set DOCKER_MONGO_URI=mongodb://admin:password123@localhost:27017
set BACKUP_DIR=mongo_backup

REM Créer le répertoire de sauvegarde
if not exist %BACKUP_DIR% mkdir %BACKUP_DIR%

echo 📤 Export des données depuis MongoDB local...

REM Export des collections depuis la base locale
docker run --rm -v %cd%\%BACKUP_DIR%:/backup --network host mongo:7-jammy mongodump --uri="%LOCAL_MONGO_URI%/dune" --out=/backup

if %ERRORLEVEL% EQU 0 (
    echo ✅ Export réussi depuis MongoDB local
) else (
    echo ❌ Erreur lors de l'export depuis MongoDB local
    exit /b 1
)

echo 📥 Import des données vers MongoDB Docker...

REM Import vers la base Docker
docker run --rm -v %cd%\%BACKUP_DIR%:/backup --network host mongo:7-jammy mongorestore --uri="%DOCKER_MONGO_URI%/dune" --drop /backup/dune

if %ERRORLEVEL% EQU 0 (
    echo ✅ Import réussi vers MongoDB Docker
) else (
    echo ❌ Erreur lors de l'import vers MongoDB Docker
    exit /b 1
)

echo 🔍 Vérification des données importées...

REM Vérifier le nombre de documents dans chaque collection
echo Collections dans MongoDB Docker après import:
docker exec dune-mongodb mongosh -u admin -p password123 --authenticationDatabase admin dune --eval "print('📊 Statistiques des collections:'); print('Items:', db.items.countDocuments()); print('Chests:', db.chests.countDocuments()); print('Activity Logs:', db.activity_logs.countDocuments()); print('✅ Migration terminée avec succès!');"

REM Nettoyer le répertoire de sauvegarde
echo 🧹 Nettoyage des fichiers temporaires...
rmdir /s /q %BACKUP_DIR%

echo 🎉 Migration des données terminée !
echo ==================================================
