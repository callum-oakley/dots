alias h='hx'
alias l='exa'

export EDITOR='hx'
export PATH="${PATH}:/opt/homebrew/opt/python@3.11/libexec/bin"
export PROMPT=$'%F{red}\n%~ $ %f'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh --cmd j)"
