#!/usr/bin/env bash

aws.ec2() {
  local -r command="${1:-}"
  shift;

  case $command in
    ls)
      __ec2_names "${1:-}"
      ;;
    id)
      __ec2_id "$@"
      ;;
    vpcs)
      __ec2_vpcs "$@"
      ;;
    ssm)
      __ssm_bash "$@"
      ;;
    update-agent)
      __ssm_update_agent "$@"
      ;;
    port)
      __ssm_port_forward "$@"
      ;;
    proxy)
      __ssm_proxy "$@"
      ;;
    *)
      echo 'aws.ec2 COMMAND ARGUMENTS'
      echo '[$region] is always an optional last argument: defaults to current region'
      echo ''
      echo 'ls                    lists names of EC2 instances in region'
      echo 'id $name              acquire instance ID for EC2 instance by name'
      echo 'vpcs                  table of "VPC -> EC2 instances" for region'
      echo 'ssm $name             connect via SSM to named EC2 instance'
      echo 'update-agent $name    updates the SSM Agent on named EC2 instance'
      echo 'port $name $port      sets up port-forwarding to EC2 instance'
      echo 'proxy $name           sets up an SSH primitive to EC2 instance'
      echo '                      (useful for some opinionated programs)'
      ;;
  esac
}


__ec2_vpcs(){
  local region="${2:-$(aws.region)}"
  aws ec2 describe-instances \
    --region $region \
    --query 'Reservations[].Instances[].{Instance:InstanceId,Instance:VpcId,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output text \
    | sort -u | column -t
}


__ec2_names() {  # get list of Name tags for active EC2 instances
  local -r region="${1:-$(aws.region)}"
  aws ec2 describe-instances \
    --region "$region" \
    --query "Reservations[].Instances[?State.Name=='running'].Tags[][?Key=='Name'].Value" \
    --output text
}


__ec2_id() {  # get Instance ID from Name tag
  local -r name="${1:-}"
  local -r region="${2:-$(aws.region)}"
  aws ec2 describe-instances \
    --filter "Name=tag:Name,Values=${name}" \
    --query "Reservations[].Instances[?State.Name=='running'].InstanceId[]" \
    --output text
}


__ssm_bash() {  # open a bash session on the EC2 instance
  local -r name="${1}"
  local -r region="${2:-$(aws.region)}"
  local -r instance="$(__ec2_id $name)" || (exit 1)

  if [[ -z $instance ]]; then
    echo "No instance available by name '${name}'."
    (exit 1)
  fi

  aws ssm start-session \
    --target "$instance" \
    --document-name AWS-StartInteractiveCommand \
    --parameters 'command="bash"'
}


__ssm_port_forward() {  # opens a port-forwarding session
  local -r name="${1}"
  local -r port="${2}"
  local -r region="${3:-$(aws.region)}"
  local -r instance="$(__ec2_id $name)"

  aws ssm start-session \
    --target "$instance" \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["'${port}'"],"localPortNumber":["'${port}'"]}'
}


__ssm_proxy() {
  local -r name="${1}"
  local -r region="${2:-$(aws.region)}"
  local -r instance="$(__ec2_id $name)"
  aws ssm start-session \
    --target $instance \
    --document-name AWS-StartSSHSession \
    --parameters 'portNumber=22'
}


__ssm_update_agent() {  # update the SSM Agent on the EC2 instance
  local -r name="${1:-}"
  local -r region="${2:-$(aws.region)}"
  local -r instance="$(__ec2_id $name)"
  aws ssm send-command \
    --document-name "AWS-UpdateSSMAgent" \
    --document-version "1" \
    --targets '[{"Key":"InstanceIds","Values":["'$instance'"]}]' \
    --parameters '{"version":[""],"allowDowngrade":["false"]}' \
    --timeout-seconds 600 \
    --max-concurrency "50" \
    --max-errors "0"
}


aws.ls-ec2-names() { __ec2_names; } # LEGACY
aws.ec2-by-name() { __ec2_id "${1:-}"; } # LEGACY
aws.ssm() { __ssm_bash "$@"; } # LEGACY
