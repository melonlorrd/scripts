#!/bin/sh

set -eux

link_if_missing() {
  src="$1"
  dst="$2"

  if [ -L "$dst" ] || [ -e "$dst" ]; then
    return 0
  fi

  ln -s "$src" "$dst"
}

link_if_missing "$(pwd)/dots-ganymede/.gitconfig" "$HOME/.gitconfig"
link_if_missing "$(pwd)/dots-ganymede/.zshrc" "$HOME/.zshrc"
link_if_missing "$(pwd)/dots-ganymede/.zprofile" "$HOME/.zprofile"
link_if_missing "$(pwd)/dots-ganymede/.config/ghostty" "$HOME/.config/ghostty"
link_if_missing "$(pwd)/dots-ganymede/.vimrc" "$HOME/.vimrc"
link_if_missing "$(pwd)/dots-ganymede/.config/helix" "$HOME/.config/helix"
