#   __ _  ____ ___ 
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/    
#
#!bin/sh

# Installation Script for Artix Base Install
# by gabrielzschmitz(https://github.com/gabrielzschmitz)
# Before running the script install paru and enable AUR manually

# paru
# sudo pacman -S --needed base-devel
# git clone https://aur.archlinux.org/paru.git "$HOME/.local/share/paru"
# cd $HOME/.local/share/paru
# makepkg -si

# enable colors in paru (and pacman)
# sudo nvim /etc/pacman.conf
# uncomment "Color" line

# Install all the programs with paru
paru -Syu --cleanafter --useask	\
polybar			\
cmatrix			\
scrot			\
alacritty		\
arandr			\
bat			\
dunst			\
exiv2			\
gcolor2			\
git			\
i3lock-color		\
lf			\
lsd			\
lxappearance		\
yarn			\
pandoc			\
texlive-core		\
pfetch-git		\
picom			\
polkit-gnome		\
sddm-sugar-candy-git	\
tty-clock		\
xautolock		\
xclip			\
xdotool			\
zathura			\
xwallpaper-git		\
devour			\
mellowplayer		\
betterdiscord		\
betterdiscordctl-git	\
librewolf-bin		\
sxiv			\
nodejs			\
paprefs			\
pasystray		\
pavucontrol		\
xarchiver		\
alacritty		\
zsh			\
neovim			\
obs-studio		\
qbittorrent		\
paru			\
discord;		\

# Make Steam close to system tray
# echo "export STEAM_FRAME_FORCE_CLOSE=1" >> .profile

# Git
# Set git to use the credential memory cache
git config --global credential.helper cache;
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600';


# LIBREWOLF EXTENSIONS:
# DarkCloud
# User Agent Plataform Spoofer
# UBlock Origin

# Dotfiles
# echo "alias dots='/usr/bin/git --git-dir=$HOME/Documents/dotfiles --work-tree=/home/gabrielzschmitz'" >> $HOME/.zshrc
# source ~/.zshrc
# echo "$HOME/Documents/dotfiles" >> .gitignore
# git clone --bare https://www.github.com/gabrielzschmitz/dotfiles.git $HOME/Documents/dotfiles
# ('rm' and 'rm -rf' all the files/folders that are making it impossible to checkout)
# dots checkout
# dots config --local status.showUntrackedFiles no

