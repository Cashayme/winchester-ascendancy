Write-Host "Demarrage de la migration des donnees MongoDB" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Yellow

# Variables de configuration
$LocalMongoUri = "mongodb://localhost:27017"
$DockerMongoUri = "mongodb://admin:password123@localhost:27017"
$BackupDir = "mongo_backup"

# Creer le repertoire de sauvegarde
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

Write-Host "Export des donnees depuis MongoDB local..." -ForegroundColor Blue

# Export des collections depuis la base locale (essayer sans auth d'abord)
$exportCommand = "docker run --rm -v ${PWD}\${BackupDir}:/backup --network host mongo:7-jammy mongodump --host localhost --port 27017 --db dune --out=/backup"
Write-Host "Execution: $exportCommand" -ForegroundColor Gray
Invoke-Expression $exportCommand

# Si ça échoue, essayer avec l'ancienne syntaxe
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tentative avec l'ancienne syntaxe MongoDB..." -ForegroundColor Yellow
    $exportCommand = "docker run --rm -v ${PWD}\${BackupDir}:/backup --network host mongo:7-jammy mongodump localhost:27017/dune --out=/backup"
    Write-Host "Execution: $exportCommand" -ForegroundColor Gray
    Invoke-Expression $exportCommand
}

# Vérifier le succès après les deux tentatives
if ($LASTEXITCODE -eq 0) {
    Write-Host "Export reussi depuis MongoDB local" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de l'export depuis MongoDB local" -ForegroundColor Red
    Write-Host "Verifier que MongoDB local est accessible et que la base 'dune' existe" -ForegroundColor Yellow
    exit 1
}

Write-Host "Import des donnees vers MongoDB Docker..." -ForegroundColor Blue

# Import vers la base Docker
$importCommand = "docker run --rm -v ${PWD}\${BackupDir}:/backup --network host mongo:7-jammy mongorestore --uri=`"${DockerMongoUri}/dune`" --drop /backup/dune"
Write-Host "Execution: $importCommand" -ForegroundColor Gray
Invoke-Expression $importCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "Import reussi vers MongoDB Docker" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de l'import vers MongoDB Docker" -ForegroundColor Red
    exit 1
}

Write-Host "Verification des donnees importees..." -ForegroundColor Blue

# Vérifier le nombre de documents dans chaque collection
Write-Host "Collections dans MongoDB Docker après import:" -ForegroundColor Cyan
$checkCommand = "docker exec dune-mongodb mongosh -u admin -p password123 --authenticationDatabase admin dune --eval `"print('Statistiques des collections:'); print('Items:', db.items.countDocuments()); print('Chests:', db.chests.countDocuments()); print('Activity Logs:', db.activity_logs.countDocuments()); print('Migration terminee avec succes!');`""
Write-Host "Execution: $checkCommand" -ForegroundColor Gray
Invoke-Expression $checkCommand

# Nettoyer le repertoire de sauvegarde
Write-Host "Nettoyage des fichiers temporaires..." -ForegroundColor Blue
if (Test-Path $BackupDir) {
    Remove-Item -Recurse -Force $BackupDir
}

Write-Host "Migration des donnees terminee !" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Yellow
