#!/usr/bin/env bash

aws.ec2() {
    local -r command="${1:-}"

    case $command in
        ls)
            local region="${2:-$(aws.region)}"

            aws ec2 describe-instances \
              --region $region \
              --query "Reservations[].Instances[?State.Name == 'running'].Tags[][?Key == 'Name'].Value" \
              --output text
            ;;
      ssm)
          local name="${2:-}"
          local region="${3:-$(aws.region)}"
          aws.ssm $name $region
          ;;
      *)
          echo 'aws.ec2 ls            lists names of ec2 instances in current region'
          echo 'aws.ec2 ls $region    as above, for given region'
          echo 'aws.ec2 ssm $name     attempts to connect via SSM to named ec2 instance'
          echo 'aws.ec2 ssm $name $region   as above, for given region'
          ;;
    esac
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
    local region="${2:-$(aws.region)}"

    local instance="$(
        aws ec2 describe-instances \
          --output text \
          --region $region \
          --filter "Name=tag:Name,Values=${name}" \
          --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]"
    )" || (exit 1)

    local instance="$(aws.ec2-by-name $name)" || (exit 1)
    if [[ -z $instance ]]; then
        echo "No instance available by the name ${name}."
        (exit 1)
    fi

    aws ssm start-session --target $instance
}
