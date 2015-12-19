#!/bin/bash
set -e
set -o pipefail

openssl=/usr/bin/openssl

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 archive" 1>&2
  exit 1
fi

if [ -z "$KEY_PASSWORD" ]; then
  if [ ! -f keys/private.pem ]; then
    echo "Error: please set KEY_PASSWORD" 1>&2
    exit 1
  else
    echo "Warning: KEY_PASSWORD not set, however private key exists - continuing" 1>&2
  fi
fi

if [ ! -f keys/private.pem ]; then
  $openssl aes-256-cbc -d -salt -pass env:KEY_PASSWORD -in keys/private-encrypted.pem -out keys/private.pem
fi

$openssl dgst -sha1 -binary < "$1" | $openssl dgst -dss1 -sign "keys/private.pem" | $openssl enc -base64
