printf '\33c\e[3J'

autoload -Uz compinit
compinit

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(starship init zsh)"
