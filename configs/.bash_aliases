# -----------------------------------------------------
# Path
# -----------------------------------------------------
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi

# -----------------------------------------------------
# Git
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gfo="git fetch origin"
alias gcheck="git checkout"

# -----------------------------------------------------
# General
# -----------------------------------------------------
alias c='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias ls='eza -a --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'

# -----------------------------------------------------
# Prompt
# -----------------------------------------------------
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init bash --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)"
fi

# -----------------------------------------------------
# Disco Elysium / Kimsay
# -----------------------------------------------------
export DISCO_CHARACTERS="kim conceptualization drama encyclopedia logic rhetoric visualCalculus authority empathy espritDeCorps inlandEmpire suggestion volition electrochemistry endurance halfLight painThreshold physicalInstrument shivers composure handEyeCoordination interfacing perception reactionSpeed savoirFaire harry cuno measurehead"

kimsayrandom() {
  local -a chars
  read -r -a chars <<< "$DISCO_CHARACTERS"
  local char="${chars[RANDOM % ${#chars[@]}]}"
  echo "$char"
}

kimsayphrase() {
  kimsay -c "$(kimsayrandom)" -r -F -f . -w "$(tput cols)"
}

customff_func() {
  fastfetch && kimsayphrase | lolcat
}