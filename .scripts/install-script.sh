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
alacritty-ligatures	\
arandr			\
bat			\
dunst			\
exiv2			\
gcolor3			\
i3exit			\
git			\
i3lock-color		\
lf			\
lsd			\
lxappearance-gtk3	\
yarn			\
pfetch			\
#picom			\
polkit-gnome		\
tty-clock		\
xautolock		\
xclip			\
xdotool			\
zathura			\
zathura-pdf-mupdf	\
xwallpaper-git		\
devour			\
betterdiscord-installer	\
betterdiscordctl-git	\
librewolf-bin		\
sxiv			\
nodejs			\
pavucontrol		\
xarchiver		\
pcmanfm-gtk3		\
zsh			\
neovim			\
obs-studio		\
qbittorrent		\
discord;		\

# Git
# Set git to use the credential memory cache
git config --global credential.helper cache;
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600';

