upload_file_to_s3() {
  local url="$1"
  local selected_file=$(printf "%s\n" "$(command ls)" | fzf --prompt "Pick a file to upload: ")
  echo "$selected_file"
  sleep 2
  local formatted_file="./$selected_file"

  if aws s3 cp "$formatted_file" "$url"; then
    echo "File successfully uploaded"
    exit 0
  else
    echo "ERROR: File not uploaded."
    exit 1
  fi
}

sync_foler_to_s3() {
  local url="$1"

  if aws s3 sync . "$url"; then
    echo "Folder successfully synced."
    exit 0
  else
    echo "ERROR: Folder not synced."
    exit 1
  fi
}

build_dir() {
  local bucket=$1
  local prefix=$2
  local folder=""

  folders=$(aws s3 ls "s3://${bucket}/${prefix}" | grep PRE | sed 's/.*PRE \(.*\)/\1/')
  if [[ "$folders" ]]; then
    folder=$(echo "$folders" | fzf --prompt="Select folder to build URL (ESC to finish): ")
    echo "$folder"
  else
    echo "$folder"
    return 1
  fi
}

upload_to_s3() {
  selected_bucket=$(aws s3 ls | awk '{print $3}' | fzf --prompt "Select a bucket: ")
  prefix=""
  while true; do
    folder=$(build_dir "$selected_bucket" "$prefix")
    if  [[ -z "$folder" ]]; then
      break
    fi
    prefix="${prefix}${folder}"
  done

  final_url="s3://${selected_bucket}/${prefix}"
  echo "This will be the final url: ${final_url}"
  sleep 2

  upload_options=("File" "Sync Current Folder")
  selected_s3_upload_option=$(printf "%s\n" "${upload_options[@]}" | fzf --prompt "Select an upload method: " | xargs) 

  case "$selected_s3_upload_option" in
    "File")
      upload_file_to_s3 "$final_url" ;;
    "Sync Current Folder")
      sync_foler_to_s3 "$final_url" ;;
  esac
}
