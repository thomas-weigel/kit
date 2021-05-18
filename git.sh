#!/usr/bin/env bash

git.lastmodified() {  # Returns the last git log date for the given directory
  # This is only moderately useful by itself; its real purpose is to be used in
  # other scripts and command-line fu where you just need the date in a simple
  # format. For example, in my ~/git/ directory, there are a lot of individual
  # git repositories, and I may want to sort them by when they were last
  # updated:
  #
  #     for repo in $(ls -1); do
  #       echo "$(git.lastmodified $repo): ${repo}";
  #     done | sort

  local home="${1:-}"
  local pushed=""
  if [[ -n $home && -d $home ]]; then
    pushd $home >/dev/null 2>&1
    pushed="pushed"
  fi

  git log -1 --date=short \
    | grep '^Date:' \
    | cut -d ':' -f 2 \
    | tr -d ' '

  if [[ $pushed == "pushed" ]]; then
    popd >/dev/null 2>&1
  fi
}
