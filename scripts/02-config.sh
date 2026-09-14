#!/usr/bin/env bash
set -e

REPO_DIR="$1"

# 1. Copiar dotfiles principales
cp "${REPO_DIR}/configs/.bash_aliases" ~/.bash_aliases
cp "${REPO_DIR}/configs/.customize_environment" ~/.customize_environment
chmod +x ~/.customize_environment

# 2. Desplegar tema Oh-My-Posh
mkdir -p ~/.config/ohmyposh
cp "${REPO_DIR}/configs/EDM115-newline.omp.json" ~/.config/ohmyposh/EDM115-newline.omp.json

# 3. Desplegar configuración personalizada de Fastfetch
mkdir -p ~/.config/fastfetch
cp "${REPO_DIR}/configs/fastfetch-config.jsonc" ~/.config/fastfetch/config.jsonc

# 4. Vincular de forma segura ~/.bash_aliases en ~/.bashrc
if ! grep -q "\. ~/.bash_aliases" ~/.bashrc && ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
    echo "--> Vinculando .bash_aliases al final de ~/.bashrc..."
    cat << 'EOF' >> ~/.bashrc

# Cargar aliases personalizados al final
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
customff_func
EOF
fi