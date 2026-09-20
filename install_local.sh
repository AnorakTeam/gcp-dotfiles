#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "  Instalador Local de Dotfiles & Tooling (Ubuntu / Mint)  "
echo "=========================================================="

# -------------------------------------------------------------
# 0. Verificación de permisos de superusuario (sudo)
# -------------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
    if ! command -v sudo &> /dev/null; then
        echo "Error: Se requiere 'sudo' para instalar herramientas en /usr/local/bin." >&2
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# Solicitar credenciales al inicio
$SUDO -v

# Mantener vivo el timestamp de sudo durante la instalación
while true; do $SUDO -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null || true' EXIT

# Detección de arquitectura del sistema
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        EZA_ARCH="x86_64-unknown-linux-gnu"
        TF_ARCH="amd64"
        DEB_ARCH="amd64"
        ;;
    aarch64|arm64)
        EZA_ARCH="aarch64-unknown-linux-gnu"
        TF_ARCH="arm64"
        DEB_ARCH="arm64"
        ;;
    *)
        echo "Advertencia: Arquitectura '$ARCH' no probada exhaustivamente. Se usará amd64 por defecto."
        EZA_ARCH="x86_64-unknown-linux-gnu"
        TF_ARCH="amd64"
        DEB_ARCH="amd64"
        ;;
esac

# -------------------------------------------------------------
# 1. Dependencias base del sistema vía APT
# -------------------------------------------------------------
echo "==> [1/8] Instalando paquetes base con APT..."
$SUDO apt-get update
$SUDO apt-get install -y \
    build-essential \
    git \
    unzip \
    curl \
    tree \
    ncurses-bin \
    cowsay

# En Debian/Ubuntu cowsay a veces se instala en /usr/games
if [ -f /usr/games/cowsay ] && [ ! -f /usr/local/bin/cowsay ] && [ ! -f /usr/bin/cowsay ]; then
    $SUDO ln -sf /usr/games/cowsay /usr/local/bin/cowsay
fi

# -------------------------------------------------------------
# 2. Terraform
# -------------------------------------------------------------
if ! command -v terraform &> /dev/null; then
    echo "==> [2/8] Descargando e instalando Terraform en /usr/local/bin..."
    TMP_TF=$(mktemp -d)
    TF_VERSION=$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform 2>/dev/null | grep -oP '"current_version":"\K[^"]+' || echo "1.16.2")
    curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip" -o "${TMP_TF}/terraform.zip"
    $SUDO unzip -o "${TMP_TF}/terraform.zip" -d /usr/local/bin/
    $SUDO chmod +x /usr/local/bin/terraform
    rm -rf "${TMP_TF}"
else
    echo "==> [2/8] Terraform ya está instalado ($(terraform -version | head -n 1))."
fi

# -------------------------------------------------------------
# 3. Oh-My-Posh
# -------------------------------------------------------------
if ! command -v oh-my-posh &> /dev/null; then
    echo "==> [3/8] Instalando Oh-My-Posh en /usr/local/bin..."
    curl -s https://ohmyposh.dev/install.sh | $SUDO bash -s -- -d /usr/local/bin
else
    echo "==> [3/8] Oh-My-Posh ya está instalado."
fi

# -------------------------------------------------------------
# 4. Eza (ls con soporte para iconitos y tal)
# -------------------------------------------------------------
if ! command -v eza &> /dev/null; then
    echo "==> [4/8] Descargando e instalando eza en /usr/local/bin..."
    curl -fsSL "https://github.com/eza-community/eza/releases/latest/download/eza_${EZA_ARCH}.tar.gz" | $SUDO tar -xz -C /usr/local/bin/
    $SUDO chmod +x /usr/local/bin/eza
else
    echo "==> [4/8] eza ya está instalado."
fi

