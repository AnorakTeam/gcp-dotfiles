#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [1/2] Instalando binarios persistentes en ~/bin..."
bash "${REPO_DIR}/scripts/01-binaries.sh"

echo "==> [2/2] Desplegando archivos de configuración y dotfiles..."
bash "${REPO_DIR}/scripts/02-configs.sh" "${REPO_DIR}"

echo ""
echo "¡Instalación completada con éxito!"
echo "Ejecuta el siguiente comando para aplicar los cambios:"
echo "    source ~/.bashrc"