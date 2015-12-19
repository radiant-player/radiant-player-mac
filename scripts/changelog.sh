#!/usr/bin/env bash

version=$1

changes="$(cat CHANGELOG.md | sed -n "/^## \[$version\]/,/^## \[/p" | sed '$d' | sed -e 's/[[:space:]]*$//')"

if [ -z "$changes" ]; then
  echo "No entry found" 1>&2
else
  echo "$changes"
fi
