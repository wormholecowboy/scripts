selected_lambda=""

select_lambda() {
    lambda_list=$(aws lambda list-functions --query "Functions[*].FunctionName")
    lambda_list_formatted=$(echo "$lambda_list" | sed -e 's/,//' -e 's/"//g')
    selected_lambda=$(echo "$lambda_list_formatted" | fzf --prompt "Select a Lambda function: " | xargs)
    if [ -z "$selected_lambda" ]; then
        echo "No Lambda function selected. Exiting."
        exit 1
    fi
}

get_last_lambda_log() {
    select_lambda
    log_group_name="/aws/lambda/$selected_lambda"
    log_stream=$(aws logs describe-log-streams --log-group-name "$log_group_name" --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text)
    aws logs get-log-events --log-group-name "$log_group_name" --log-stream-name "$log_stream" --query "events[*].[timestamp,message]" | jq | fzf
}

upload_lambda_zip() {
  select_lambda
  lambda_zip_to_upload=$(printf "%s\n" "$(command ls)" | fzf --prompt "Pick zip file to upload: ")
  echo "$lambda_zip_to_upload this is not usable yet!"
  sleep 2
# aws lambda update-function-code --function-name "$selected_lambda" --zip-file "$lambda_zip_to_upload"
}


lambda_main() {
  selected_lambda_service=$(printf "Upload Zip\nGet Logs" | fzf --prompt "Pick Lambda Service: ")

  case "$selected_lambda_service" in
    "Get Logs")
      get_last_lambda_log;;
    "Upload Zip")
      upload_lambda_zip;;
  esac
}
