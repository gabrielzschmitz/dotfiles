#   __ _  ____ ___ 
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz               
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/    
# 
#!bin/sh
# Clean Up $HOME Directory
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_CACHE="$HOME/.cache"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME/.config/zsh"
export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc-2.0"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export STEAM_FRAME_FORCE_CLOSE=1

