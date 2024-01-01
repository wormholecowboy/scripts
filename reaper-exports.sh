#!/bin/zsh
#
# SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
DIR=/Users/briangildea/reaper-files/reaper-auto-export/
export PATH=/Users/briangildea/.nvm/versions/node/v20.7.0/bin:/Users/briangildea/.nvm/versions/node/v20.7.0/bin:/Users/briangildea/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Users/briangildea/.nvm/versions/node/v20.7.0/bin:/Users/briangildea/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/fzf/bin:/opt/stylua:/usr/local/lf:/usr/local/go/bin:/opt/stylua:/usr/local/lf:/usr/local/go/bin
 
for FILE in "$DIR"/*; do
    if [[ -f "$FILE" && "$FILE" == *.mp3 ]]; then
        BASENAME=$(basename "$FILE")
        FILENAME=${BASENAME%.mp3}
        DIR_PATH=$(dirname "$FILE")
        PARENT_DIR=$(basename "$DIR_PATH")
        MONTH_YEAR=$(date +%Y-%m)
        YEAR=$(date +%Y)
        id3v2 -a "The Keeper" "${FILE}"
        id3v2 -A "$MONTH_YEAR" "${FILE}"
        id3v2 -t "$FILENAME" "${FILE}"
        id3v2 -g "sketches" "${FILE}"
        id3v2 -y "$YEAR" "${FILE}"
        eyed3 --add-image=/Users/briangildea/scripts/tkod.png:FRONT_COVER "$FILE"
        sleep 3
        # cp "${FILE}" ~/Music/Music/Media.localized/0-sketches/
    fi
done

python3 /Users/briangildea/scripts/reaper-exports.py
