#!/usr/bin/env bash
set -e

mkdir -p ~/bin ~/share ~/.local/share/fastfetch/presets /tmp/cs-install

echo "Verificando dependencias base del sistema"
sudo apt-get update && sudo apt-get install -y build-essential git unzip curl tree ncurses-bin

# Para agregar programasa (y que no se limpien cada vez que se resetea la sesión)
# toca moverlos a $HOME (donde google nos da el disco de unos 5 gigas efimero entre
# sesiones).
# Toncs colocarlos ordenados paso a paso y ver cómo poder moverlos a $HOME, algunos
# hay que compilarlos y otros simplemente sirve mover el binario.

# 1. Terraform
if [ ! -f ~/bin/terraform ]; then
    echo "--> Descargando Terraform..."
    TF_VERSION="1.16.2"
    curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o /tmp/cs-install/terraform.zip
    unzip -o /tmp/cs-install/terraform.zip -d ~/bin/
    chmod +x ~/bin/terraform
fi

# 2. Oh-My-Posh
if [ ! -f ~/bin/oh-my-posh ]; then
    echo "--> Instalando Oh-My-Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
fi

# 3. Eza (ls con iconitos)
if [ ! -f ~/bin/eza ]; then
    echo "--> Descargando eza..."
    curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar -xz -C ~/bin/
    chmod +x ~/bin/eza
fi

# 4. Fastfetch + Presets oficiales (mi preset es el 10, solo que un poco modificado)
# usar fastfetch --list-presets para ver los que hay disponibles.
if [ ! -f ~/bin/fastfetch ]; then
    echo "--> Descargando fastfetch y presets..."
    mkdir -p /tmp/cs-install/fastfetch
    curl -fsSL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.tar.gz | tar -xz -C /tmp/cs-install/fastfetch
    cp /tmp/cs-install/fastfetch/fastfetch-linux-amd64/usr/bin/fastfetch ~/bin/
    cp -r /tmp/cs-install/fastfetch/fastfetch-linux-amd64/usr/share/fastfetch/presets/* ~/.local/share/fastfetch/presets/
    chmod +x ~/bin/fastfetch
fi

# 5. Lolcat (C Nativo)
if [ ! -f ~/bin/lolcat ]; then
    echo "--> Compilando lolcat (C)..."
    git clone --depth 1 https://github.com/jaseg/lolcat /tmp/cs-install/lolcat
    make -C /tmp/cs-install/lolcat lolcat
    cp /tmp/cs-install/lolcat/lolcat ~/bin/
    chmod +x ~/bin/lolcat
fi

# 6. Cowsay
if [ ! -f ~/bin/cowsay ]; then
    echo "--> Instalando cowsay en $HOME..."
    git clone --depth 1 https://github.com/cowsay-org/cowsay /tmp/cs-install/cowsay
    make -C /tmp/cs-install/cowsay install prefix="$HOME"
fi

# 7. Kimsay (Disco Elysium)
if [ ! -f ~/bin/kimsay ]; then
    echo "--> Instalando kimsay en $HOME..."
    git clone --depth 1 https://github.com/IcaroJam/kimsay /tmp/cs-install/kimsay
    make -C /tmp/cs-install/kimsay install PREFIX="$HOME"
fi

# 8. Tree y Tput (Persistir copias locales, si no están en local se eliminan)
[ ! -f ~/bin/tree ] && cp "$(which tree)" ~/bin/tree
[ ! -f ~/bin/tput ] && cp "$(which tput)" ~/bin/tput
chmod +x ~/bin/tree ~/bin/tput

# Limpieza temporal
rm -rf /tmp/cs-install