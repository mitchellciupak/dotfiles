
# ZSH
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' frequency 13
export LANG=en_US.UTF-8

# ZSH UI
# https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell" 
HIST_STAMPS="yyyy-mm-dd"

# ZSH Plugins
# https://github.com/ohmyzsh/ohmyzsh/wiki/plugins
plugins=(aws copyfile copypath dotenv git kubectl web-search)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Keep below ZSH config
source $ZSH/oh-my-zsh.sh

# Aliases

## Editor
export EDITOR=nvim
export VISUAL="${EDITOR}"
export BROWSER=open
export EDITOR='nvim'
export TERMINAL='ghostty'
export PAGER='less'
export LESS='-~'
alias v=nvim
alias vi=nvim
alias vim=nvim
alias view="nvim -R"
alias vimdiff="nvim -d"

## Nav
alias l='eza --group-directories-first --color=always --icons=always'
alias ls='l'
alias la='l --long --time-style="+%Y-%m-%d %H:%M" --no-user'
alias tree='l --tree'

# Git
alias g='git'
unalias gc 2>/dev/null
gc() { if [[ $# -gt 0 ]]; then git commit -m "$*"; else git commit; fi }
alias gce='git commit --amend'
alias gd='git diff --output-indicator-new=" " --output-indicator-old=" "'

alias gpull='git pull'
alias gnb='git checkout -b'
alias gcout='git checkout'

alias gs='git status --short'
alias gl='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'

alias gp='git push'

## SSH
alias ssh-work="ssh 'mciupa484@10.0.0.216'"
alias ssh-studio="ssh 'mitchellciupak@10.0.0.165'"

## K8s
alias k=kubectl
alias kg="kubectl get"
alias kd="kubectl describe"
alias kl="kubectl logs"

## Docker
killdocker() {
	ps ax|grep -i docker|egrep -iv 'grep|com.docker.vmnetd'|awk '{print $1}'|xargs kill
}

## Search
alias rg="rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim --colors=line:fg:black --colors=line:style:bold --colors=path:fg:magenta --colors=match:style:nobold"

## Passwords / Secrets
newpass() { openssl rand -base64 ${1:-33} }

## Systemd
alias sd='sudo systemctl'
alias sdu='systemctl --user'
alias jd='journalctl --no-pager'

## OpenCode
alias oc='opencode'
whatcmd() {
  local task="$*"
  local result
  result=$(oc run -m github-copilot/gpt-5-mini \
    "You are a CLI command builder. Given a task description, output only the exact command to run it.

Rules:
1. output only one command to run. 
2. output the best one
3. prefer single-line commands; use && or pipes where appropriate
4. flags should be explicit and readable (prefer --long-form over -x where practical)

Task: ${task}")
  echo "$result"
  echo "$result" | pbcopy
}

# Enironmental Variables

## Rancher
export PATH="/Users/mciupa484@cable.comcast.com/.rd/bin:$PATH"

## AWS
export AWS_REGION=us-east-1
export AWS_PROFILE=ApplicationOwner@476134988768
export AWS_DEFAULT_OUTPUT="json"
export AWS_PAGER="less -FRSX"