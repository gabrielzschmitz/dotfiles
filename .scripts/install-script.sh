#   __ _  ____ ___ 
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz               
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/    
#
#!bin/sh

# Installation Script for Manjaro I3 Minimal
# by gabrielzschmitz(https://github.com/gabrielzschmitz)
# Before running the script install yay manually

# Remove Programs
pacman -Rsnu --noconfirm cmus;
pacman -Rsnu --noconfirm mousepad;
pacman -Rsnu --noconfirm bmenu;
pacman -Rsnu --noconfirm conky;
pacman -Rsnu --noconfirm conky-i3;
pacman -Rsnu --noconfirm i3-default-artwork;
pacman -Rsnu --noconfirm manjaro-zsh-config;
pacman -Rsnu --noconfirm manjaro-browser-settings;
pacman -Rsnu --noconfirm morc-menu;
pacman -Rsnu --noconfirm palemoon-bin;
pacman -Rsnu --noconfirm pacui;
pacman -Rsnu --noconfirm nitrogen;
pacman -Rsnu --noconfirm firefox;

# Enable AUR and Update Mirrors
sudo -u	gabrielzschmitz \
yay -Syu --nocleanmenu --noeditmenu --nodiffmenu --cleanafter --useask	\
xwallpaper-git		\
devour			\
mellowplayer		\
betterdiscord		\
betterdiscordctl-git	\
librewolf-bin;		\
yay -Syu --nocleanmenu --noeditmenu --nodiffmenu --cleanafter --useask	\
sxiv			\
nodejs			\
paprefs			\
pasystray		\
pavucontrol		\
lightdm-settings	\
p7zip			\
unzip			\
xarchiver		\
alacritty		\
zsh			\
libreoffice-fresh	\
deadbeef		\
neovim			\
obs-studio		\
qbittorrent		\
yay			\
discord;		\

# Make Steam close to system tray
echo "export STEAM_FRAME_FORCE_CLOSE=1" >> .profile

# GIT
# Set git to use the credential memory cache
git config --global credential.helper cache;
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600';


# LIBREWOLF EXTENSIONS:
# DarkCloud
# User Agent Plataform Spoofer
# UBlock Origin

