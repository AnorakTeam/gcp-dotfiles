# Google Cloud Shell Dotfiles & Tooling

Configuración automatizada y persistente para Google Cloud Shell con soporte para Terraform, Oh-My-Posh, Eza, Fastfetch y utilidades de Disco Elysium `kimsay` + `lolcat` (shoutout a https://github.com/IcaroJam/kimsay).

## Instalación Rápida

Ejecuta en tu terminal de Google Cloud Shell:

```bash
git clone https://github.com/AnorakTeam/gcp-dotfiles.git ~/.cloudshell-dotfiles
cd ~/.cloudshell-dotfiles
chmod +x install.sh scripts/*.sh
./install.sh
source ~/.bashrc
```

---

## Persistencia en Cloud Shell

El sistema de archivos raíz (`/`) de Cloud Shell es efímero y se destruye cuando la sesión caduca o se recicla. Para garantizar que **no sea necesario descargar ni compilar nada de nuevo**, este repositorio:

1. Instala todos los ejecutables en `$HOME/bin`:
   - `terraform`
   - `oh-my-posh`
   - `eza`
   - `fastfetch`
   - `kimsay`
   - `lolcat` (versión binaria compilada en C)
   - `cowsay`
   - `tree` y `tput`
2. Almacena las plantillas y cowfiles en `$HOME/share/`.
3. Guarda los presets de fastfetch en `$HOME/.local/share/fastfetch/presets/`.
4. Mantiene `$HOME/.customize_environment` sin cargas pesadas de `apt` para acelerar el arranque.

---

## Visualización de Íconos y Fuentes (Nerd Fonts)

Cloud Shell se ejecuta de forma remota y envía glifos Unicode. Tu navegador web y sistema operativo local son los responsables de renderizar los símbolos.

### 1. Requisito en tu equipo local
Debes tener instalada en tu sistema operativo local la versión monoespaciada estricta:
- **JetBrainsMono Nerd Font Mono** (o `MesloLGS NF`).

### 2. Configurar Stylus en el navegador
Para evitar que el emulador web (`xterm.js`) recorte los glifos o desalinee las columnas, crea una regla en la extensión **Stylus** para `https://shell.cloud.google.com`:

```css
.xterm, 
.terminal, 
.xterm-screen, 
.xterm-rows,
.xterm-rows span {
    font-family: 'JetBrainsMono Nerd Font Mono', 'JetBrainsMono NFM', 'JetBrainsMonoNL Nerd Font Mono', monospace !important;
    font-variant-ligatures: none !important;
    letter-spacing: 0 !important;
}

.xterm-rows span {
    overflow: visible !important;
}
```

### 4. Alternativa: Cloud Shell Editor

Huuuummmm no he probado con el vscode live, pero si se abre la terminal integrada de vscode (no la terminal de cloud shell aparte) debería seguir funcionando por el css de Stylus