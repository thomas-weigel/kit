#!/usr/bin/env bash

venv.main() {
  mkdir -p "${HOME}/.venv"
  complete -F venv.complete venv
  complete -F venv.complete venv.repair
  complete -F venv.complete venv.rm
}


venv() {
  local -r name="${1:-}"
  local -r path="$(venv.path $name)"
  if [[ -f "${path}" ]]; then
    source "$path"
  else
    echo "ERROR: No virtualenv found under the name '${name}'." >&2
    (exit 1)
  fi
}


venv.ls() {
  local name=""
  local path=""
  for name in $(ls -1p "${HOME}/.venv/" | grep '/' | tr -d '/'); do
    venv.validate $name && echo "$name"
  done | sort
}


venv.mk() {
  pushd "${HOME}/.venv/" >/dev/null 2>&1;
    virtualenv --python "python3.8" $@;
  popd >/dev/null 2>&1;
}


venv.repair() {
  local -r name="${1:-}"
  if [[ -z "$name" ]]; then
    echo "No virtualenv name given." >&2
    return 1
  fi
  if ! venv.validate $name; then
    echo "No virtualenv named '${name}'." >&2
    return 1
  fi

  pushd "${HOME}/.venv" >/dev/null 2>&1
    find "$(venv.dir $name)" -type l -delete
    echo "repairing..."
    virtualenv --python "python3.8" "${name}"
  popd >/dev/null 2>&1
}


venv.rm() {
  local -r name="${1:-}"
  if [[ -z "$name" ]]; then
    echo "No virtualenv name given." >&2
    return 1
  fi
  if ! venv.validate $name; then
    echo "No virtualenv named '${name}'." >&2
    return 1
  fi

  pushd "${HOME}/.venv" >/dev/null 2>&1
    cd "$name" && printf "About to delete $(pwd)" && cd ..
    for i in {1..10}; do
      sleep 0.2 && printf "."
    done
    printf "Deleting.\n"
    rm -rf $name
  popd >/dev/null 2>&1
}


venv.path() {
  local -r name="${1:-}"
  echo "$(venv.dir $name)/bin/activate"
}


venv.dir() {
  local -r name="${1:-}"
  echo "${HOME}/.venv/${name}"
}


venv.validate() {
  local -r name="${1:-}"
  [[ -f "$(venv.path $name)" ]]
}


venv.complete() {
  local partial=$2  # the portable and trustworthy value from bash `complete`
  local commands=($(venv.ls))

  local word=
  for word in "${commands[@]}"; do
    [[ "$word" =~ ^$partial ]] && COMPREPLY+=("$word")
  done
}


venv.main
