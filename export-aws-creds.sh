#!/bin/bash

output=$(saml2aws script | head -n 3)

while IFS= read -r line; do
    eval "$line"
done <<< "$output"