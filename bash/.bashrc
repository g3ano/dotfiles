# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# System wide specific environment
if ! [[ "$PATH" =~ "/usr/local/bin:" ]]; then
    PATH="/usr/local/bin:$PATH"
fi

export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Load aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Options
bind "set completion-ignore-case on"

# Git branch indicator
# with color based on status
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
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

