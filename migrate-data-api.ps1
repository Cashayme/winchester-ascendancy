Write-Host "Migration des donnees via l'API backend" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Yellow

# Variables
$BackendUrl = "http://localhost:4000"
$ApiBase = "$BackendUrl/api"

# Fonction pour faire des requêtes API
function Invoke-ApiRequest {
    param (
        [string]$Method = "GET",
        [string]$Endpoint,
        [string]$Body = $null
    )

    $url = "$ApiBase$Endpoint"

    try {
        $params = @{
            Uri = $url
            Method = $Method
            ContentType = "application/json"
        }

        if ($Body) {
            $params.Body = $Body
        }

        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Host "Erreur API: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "Verification de la connectivite de l'API..." -ForegroundColor Blue

# Tester la connectivite de l'API
$healthCheck = Invoke-ApiRequest -Endpoint "/health"
if ($null -eq $healthCheck) {
    Write-Host "L'API backend n'est pas accessible sur $BackendUrl" -ForegroundColor Red
    Write-Host "Assurez-vous que le backend local est demarre" -ForegroundColor Yellow
    exit 1
}

Write-Host "API accessible, debut de la migration..." -ForegroundColor Green

# Récupérer tous les coffres
Write-Host "Recuperation des coffres..." -ForegroundColor Blue
$chests = Invoke-ApiRequest -Endpoint "/chests"

if ($null -eq $chests) {
    Write-Host "Impossible de recuperer les coffres" -ForegroundColor Red
    exit 1
}

Write-Host "Nombre de coffres trouves: $($chests.Count)" -ForegroundColor Cyan

# Pour chaque coffre, récupérer les items
$totalItems = 0
foreach ($chest in $chests) {
    Write-Host "Traitement du coffre: $($chest.name) (ID: $($chest._id))" -ForegroundColor Blue

    try {
        # Récupérer les items du coffre
        $chestItems = Invoke-ApiRequest -Endpoint "/chests/$($chest._id)/items"

        if ($null -ne $chestItems) {
            $itemCount = $chestItems.Count
            $totalItems += $itemCount
            Write-Host "  - $itemCount items trouves" -ForegroundColor Green
        } else {
            Write-Host "  - Erreur lors de la recuperation des items" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  - Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Migration via API terminee!" -ForegroundColor Green
Write-Host "Total d'items trouves: $totalItems" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Yellow
