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
#!bin/sh
# Clean Up $HOME Directory
export PATH="$PATH:${$(find ~/.local/bin -type d -printf %p:)%%:}"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_CACHE="$HOME/.cache"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME/.config/zsh"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="chromium"

export NNN_PLUG='f:finder;o:fzopen;p:mocplay;d:diffs;t:nmount;v:imgview'
BLK="0B" CHR="0B" DIR="04" EXE="06" REG="00" HARDLINK="06" SYMLINK="06" MISSING="00" ORPHAN="09" FIFO="06" SOCK="0B" OTHER="06"
export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
set --export NNN_FIFO "/tmp/nnn.fifo"

