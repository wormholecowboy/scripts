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
    glue_base_url="/aws-glue/python-jobs/"
    log_type=$(printf "output\nerror" | fzf --prompt "Pick error or output logs: ")
    glue_final_url="$glue_base_url$log_type"
    JOB_IDS=$(aws glue get-job-runs --job-name "$1" --query 'JobRuns[0].Id' --output text)
    JOB_ID=$(echo $JOB_IDS | tr ' ' '\n' | head -n 1)
    echo "$JOB_ID"
    aws logs get-log-events --log-group-name "$glue_final_url" --log-stream-name "$JOB_ID" --start-from-head | jq | less
    # log_stream=$(aws logs describe-log-streams --log-group-name "$glue_url" --order-by LastEventTime --descending --limit 1 --query "logStreams[0].logStreamName" --output text)
    # aws logs get-log-events --log-group-name "$glue_url" --log-stream-name "$log_stream" --query "events[*].[timestamp,message]" | jq
}
