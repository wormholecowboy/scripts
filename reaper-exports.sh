#!/bin/bash
#
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

for FILE in "$SCRIPT_DIR"/*; do
    if [[ -f "$FILE" && "$FILE" == *.mp3 ]]; then
        BASENAME=$(basename "$FILE")
        FILENAME=${BASENAME%.mp3}
        DIR=$(dirname "$FILE")
        PARENT_DIR=$(basename "$DIR")
        MONTH_YEAR=$(date +%Y+%m)
        YEAR=$(date +%Y)
        id3v2 -a "The Keeper" "${FILE}"
        id3v2 -A "$MONTH_YEAR" "${FILE}"
        id3v2 -t "$FILENAME" "${FILE}"
        id3v2 -g "sketches" "${FILE}"
        id3v2 -y "$YEAR" ${FILE}"
    fi
done
