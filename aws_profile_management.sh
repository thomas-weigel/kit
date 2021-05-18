#!/usr/bin/env bash

__aws_profile_main() {
    complete -F aws_profilecompleter aws.profile
}


aws.profile() {  # Sets AWS_PROFILE and/or logs you into AWS SSO
    # Intended to be slightly easier than exporting AWS_PROFILE bare, especially
    # when AWS Single-Sign On services are in use. Also double-checks that the
    # credentials profile exists.

    local profile="${1:-help}"
    local sso="${2:-}"

    # swap order if needed so we know what to expect from each variable
    if [[ $profile == "--sso" || $profile == "-s" ]]; then
        profile="$sso"
        sso="--sso"
    fi

    if [[ $profile == "help" || $profile == "--help" || $profile == "-h" ]]; then
        echo "aws.profile [-s|--sso] PROFILE"
        echo "You can use aws.ls to list the profiles available to you."
        echo "-s|--sso  tells the system to try to log you in via AWS single-sign on."
        (exit 0)
    fi

    local profile_exists="false"
    for p in $(aws.ls); do
        if [[ $p == $profile ]]; then
            export AWS_PROFILE="${profile}"
            profile_exists="true"
            if [[ $sso == "--sso" || $sso == "-s" ]]; then
                aws --profile "$profile" sso login
            fi
            break
        fi
    done

    if [[ $profile_exists == "false" ]]; then
        echo "Profile ${profile} not found. 'aws.ls' to list available profiles."
        (exit 1)
    fi
}


aws.ls() {  # lists AWS configured profiles
    local -r subset="${1:-}"
    if [[ $subset == "work" ]]; then
        grep -E '^\[' ~/.aws/config \
          | tr -d '[' | tr -d ']' \
          | cut -d ' ' -f 2 \
          | grep -v default | sort \
          | grep -vE '(tiamat|jwoolfe)'
    elif [[ $subset == "personal" ]]; then
        grep -E '^\[' ~/.aws/config \
          | tr -d '[' | tr -d ']' \
          | cut -d ' ' -f 2 \
          | grep -v default | sort \
          | grep -E '(tiamat|jwoolfe)'
    else
        grep -E '^\[' ~/.aws/config \
          | tr -d '[' | tr -d ']' \
          | cut -d ' ' -f 2 \
          | grep -v default | sort
    fi
}


aws_profilecompleter() {
    local partial=$2  # the portable and trustworthy value from bash `complete`
    local commands=($(aws.ls))

    local word=
    for word in "${commands[@]}"; do
        [[ "$word" =~ ^$partial ]] && COMPREPLY+=("$word")
    done
}

__aws_profile_main
