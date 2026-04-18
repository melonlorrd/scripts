printf '\33c\e[3J'

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

autoload -Uz compinit
compinit

autoload -Uz colors && colors
PROMPT='%F{blue}%~%f %F{magenta}λ%f '
