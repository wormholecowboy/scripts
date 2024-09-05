#!/bin/bash


. ~/scripts/aws-wormhole/s3.sh
. ~/scripts/aws-wormhole/glue.sh
. ~/scripts/aws-wormhole/lambda.sh


check_login() {
  if ! saml2aws script &> /dev/null; then
    echo "You are not logged into AWS. Make sure you are connected to the VPN. "
    sleep 2
    exit 1
  fi
}

select_service() {
  service_list=("glue" "lambda" "s3")
  selected_service=$(printf "%s\n" "${service_list[@]}" | fzf --prompt "Select a service: " | xargs)
  case "$selected_service" in
    "glue") select_glue_job ;;
    "lambda") lambda_main ;;
    "s3") upload_to_s3 ;;
  esac
  
}

check_login
if ! check_login; then return; fi
select_service
