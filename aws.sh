#!/bin/bash

select_service() {
  service_list=("glue" "lambda" "ec2")
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
}

# Function to get the most recent logs for a selected Lambda
get_lambda_logs() {
    temp="/aws/lambda/$1"
    echo "temp: $temp"
    log_stream=$(aws logs describe-log-streams --log-group-name "/aws/lambda/$1" --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text)
    aws logs get-log-events --log-group-name "/aws/lambda/$1" --log-stream-name "$log_stream" --query "events[*].[timestamp,message]" | jq
}

# Main script logic
select_lambda
get_lambda_logs "$selected_lambda"









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
