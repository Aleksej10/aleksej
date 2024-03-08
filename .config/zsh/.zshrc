CASE_SENSITIVE="true" 
DISABLE_AUTO_UPDATE="true"
autoload -U colors && colors


setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    ' %F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats       \
    ' %F{5}[%F{2}%b%F{5}]%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}

PS1='%F{red}%~$(vcs_info_wrapper) %f'
PS2='%_> '
PS3='?# '
PS4='+%N:%i> '
RPROMPT='%10(d.%9(D.always.).)'
SPROMPT='correct '\''%R'\'' to '\''%r'\'' [nyae]? '


set -o vi

## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.
setopt interactive
setopt kshglob
setopt nonomatch
setopt numericglobsort
setopt promptsubst
setopt sharehistory

autoload -U compinit
zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':autocomplete:tab:*' widget-style menu-select
zstyle ':autocomplete:tab:*' fzf-completion yes
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:*' completer _expand _complete _ignored # enable approximate matches for completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zmodload zsh/complist
compinit

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.config/zsh/history"
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word


## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

#edit line in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init


# Use lf to switch directories
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

bindkey -s '^f' 'lfcd\n'  # zsh

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

## Alias section 
alias cp="cp -i"                                                # Confirm before overwriting something
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB
alias gitu='git add . && git commit && git push'
alias ga='git add .'
alias gc='git commit -am'
alias gp='git push'
alias gs='git status'
alias ls='lsd'
alias e='emacsclient -c'
alias vi='nvim'
alias v='neovide --nofork --multigrid'

[ -f "$HOME/.config/shell/secure_db_alias" ] && source "$HOME/.config/shell/secure_db_alias"


# git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"

# Theming section  
autoload -U compinit colors zcalc
compinit -d
colors


## Plugins section: Enable fish style features
# Use syntax highlighting
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
# source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# bind UP and DOWN arrow keys to history substring search
# zmodload zsh/terminfo
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
# bindkey '^[[A' history-substring-search-up			
# bindkey '^[[B' history-substring-search-down

# Offer to install missing package if command is not found
# if [[ -r /usr/share/zsh/functions/command-not-found.zsh ]]; then
#     source /usr/share/zsh/functions/command-not-found.zsh
#     export PKGFILE_PROMPT_INSTALL_MISSING=1
# fi

# xmodmap $HOME/.config/x11/Xmodmap
# xset r rate 380 55
# unclutter -b

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
[ -f "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Load zsh-syntax-highlighting; should be last.
source "$HOME/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" 2>/dev/null
source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" 2>/dev/null
# source "$HOME/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" 2>/dev/null

# [ -f "$HOME/.resh/shellrc" ] && source "$HOME/.resh/shellrc" # this line was added by RESH (Rich Enchanced Shell History)

# bun completions
[ -f "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
