#!/usr/bin/env bash

# First fetch to ensure git is up to date. Fail-fast if this fails.
git fetch;
if [[ $? -ne 0 ]]; then exit 1; fi;

# Extract useful information.
GITSTATUS=$(git status --porcelain);
GITBRANCH=$(git branch -v 2> /dev/null | sed '/^[^*]/d');
GITBRANCHNAME=$(echo "$GITBRANCH" | sed 's/* \([A-Za-z0-9_\-]*\).*/\1/');
GITBRANCHSYNC=$(echo "$GITBRANCH" | sed 's/* [^[]*.\([^]]*\).*/\1/');

# Check if working directory is clean
if [ ! -z "$GITSTATUS" ]; then
  read -p "Git working directory is not clean. Continue? (y|N) " yn;
  if [ "$yn" != "y" ]; then exit 1; fi;
fi;

# Check if master is checked out
if [ "$GITBRANCHNAME" != "master" ]; then
  read -p "Git not on master but $GITBRANCHNAME. Continue? (y|N) " yn;
  if [ "$yn" != "y" ]; then exit 1; fi;
fi;

# Check if branch is synced with remote
if [ "$GITBRANCHSYNC" != "" ]; then
  read -p "Git not up to date but $GITBRANCHSYNC. Continue? (y|N) " yn;
  if [ "$yn" != "y" ]; then exit 1; fi;
fi;
