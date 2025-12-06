#!/bin/bash
# Análisis de seguridad con Checkov
# Este script falla automáticamente si Checkov detecta vulnerabilidades

set -e  # Detener el script si cualquier comando falla

TERRAFORM_DIR="../../terraform"
RESULTS_DIR="../results"

mkdir -p "$RESULTS_DIR"
rm -f "$RESULTS_DIR"/*.xml "$RESULTS_DIR"/*.json

echo "Ejecutando Checkov..."
echo "IMPORTANTE: Este análisis fallará automáticamente si se detectan vulnerabilidades"

# Ejecutar Checkov y capturar el exit code
docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:latest \
  --directory /tf \
  --framework terraform \
  --output cli

CHECKOV_EXIT_CODE=$?

echo "Generando reporte XML..."

docker run --rm \
  -v "$(pwd)/$TERRAFORM_DIR:/tf" \
  --workdir /tf \
  bridgecrew/checkov:latest \
  --directory /tf \
  --framework terraform \
  --output junitxml \
  --output-file-path /tf/checkov-results.xml \
  --quiet

if [ -f "$TERRAFORM_DIR/checkov-results.xml" ]; then
    mv "$TERRAFORM_DIR/checkov-results.xml" "$RESULTS_DIR/"
    echo "Reporte guardado: $RESULTS_DIR/checkov-results.xml"
else
    echo "Error: No se generó reporte"
    exit 1
fi

# Salir con el exit code de Checkov
if [ $CHECKOV_EXIT_CODE -ne 0 ]; then
    echo "FALLO: Checkov detectó vulnerabilidades de seguridad"
    echo "El pipeline se detiene automáticamente - NO se requiere intervención manual"
    exit $CHECKOV_EXIT_CODE
fi

echo "Análisis completado exitosamente - No se detectaron vulnerabilidades"
exit 0
