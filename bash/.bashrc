# Source global definitions
if [ -f "/etc/bashrc" ]; then
    . "/etc/bashrc"
fi

# Source aliases
if [ -f "$HOME/.bash_aliases" ]; then
    source "$HOME/.bash_aliases"
fi

# Update PATH
if ! echo ":$PATH:" | grep -q ":$HOME/.local/bin:$HOME/bin:"; then
    PATH="$PATH:$HOME/.local/bin:$HOME/bin"
fi

if ! echo ":$PATH:" | grep -q ":/usr/local/bin:"; then
    PATH="$PATH:/usr/local/bin"
fi

export PATH

if [ -d "$HOME/.bashrc.d" ]; then
    for rc in "$HOME/.bashrc.d/*" ; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Bash completion
if [ -f "/etc/bash_completion" ]; then
    . "/etc/bash_completion"
elif [ -f "/usr/share/bash-completion/bash_completion" ]; then
    . "/usr/share/bash-completion/bash_completion"
fi

# Options
bind "set completion-ignore-case on"

# Git branch indicator with color based on status
git_branch() {
    # Get current branch name (or return if not in a git repo)
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return

    # Colors
    local PURPLE="\001\033[1;35m\002"    # Dirty state/Remote differences
    local GREEN="\001\033[1;32m\002"     # Clean state
    local RESET="\001\033[0m\002"

    # Status indicators
    local indicators=""
    local color=$GREEN

    # Check for unpushed/unpulled changes
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ -n "$remote" ]]; then
        local ahead=$(git rev-list --count $remote..HEAD 2>/dev/null)
        local behind=$(git rev-list --count HEAD..$remote 2>/dev/null)
        [[ $ahead -gt 0 ]] && indicators+="↑$ahead" && color=$PURPLE
        [[ $behind -gt 0 ]] && indicators+="↓$behind" && color=$PURPLE
    fi

    # Check git status
    local untracked=$(git ls-files --others --exclude-standard)
    git diff --quiet HEAD -- 2>/dev/null
    local has_changes=$?

    # Set color based on status
    [[ -n "$untracked" || $has_changes -ne 0 ]] && color=$PURPLE

    # Output formatted branch indicator with status
    echo -e "${color}(git:$branch${indicators})${RESET}"
}

# Main prompt
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$(git_branch)$ "

# Tools
# Go
if ! echo ":$PATH:" | grep -q ":$HOME/go/bin:/usr/local/go/bin:"; then
	export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin"
fi

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# Bun
export BUN_INSTALL="$HOME/.bun"

if ! echo ":$PATH:" | grep -q ":$BUN_INSTALL/bin:"; then
	export PATH="$PATH:$BUN_INSTALL/bin"
fi

# Flatpak exports
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share

# SSH Agent
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
