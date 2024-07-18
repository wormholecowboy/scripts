#!/bin/bash

select_service() {
  service_list=("glue" "lambda" "ec2")
  selected_service=$(printf "%s\n" "${service_list[@]}" | fzf --prompt "Select a service: " | xargs)
  case "$selected_service" in
    glue) select_glue_job
    ;;
    lambda) select_lambda
    ;;
    s3) echo "s3"
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
    echo $JOB_ID
    aws logs get-log-events --log-group-name $glue_url --log-stream-name $JOB_ID
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

# Main script logic
select_service









# QUERY_ID=$(aws logs start-query \
#  --profile $profile \
#  --log-group-name /aws/lambda/test_client_getall_api_rds_lambda_function \
#  --start-time `date --date='-60 minutes' "+Y-%m-%dT%H:%M:%S"` \
#  --end-time `date "+%s"` \
#  --query-string 'fields @message filter @message like /ERROR/' \
#  | jq -r '.queryId')
#  
# echo "Query started (query id: $QUERY_ID), please hold ..." && sleep 5 # give it some time to query
# aws logs --profile $profile logs get-query-results --query-id $QUERY_ID
