#!/usr/bin/env bash

__pip_main() {
  complete -o default -F __pip_autocomplete pip
  complete -o default -F __pip_autocomplete pip3
}


pip.updateall() {
  pip install \
    --upgrade \
    --use-feature=2020-resolver \
    -r <(pip freeze | cut -d '=' -f 1)
}


__pip_autocomplete() {
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}

__pip_main
