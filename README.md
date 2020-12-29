# gabrielzschmitz Dotfiles

## Table of Contents
- [Screenshots](https://github.com/gabrielzschmitz/dotfiles#screenshots)
- [How to Install](https://github.com/gabrielzschmitz/dotfiles#how-to-install)
- [Window Manager Configs](https://github.com/gabrielzschmitz/dotfiles#window-manager-configs)
- [Other Themes and Configs](https://github.com/gabrielzschmitz/dotfiles#other-themes-and-configs)

### Screenshots
- Alacritty and CLI-Visualizer
![Alacritty and CLI-Visualizer Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Alacritty%2BCLI-Visualizer.png)

- GTK Theme and Icons
![GTK Theme and Icons Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/GTK%2BIcons.png)

- Geany
![Geany Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Geany.png)

- Firefox
![Firefox New Tab Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Firefox.png)

- Homepage
![My Firefox Homepage Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Homepage.png)

- Vimb
![Vimb Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Vimb.png)

- Nvim
![NeoVim Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/NeoVim.png)

- Ripcord
![Ripcord Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/Ripcord.png)

- DuckDuckGo
![DuckDuckGo Screenshot](https://github.com/gabrielzschmitz/dotfiles/blob/main/.screenshots/DuckDuckGo.png)

### How to Install

For all the programs (unless for Ripcord, VSCode, Firefox and DuckDuckGo, for them read the related tutorials)

```
mv ~/.config ~/.config-backup
mv ~/.zshrc ~/.zshrc-backup
mkdir -p ~/.config/ ~/Documents/ ~/Pictures/Wallpapers/
echo 'alias config="/usr/bin/git --git-dir=$HOME/Documents/dotfiles/ --work-tree=$HOME"' >> $HOME/.zshrc
source ~/.zshrc && mv ~/.zshrc ~/.zshrc-backup
echo "Documents/dotfiles" >> .gitignore
git clone --bare https://www.github.com/gabrielzschmitz/dotfiles $HOME/Documents/dotfiles
config checkout
config config --local status.showUntrackedFiles no
```

#### Ripcord
For Ripcord open the program an then in the Status Bar follow this path:
- View -> Preferences... <br>
Then click in Style, change the Theme for Custom and go fot Customize, then put that colors:

```
Window			#232731		Button			#2a2e3b
Text			#9faab8		Disabled Button		#1b1e26
Disabled Text		#6f798c		Unread Badge		#b1bdcc
Highlight		#353b4a		Unread Badge Text	#9faab8
Highlighted Text	#9faab8		Icon			#b1bdcc
Base			#232731		Disabled icon		#818a94
Alternate Base		#1b1e26		Chat Timestamp		#9faab8
```

#### VSCode
To install the Faint VSCode Theme:

1. Open VSCode/VSCodium, Ctrl+Shift+X to open the Extensions tab;

2. Install the Base16 Theme Generator;

3. After that copy the [Faint VSCode](https://pastebin.com/tLNLJFfm) and paste it in a .json file (Preferably "Faint.json");

4. Then cut the Faint.json to the Base16 Theme Generator themes folder;

5. Usually it resides in ~/.vscode-oss/extensions/golf1052.base16-generator/themes;

6. Then restart the VSCode/VSCodium and open the Command Pallete with Ctrl+Shift+P;

7. Search for Base16: Activate theme, search for Faint and activate it;

8. Then restart again the VSCode/VSCodium;

9. And finally open the Color Theme tab with Ctrl+K+Ctrl+S and select the Faint Theme.

#### Firefox
To Firefox First of all:

- Clone My Firefox repository

```
git clone https://github.com/gabrielzschmitz/MyHomepage.git
```
- Then for the homepage just make the myhomepage.html your startpage in firefox.

- For the Firefox Theme:

1. Put "about:config" in the address bar, set "toolkit.legacyUserProfileCustomizations.stylesheets" true

2. Open the profile folder. By putting "about:support" in the address bar, click "Open Folder" next to "Profile Folder"

3. Copy "userChrome.css" and "userContent.css" to "chrome" folder (create if not exist)

4. Put Firefox in Default Theme, Compact Density and disables Menu Bar and Bookmarks Toolbar

5. Restart Firefox

#### DuckDuckGO
To configure the Faint Theme in DuckDuckGo:
1. Go to https://duckduckgo.com/settings#appearance
2. Put the DuckDuckGo colors like that:

```
Background Color:   		#232731
Header Color:   		#232731
Result Title Color:   		#469E76
Result Visited Title Color:	#B86974
Result Description Color:   	#9faab8
Result Url Color:   		#3C97AD
Result Hover, Module, and Dropdown Background Color:	#1b1e26
```

### Window Manager Configs
- [i3wm-config](https://github.com/gabrielzschmitz/dotfiles/tree/master/.config/i3)
- [i3status-config](https://github.com/gabrielzschmitz/dotfiles/tree/master/.config/i3status)

### Other Themes and Configs
- [Alacritty](https://github.com/gabrielzschmitz/dotfiles/tree/main/.config/alacritty)
- [Fonts](https://github.com/gabrielzschmitz/dotfiles/tree/main/.fonts)
- [GTK Theme](https://github.com/gabrielzschmitz/dotfiles/tree/main/.themes/Faint%20GTK)
- [Icons](https://github.com/gabrielzschmitz/dotfiles/tree/main/.icons/Faint%20Icons)
- [NeoVim](https://github.com/gabrielzschmitz/dotfiles/tree/main/.config/nvim)
- [Vimb](https://github.com/gabrielzschmitz/dotfiles/tree/main/.config/vimb)
- [Ripcord](https://github.com/gabrielzschmitz/dotfiles#ripcord)
- [VSCode](https://github.com/gabrielzschmitz/dotfiles#vscode)
- [Zsh](https://github.com/gabrielzschmitz/dotfiles/tree/main/.zshrc)
- [CLI-Visualizer](https://github.com/gabrielzschmitz/dotfiles/tree/main/.config/vis)
- [Firefox](https://github.com/gabrielzschmitz/dotfiles#firefox)
- [DuckDuckGo](https://github.com/gabrielzschmitz/dotfiles#duckduckgo)
- [Wallpapers](https://github.com/gabrielzschmitz/dotfiles/tree/main/Pictures/Wallpapers)
