# Análisis de seguridad con Checkov para Windows
# Este script falla automáticamente si Checkov detecta vulnerabilidades

$ErrorActionPreference = "Stop"

$TERRAFORM_DIR = "C:/Users/walte/Downloads/INFRAESTRUCTURA COMO CODIGO CURSO/Backend-main/INFRAESTRUCTURA DINEX/infrastructure/terraform"
$RESULTS_DIR = "C:/Users/walte/Downloads/INFRAESTRUCTURA COMO CODIGO CURSO/Backend-main/INFRAESTRUCTURA DINEX/infrastructure/security/results"

# Crear directorio de resultados si no existe
New-Item -ItemType Directory -Force -Path $RESULTS_DIR | Out-Null
Remove-Item -Path "$RESULTS_DIR\*.xml" -ErrorAction SilentlyContinue
Remove-Item -Path "$RESULTS_DIR\*.json" -ErrorAction SilentlyContinue

Write-Host "Ejecutando Checkov..." -ForegroundColor Cyan
Write-Host "IMPORTANTE: Este análisis fallará automáticamente si se detectan vulnerabilidades" -ForegroundColor Yellow
Write-Host "Analizando directorio: $TERRAFORM_DIR" -ForegroundColor Green

# Ejecutar Checkov y capturar el exit code
docker run --rm `
  -v "${TERRAFORM_DIR}:/tf" `
  bridgecrew/checkov:latest `
  --directory /tf `
  --framework terraform `
  --output cli

$CHECKOV_EXIT_CODE = $LASTEXITCODE

Write-Host ""
Write-Host "Generando reporte XML..." -ForegroundColor Cyan

docker run --rm `
  -v "${TERRAFORM_DIR}:/tf" `
  bridgecrew/checkov:latest `
  --directory /tf `
  --framework terraform `
  --output junitxml `
  --output-file-path /tf/checkov-results.xml `
  --quiet

# Mover reporte a directorio de resultados
if (Test-Path "$TERRAFORM_DIR/checkov-results.xml") {
    Move-Item -Path "$TERRAFORM_DIR/checkov-results.xml" -Destination "$RESULTS_DIR/" -Force
    Write-Host "Reporte guardado: $RESULTS_DIR/checkov-results.xml" -ForegroundColor Green
} else {
    Write-Host "Error: No se generó reporte" -ForegroundColor Red
    exit 1
}

# Salir con el exit code de Checkov
if ($CHECKOV_EXIT_CODE -ne 0) {
    Write-Host ""
    Write-Host "FALLO: Checkov detectó vulnerabilidades de seguridad" -ForegroundColor Red
    Write-Host "El pipeline se detiene automáticamente - NO se requiere intervención manual" -ForegroundColor Red
    exit $CHECKOV_EXIT_CODE
}

Write-Host ""
Write-Host "Análisis completado exitosamente - No se detectaron vulnerabilidades" -ForegroundColor Green
exit 0
