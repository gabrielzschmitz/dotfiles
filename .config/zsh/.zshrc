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
# A customized Zsh Config by gabrielzschmitz

# Preferred editor and visual
autoload -U colors && colors
export EDITOR='nvim';
export VISUAL='nvim';

source $ZDOTDIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh

## Vi mode
bindkey -v
KEYTIMEOUT=1
# Prompt
PROMPT_EOL_MARK=''
#sh $HOME/.scripts/quote.textart
sh -c "$HOME/.config/zerofetch/zerofetch"
fpath+=$ZDOTDIR/typewritten
autoload -U promptinit; promptinit
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      VIMODE="NORMAL ❯"
      VICOLORS="primary:red;secondary:green;accent:green"
      ;;
    $ZVM_MODE_INSERT)
      VIMODE="INSERT ❯"
      VICOLORS="primary:red;secondary:cyan;accent:green"
      ;;
    $ZVM_MODE_VISUAL)
      VIMODE="VISUAL ❯"
      VICOLORS="primary:red;secondary:yellow;accent:green"
      ;;
    $ZVM_MODE_VISUAL_LINE)
      VIMODE="V-LINE ❯"
      VICOLORS="primary:red;secondary:yellow;accent:green"
      ;;
  esac
  export TYPEWRITTEN_SYMBOL="$VIMODE"
  export TYPEWRITTEN_COLOR_MAPPINGS="$VICOLORS"
  prompt typewritten
}
# More keybinds
bindkey -a u undo
bindkey -a '^r' redo
bindkey '^?' backward-delete-char
autoload edit-command-line; zle -N edit-command-line # Use v-v to edit the command line in nvim

# Aliases
source $ZDOTDIR/aliases

# History
export HISTFILE=$ZDOTDIR/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

# Man pages colors
export LESS_TERMCAP_mb=$'\e[0;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;41;30m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[0;36m'

# Set 256 color terminal and Highlighting
export TERM=xterm-256color
source $ZDOTDIR/highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
setopt NO_CASE_GLOB

# Completition
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle :compinstall filename '/home/gabrielzschmitz/.config/zsh/.zshrc'
autoload -Uz compinit
compinit
_comp_options+=(globdots)

if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0232323" #black
    echo -en "\e]P82B2B2B" #darkgrey
    echo -en "\e]P1D75F5F" #darkred
    echo -en "\e]P9E33636" #red
    echo -en "\e]P287AF5F" #darkgreen
    echo -en "\e]PA98E34D" #green
    echo -en "\e]P3D7AF87" #brown
    echo -en "\e]PBFFD75F" #yellow
    echo -en "\e]P48787AF" #darkblue
    echo -en "\e]PC7373C9" #blue
    echo -en "\e]P5BD53A5" #darkmagenta
    echo -en "\e]PDD633B2" #magenta
    echo -en "\e]P65FAFAF" #darkcyan
    echo -en "\e]PE44C9C9" #cyan
    echo -en "\e]P7E5E5E5" #lightgrey
    echo -en "\e]PFFFFFFF" #white
    clear #for background artifacting
fi

