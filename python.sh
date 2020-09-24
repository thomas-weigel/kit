#!/usr/bin/env bash

__py_main() {
  complete -o default -F __pip_autocomplete pip
  complete -o default -F __pip_autocomplete pip3
}


py.outline() {
  local -r docs="${1:-}"
  if [[ -n $docs ]]; then
    if [[ $docs == '--docs' ]]; then
      shift;
      __py.outline_with_docs $@
    fi
  else
    __py.outline_without_docs $@
  fi
}


__py.has_ripgrep() {
  [[ -n "$(which rg)" ]]
}


__py.outline_without_docs() {
  if __py.has_ripgrep; then
    rg \
      --type py \
      --sort path \
      --no-line-number \
      --colors match:fg:black \
      --colors match:style:nobold \
      --colors path:style:bold \
      --colors path:style:underline \
      '^ *(@|class|def)\b' \
      $@  # any additional arguments you want to pass in
  else
    echo "This is better with ripgrep. Consider installing:"
    echo "https://github.com/BurntSushi/ripgrep#installation"
    for pfile in $(find . -iname '*.py'); do
      echo
      echo -e "\e[1m\e[4m${pfile}\e[0m"
      grep -h --extended-regexp '^ *(@|class|def)\b' $pfile
    done
  fi
}


__py.outline_with_docs() {
  if ! __py.has_ripgrep; then
    echo "Unable to parse docstrings with ordinary grep."
    echo "Consider installing:"
    echo "https://github.com/BurntSushi/ripgrep#installation"
    return 1;
  fi
  rg \
    --type py \
    --sort path \
    --no-line-number \
    --multiline \
    --colors match:fg:black \
    --colors match:style:nobold \
    --colors path:style:bold \
    --colors path:style:underline \
    "^ *((@|class|def).+?$|\"\"\"\p{any}*?\"\"\"|'''\p{any}*?''')" \
    $@  # any additional arguments you want to pass in
}


__pip_autocomplete() {
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}

__py_main
