#!/usr/bin/env bash

export HISTCONTROL=100000
export HISTSIZE=100000
shopt -s histappend
shopt -s cmdhist
export HISTTIMEFORMAT='%F %T'
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

set -o vi

__prompt_main() {
  export VIRTUAL_ENV_DISABLE_PROMPT=1
  export PS1='\[\e[0;31m\]$(__ps1_string)\[\e[0m\]'
  export PS2='\[\e[0;31m\]$(__ps2_string)\[\e[0m\]'
}

__ps1_string() {  # a reasonably attractive and informative prompt
    printf '%s%s@%s %s%s $ ' \
        "$(__venv_block)" \
        "$(whoami)" \
        "$(hostname)" \
        "$(__working_directory)" \
        "$(__git_working_branch)"
}

__ps2_string() {  # pad continuing lines with spaces to bring alignment
    local -r text="$(__ps1_string)"
    local -r length="$(( "$(__length "$text")" - 2 ))"

    printf "%-${length}s> "
}

__venv_block() {
    [[ -n "$VIRTUAL_ENV" ]] && printf "%s║" "$(basename "$VIRTUAL_ENV")"
}

__working_directory() {  # the barest minimum of local position information
    local -r wd="$(pwd | sed -E "s/^\/(Users|home)\/${USER}/~/")"
    # printf "%s" "$wd"
    printf "%s" "$(basename "$wd")"
}

__git_working_branch() {  # just wanna know which branch in a consistent way
    local -r gb="$(git branch 2>/dev/null | grep '^\*' | tr -d '*' | __chomp)"
    [[ -n "$gb" ]] && printf "║%s" "$gb"
}

__chomp() {  # remove whitespace
    if (( ${#} == 0 )); then
        while read -r line; do
            echo "${line}" | tr -d '[:space:]'
        done
    else
        echo "${@}" | tr -d '[:space:]';
    fi
}

__length() {  # visible length of a string
    local -r text="${1:-}";
    echo -n "${#text}";
}

__prompt_main
