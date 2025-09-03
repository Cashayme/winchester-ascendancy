Write-Host "Import des donnees JSON vers MongoDB Docker" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Yellow

# Variables
$DockerMongoUri = "mongodb://admin:password123@localhost:27017"
$JsonFiles = @("items.json", "chests.json", "activity_logs.json")

# Vérifier que les fichiers JSON existent
$missingFiles = @()
foreach ($file in $JsonFiles) {
    if (!(Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Fichiers manquants:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host "Veuillez exporter vos donnees d'abord (voir export-instructions.md)" -ForegroundColor Yellow
    exit 1
}

Write-Host "Tous les fichiers JSON sont presents, debut de l'import..." -ForegroundColor Green

# Importer chaque collection
foreach ($file in $JsonFiles) {
    $collectionName = $file.Replace(".json", "")
    Write-Host "Import de $collectionName..." -ForegroundColor Blue

    $importCommand = "docker run --rm -v ${PWD}:/data --network host mongo:7-jammy mongoimport --uri=`"$DockerMongoUri`" --db=dune --collection=$collectionName --file=/data/$file --jsonArray --drop"

    Write-Host "Execution: $importCommand" -ForegroundColor Gray
    Invoke-Expression $importCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Import reussi pour $collectionName" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de l'import de $collectionName" -ForegroundColor Red
    }
}

Write-Host "Verification des donnees importees..." -ForegroundColor Blue

# Vérifier le nombre de documents dans chaque collection
$checkCommand = "docker exec dune-mongodb mongosh -u admin -p password123 --authenticationDatabase admin dune --eval `"print('Statistiques apres import:'); print('Items:', db.items.countDocuments()); print('Chests:', db.chests.countDocuments()); print('Activity Logs:', db.activity_logs.countDocuments());`""

Write-Host "Execution: $checkCommand" -ForegroundColor Gray
Invoke-Expression $checkCommand

Write-Host "Import termine!" -ForegroundColor Green
Write-Host "Vous pouvez maintenant acceder a vos donnees via l'application sur http://localhost:3000" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Yellow
