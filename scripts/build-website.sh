#!/usr/bin/env bash
set -e

cd website
bundle exec jekyll build
bundle exec htmlproof ./_site --href-ignore '#'
