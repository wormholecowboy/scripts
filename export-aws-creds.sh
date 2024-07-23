#!/bin/bash

if ! saml2aws login; then
  echo "Error: Check password/user and make sure you are connected to the VPN."
  exit 1
fi

output=$(saml2aws script | head -n 3)

while IFS= read -r line; do
    eval "$line"
done <<< "$output"
echo
echo
echo "NOTE: Successfully exported AWS variables"
