#!/usr/bin/env bash
set -e

cd website
bundle exec jekyll build
bundle exec htmlproofer ./_site --allow-hash-href
