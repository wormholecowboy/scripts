#!/bin/bash

if ! saml2aws login; then
  echo "\n"
  echo "\n"
  echo "ERROR: Check password/user and make sure you are connected to the VPN."
  sleep 4
  exit 1
fi

output=$(saml2aws script | head -n 3)
if [ $? -ne 0 ] || [ -z "$output" ]; then
  echo "\n"
  echo "\n"
  echo "Error: Failed to generate output from saml2aws script."
  sleep 4
  exit 1
fi

while IFS= read -r line; do
    eval "$line"
done <<< "$output"
echo
echo
echo "NOTE: Successfully exported AWS variables"
