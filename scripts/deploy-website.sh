#!/usr/bin/env bash

if [[ "$TRAVIS_PULL_REQUEST" != "false"  && "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Skipping deploy - this is not master"
  exit 0
fi

cd website

git init

git config user.name "${GH_USER}"
git config user.email "${GH_EMAIL}"

git add .
git commit -m "Deploy to GitHub Pages"

git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1
