#!/usr/bin/env bash

if [[ "$TRAVIS_PULL_REQUEST" != "false"  && "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Skipping deploy - this is not master"
  exit 0
fi

cd website/_site

git init

git config user.name "${GITHUB_BOT_USER}"
git config user.email "${GITHUB_BOT_EMAIL}"

git add .
git commit -m "Deploy to GitHub Pages - $(date -u +%FT%TZ)"

git push --force --quiet "https://${GITHUB_TOKEN}@github.com/$GITHUB_USER/$GITHUB_REPO" master:gh-pages > /dev/null 2>&1
