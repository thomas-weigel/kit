#!/usr/bin/env bash

__aws_main() {
    complete -C aws_completer aws
    source ~/bash.d/aws_profile_management.sh
    source ~/bash.d/aws_ec2.sh
    source ~/bash.d/aws_org.sh
}

# What follows are some useful aliases, written as functions for ease of reading
aws.region() {
    aws ec2 describe-availability-zones \
      --output text \
      --query "AvailabilityZones[0].RegionName"
}


aws.accountid() {
    aws sts get-caller-identity \
      --output text \
      --query "Account"
}


aws.whoami() {
    aws sts get-caller-identity \
      --output text \
      --query "Arn"
}


__aws_main
