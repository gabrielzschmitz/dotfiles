#!/bin/sh
#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
# GITHUB:https://github.com/gabrielzschmitz		  
# INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
# DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   

# Clean Up $HOME Directory
export PATH="$PATH:${$(find ~/.local/bin -type d -printf %p:)%%:}"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_CACHE="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XAUTHORITY="$HOME/.config/X11"/xauthority
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME/.config/zsh"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="chromium"

# GPU Stuff
export vblank_mode=0

