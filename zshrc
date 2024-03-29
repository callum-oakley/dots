PROMPT=$'%F{red}\n%1~ $ %f'

alias h='hx'
alias l='exa'

export EDITOR='hx'
export RUSTUP_TOOLCHAIN=stable

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

autoload -Uz compinit && compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh --cmd j)"
