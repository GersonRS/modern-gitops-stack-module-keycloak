#!/bin/bash

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  command -v openssl >/dev/null 2>&1 || error_exit "openssl command not detected in path, please install it"
}

function parse_input() {
  # Read JSON from stdin and parse without jq
  input=$(cat)
  # Extract cert value using basic string manipulation
  CERT=$(echo "$input" | sed -n 's/.*"cert":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g')
  if [[ -z "${CERT}" ]]; then 
    export CERT=none
  else
    export CERT
  fi
}

function produce_output() {
  if [[ "${CERT}" == "none" ]]; then
    echo '{"fingerprint":"N/A"}'
    return
  fi
  
  # Create temporary file for certificate
  temp_cert=$(mktemp)
  echo -e "$CERT" > "$temp_cert"
  
  # Generate fingerprint
  fingerprint=$(openssl x509 -noout -fingerprint -sha1 -in "$temp_cert" 2>/dev/null || echo "SHA1 Fingerprint=N/A")
  
  # Clean up
  rm -f "$temp_cert"
  
  # Output JSON without jq
  echo "{\"fingerprint\":\"$fingerprint\"}"
}

check_deps
parse_input
produce_output
