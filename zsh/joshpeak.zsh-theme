NL=$'\n'
PROMPT='%{$fg[cyan]%}%~%{$reset_color%}$(git_prompt_info)'
PROMPT+="%(?:%{$fg_bold[green]%}${NL}λ :%{$fg_bold[red]%}${NL}λ )"

ZSH_THEME_GIT_PROMPT_PREFIX="${NL}%{$fg_bold[blue]%}⎇  %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
