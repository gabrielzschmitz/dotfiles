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
export EDITOR='nvim'
export VISUAL='nvim'

# Vi mode
source $ZDOTDIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh
KEYTIMEOUT=1
bindkey -v
bindkey -a u undo
bindkey -a '^r' redo
bindkey '^?' backward-delete-char
autoload edit-command-line; zle -N edit-command-line # Use v-v to edit the command line in nvim

# Prompt
zerofetch
source $ZDOTDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
PROMPT_EOL_MARK=''
setopt prompt_subst
RPROMPT='%F{white}%1~'
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      VICOLORS="white"
      VIMODE="⤚➛ "
      ;;
    $ZVM_MODE_INSERT)
      VICOLORS="white"
      VIMODE="⤜➙ "
      ;;
    $ZVM_MODE_VISUAL)
      VICOLORS="white"
      VIMODE="⤚➻ "
      ;;
    $ZVM_MODE_VISUAL_LINE)
      VICOLORS="white"
      VIMODE="⤚➻ "
      ;;
  esac
  PROMPT='%F{$VICOLORS}$VIMODE%f'
}

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
export LESS_TERMCAP_mb=$'\e[0;31m'
export LESS_TERMCAP_md=$'\e[1;35m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;45;3m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[0;31m'

# Set 256 color terminal and Highlighting
export TERM=xterm-256color
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

