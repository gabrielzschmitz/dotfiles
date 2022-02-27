# gabrielzschmitz Dotfiles

## Main configs demonstration:
### dwm
![dwm](https://github.com/gabrielzschmitz/dotfiles/blob/main/pic/%5Bricedemo%5D/dwm%5Bdemo%5D.png)
### st
![st](https://github.com/gabrielzschmitz/dotfiles/blob/main/pic/%5Bricedemo%5D/st%5Bdemo%5D.png)
### dmenu
![dmenu](https://github.com/gabrielzschmitz/dotfiles/blob/main/pic/%5Bricedemo%5D/dmenu%5Bdemo%5D.png)
### nvim
![nvim](https://github.com/gabrielzschmitz/dotfiles/blob/main/pic/%5Bricedemo%5D/nvim%5Bdemo%5D.png)
### walls
![walls](https://github.com/gabrielzschmitz/dotfiles/blob/main/pic/%5Bricedemo%5D/walls%5Bdemo%5D.png)

## How to Install
```shell
echo "alias dots='/usr/bin/git --git-dir=$HOME/doc/dotfiles --work-tree=$HOME'" >> $HOME/.zshrc
source ~/.zshrc
echo "$HOME/doc/dotfiles" >> .gitignore
git clone --bare https://www.github.com/gabrielzschmitz/dotfiles.git $HOME/doc/dotfiles

('rm' and 'rm -rf' all the files/folders that are making it impossible to checkout)
dots checkout
dots config --local status.showUntrackedFiles no
```

### DuckDuckGO
To configure the zero theme in DuckDuckGo:
1. Go to https://duckduckgo.com/settings#appearance

2.1. Put the DuckDuckGo colors like that:
|                                                     |         |
| :-------------------------------------------------: | :-----: |
| Background Color                                    | #080808 |
| Header Color                                        | #030303 |
| Result Title Color                                  | #324f66 |
| Result Visited Title Color                          | #564666 |
| Result Description Color                            | #b3b3b3 |
| Result Url Color                                    | #375759 |
| Result Hover, Module, and Dropdown Background Color | #141414 |

2.2. Or use the load settings with the following phrase:

```
gabrielzschmitz-zero-theme
```
