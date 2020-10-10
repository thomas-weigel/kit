#!/usr/bin/env bash

__aws_main() {
  complete -C aws_completer aws
}


aws.ls() {  # lists AWS configured profiles
  grep -E '^\[' ~/.aws/config | tr -d '[' | tr -d ']' | cut -d ' ' -f 2 | grep -v default | sort
}


aws.ls-ec2-names() {  # lists available Name tags in EC2 for current AWS profile
  aws ec2 describe-instances \
    --query "Reservations[].Instances[?State.Name == 'running'].Tags[][?Key == 'Name'].Value" \
    --output text
}


aws.ec2-by-name() {  # finds an EC2 instance by its Name tag
  local name="${1:-}"
  if [[ -z $name || $name == "help" ]]; then
    echo "Usage: aws.ec2-by-name INSTANCE_TAG_NAME"
    (exit 1)
  fi

  aws ec2 describe-instances \
    --filter "Name=tag:Name,Values=${name}" \
    --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" \
    --output text
}


aws.ssm() {  # connect to an EC2 instance via SSM by its Name tag
  local name="${1:-}"
  local instance="$(aws.ec2-by-name $name)" || (exit 1)
  if [[ -z $instance ]]; then
    echo "No instance available by the name ${name}."
    (exit 1)
  fi

  aws ssm start-session --target $instance
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

  if [[ $profile == "help" ]]; then
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


__aws_main