# -------------------------------------------------------------
# 5. Fastfetch + Presets oficiales
# -------------------------------------------------------------
if ! command -v fastfetch &> /dev/null; then
    echo "==> [5/8] Descargando e instalando fastfetch..."
    TMP_FF=$(mktemp -d)
    DEB_URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${DEB_ARCH}.deb"
    
    if curl -fsSL "$DEB_URL" -o "${TMP_FF}/fastfetch.deb" && $SUDO apt-get install -y "${TMP_FF}/fastfetch.deb" 2>/dev/null; then
        echo "    Fastfetch instalado correctamente vía paquete deb."
    else
        echo "    Instalando Fastfetch vía release tarball en /usr/local/..."
        curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${DEB_ARCH}.tar.gz" | tar -xz -C "${TMP_FF}"
        FF_DIR=$(find "${TMP_FF}" -maxdepth 1 -type d -name "fastfetch*" | head -n 1)
        if [ -n "$FF_DIR" ]; then
            $SUDO cp "${FF_DIR}/usr/bin/fastfetch" /usr/local/bin/
            $SUDO chmod +x /usr/local/bin/fastfetch
            $SUDO mkdir -p /usr/local/share/fastfetch/presets
            $SUDO cp -r "${FF_DIR}/usr/share/fastfetch/presets/"* /usr/local/share/fastfetch/presets/
        fi
    fi
    rm -rf "${TMP_FF}"
else
    echo "==> [5/8] fastfetch ya está instalado."
fi

# -------------------------------------------------------------
# 6. Lolcat (Versión optimizada y rápida en C)
# -------------------------------------------------------------
if [ ! -f /usr/local/bin/lolcat ]; then
    echo "==> [6/8] Compilando e instalando lolcat (C) en /usr/local/bin..."
    TMP_LOLCAT=$(mktemp -d)
    git clone --depth 1 https://github.com/jaseg/lolcat "${TMP_LOLCAT}/lolcat"
    make -C "${TMP_LOLCAT}/lolcat" lolcat
    $SUDO cp "${TMP_LOLCAT}/lolcat/lolcat" /usr/local/bin/lolcat
    $SUDO chmod +x /usr/local/bin/lolcat
    rm -rf "${TMP_LOLCAT}"
else
    echo "==> [6/8] lolcat (C) ya está presente en /usr/local/bin."
fi

# -------------------------------------------------------------
# 7. Kimsay (Disco Elysium)
# -------------------------------------------------------------
if ! command -v kimsay &> /dev/null; then
    echo "==> [7/8] Compilando e instalando kimsay en /usr/local..."
    TMP_KIMSAY=$(mktemp -d)
    git clone --depth 1 https://github.com/IcaroJam/kimsay "${TMP_KIMSAY}/kimsay"
    $SUDO make -C "${TMP_KIMSAY}/kimsay" install
    rm -rf "${TMP_KIMSAY}"
else
    echo "==> [7/8] kimsay ya está instalado."
fi

# -------------------------------------------------------------
# 8. Despliegue de Configuraciones y Dotfiles de Usuario
# -------------------------------------------------------------
echo "==> [8/8] Desplegando configuraciones y dotfiles..."

# 8.1. Tema Oh-My-Posh
mkdir -p ~/.config/ohmyposh
cp "${REPO_DIR}/configs/EDM115-newline.omp.json" ~/.config/ohmyposh/EDM115-newline.omp.json

# 8.2. Configuración Fastfetch
mkdir -p ~/.config/fastfetch
cp "${REPO_DIR}/configs/fastfetch-config.jsonc" ~/.config/fastfetch/config.jsonc

# 8.3. Dotfile .bash_aliases
if [ -f ~/.bash_aliases ]; then
    if ! cmp -s "${REPO_DIR}/configs/.bash_aliases" ~/.bash_aliases; then
        echo "    Creando respaldo de ~/.bash_aliases en ~/.bash_aliases.bak..."
        cp ~/.bash_aliases ~/.bash_aliases.bak
    fi
fi
cp "${REPO_DIR}/configs/.bash_aliases" ~/.bash_aliases

# 8.4. Vincular ~/.bash_aliases y customff_func en ~/.bashrc
touch ~/.bashrc

if ! grep -q "\. ~/.bash_aliases" ~/.bashrc && ! grep -q "source ~/.bash_aliases" ~/.bashrc; then
    echo "    Vinculando ~/.bash_aliases en ~/.bashrc..."
    cat << 'EOF' >> ~/.bashrc

# Cargar aliases personalizados
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
fi

if ! grep -q "customff_func" ~/.bashrc; then
    echo "    Configurando saludo customff_func en ~/.bashrc..."
    cat << 'EOF' >> ~/.bashrc

# Mostrar banner Fastfetch y frase del Disco al abrir terminal
customff_func
EOF
fi

echo ""
echo "=========================================================="
echo "  Instalación local completada (creo jsjsjs)              "
echo "=========================================================="
echo "Ejecuta el siguiente comando para aplicar los cambios, o mata esta terminal y abre otra"
echo "    source ~/.bashrc"
