#!/bin/bash

# Fast fail the script on failures.
set -e

mkdir -p .pub-cache

cat <<EOF > ~/.pub-cache/credentials.json
{
  "accessToken":"$accessToken",
  "refreshToken":"$refreshToken",
  "tokenEndpoint":"$tokenEndpoint",
  "scopes":["$scopes"],
  "expiration":$expiration
}
EOF

pub publish -f