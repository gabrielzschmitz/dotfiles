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
export EDITOR='nvim';
export VISUAL='nvim';

# Aliases
source $ZDOTDIR/aliases

# History
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
export HISTSIZE=10000
export HISTFILE=$ZDOTDIR/.zhistory

# Prompt
export TYPEWRITTEN_COLOR_MAPPINGS="primary:red;secondary:green;accent:green"
fpath+=$ZDOTDIR/typewritten
autoload -U promptinit; promptinit
prompt typewritten
PROMPT_EOL_MARK=''
sh $HOME/.scripts/quote.textart

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
source $ZDOTDIR/highlighting/zsh-syntax-highlighting.zsh

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

