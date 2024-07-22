#!/bin/bash

select_service() {
  service_list=("glue" "lambda" "s3")
  selected_service=$(printf "%s\n" "${service_list[@]}" | fzf --prompt "Select a service: " | xargs)
  case "$selected_service" in
    glue) select_glue_job
    ;;
    lambda) select_lambda
    ;;
    s3) get_s3_bucket
    ;;
  esac
  
}

select_glue_job() {
  response=$(aws glue list-jobs --max-results 100)
  next_token=$(echo "$response" | jq -r '.NextToken // empty')

  while [ -n "$next_token" ]; do
      response=$(aws glue list-jobs --max-results 100 --next-token "$next_token")
      next_token=$(echo "$response" | jq -r '.NextToken // empty')
  done

  res_formatted=$(echo "$response" | jq -r '.JobNames[]')
  selected_job=$(echo "$res_formatted" | fzf --prompt "Select a glue job: " | xargs)
  get_last_glue_log "$selected_job"

}

get_last_glue_log() {
    glue_url="/aws-glue/python-jobs/output"
    JOB_IDS=$(aws glue get-job-runs --job-name "$1" --query 'JobRuns[0].Id' --output text)
    JOB_ID=$(echo $JOB_IDS | tr ' ' '\n' | head -n 1)
    echo "$JOB_ID"
    aws logs get-log-events --log-group-name "$glue_url" --log-stream-name "$JOB_ID"
    # log_stream=$(aws logs describe-log-streams --log-group-name "$glue_url" --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text)
    # aws logs get-log-events --log-group-name "$glue_url" --log-stream-name "$log_stream" --query "events[*].[timestamp,message]" | jq
}

# Function to list AWS Lambdas and select one using fzf
select_lambda() {
    lambda_list=$(aws lambda list-functions --query "Functions[*].FunctionName")
    lambda_list_formatted=$(echo "$lambda_list" | sed -e 's/,//' -e 's/"//g')
    selected_lambda=$(echo "$lambda_list_formatted" | fzf --prompt "Select a Lambda function: " | xargs)
    if [ -z "$selected_lambda" ]; then
        echo "No Lambda function selected. Exiting."
        exit 1
    fi
    get_last_lambda_log "$selected_lambda" | fzf
}

get_last_lambda_log() {
    lambda_url="/aws/lambda/$1"
    log_stream=$(aws logs describe-log-streams --log-group-name "/aws/lambda/$1" --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text)
    aws logs get-log-events --log-group-name "/aws/lambda/$1" --log-stream-name "$log_stream" --query "events[*].[timestamp,message]" | jq
}

get_s3_bucket() {
  selected_bucket=$(aws s3 ls | awk '{print $3}' | fzf --prompt "Select a bucket: ")
  # objects=$(aws s3 ls "s3://$selected_bucket/" --recursive)
  # selected_object=$(echo "$objects" | fzf --prompt="Select a subfolder: ")
  prefix=""
  while true; do
    folder=$(list_dirs "$selected_bucket" "$prefix")
    echo "prefix: $prefix"
    echo "folder: $folder"
    sleep 7
    if [[ -z "$folder" ]]; then
      echo "loop ended"
      break
    fi
    prefix="${prefix}${folder}"
  done

  final_url="s3://${selected_bucket}/${prefix}"
  echo "This will be the final url: ${final_url}"

  file_to_copy=$(ls | awk '{print #7}' | fzf) 
}

list_dirs() {
  local bucket=$1
  local prefix=$2

  aws s3 ls "s3://${bucket}/${prefix}" | grep PRE | sed 's/.*PRE \(.*\)/\1/' | fzf --prompt="Select folder to build URL (ESC to finish): "
}

# Main script logic
select_service
