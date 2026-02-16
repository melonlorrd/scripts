printf '\33c\e[3J'

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

autoload -Uz compinit
compinit

eval "$(starship init zsh)"
