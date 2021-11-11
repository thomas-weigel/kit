#!/usr/bin/env bash

aws.org_table() {
  if ! __org_python_version; then
    echo "No Python3 + boto3 installed, falling back to AWS CLI."

    for root in $(aws.org_roots); do
      echo "${root} --"
      local top_accounts="no"
      for top_acct in $(aws.org_accounts $root); do
        echo "$(aws.org_account_name $top_acct)"
        top_accounts="yes"
      done
      [[ "$top_accounts" == "yes" ]] && echo  # add a spacer if there were any

      notfirst="no"
      for ou in $(aws.org_ous $root); do
        [[ "$notfirst" == "yes" ]] && echo  # spacer before each except the first
        echo "$(aws.org_ou_name $ou)"
        for acct in $(aws.org_accounts $ou); do
          echo "  $(aws.org_account_name $acct)"
        done
        notfirst="yes"
      done
    done
  fi
}


__org_python_version() {  # runs significantly faster than the pure AWS CLI version
  local -r script_dir="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
  python3 "${script_dir}/aws_org.py" 2>/dev/null
  # Note: we don't care about failures, really — we will just fallback to the
  # pure AWS CLI version
}


aws.org_roots() {
  aws organizations list-roots \
    --output text \
    --query "Roots[].Id"
}


aws.org_ous() {
  local -r root="${1:-}"
  aws organizations list-children \
    --parent-id $root \
    --child-type ORGANIZATIONAL_UNIT \
    --output text \
    --query "Children[].Id"
}


aws.org_ou_name() {
  local -r ou="${1:-}"
  aws organizations describe-organizational-unit \
    --organizational-unit-id $ou \
    --output text \
    --query "OrganizationalUnit.[Name,Id]" \
    | awk -F '\t' '{ print $1 " -- " $2 }'
}


aws.org_accounts() {
  local -r ou="${1:-}"
  aws organizations list-children \
    --parent-id $ou \
    --child-type ACCOUNT \
    --output text \
    --query "Children[].Id"
}


aws.org_account_name() {
  local -r account="${1:-}"
  aws organizations describe-account \
    --account-id $account \
    --output text \
    --query "Account.[Name,Id,Email]" \
    | awk -F '\t' '{ print $1 " (" $2 " -- " $3 ")" }'
}
