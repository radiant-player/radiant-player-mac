#!/usr/bin/env bash

# Determine the release type
case $1 in
major)
  release_type="major"
  ;;
minor)
  release_type="minor"
  ;;
patch)
  release_type="patch"
  ;;
*)
  echo "Usage: $0 [major|minor|patch]" 1>&2
  exit 2
esac

# Check that git is up to date
if ! "`dirname $0`/check-git.sh"; then
  exit 1
fi

# Check for the required plist
if [ ! -f $PWD/radiant-player-mac/info.plist ]; then
  echo "Please run $(basename $0) from the root of the project" 1>&2
  exit 1
fi

# Read the current version
current_version="$(defaults read $PWD/radiant-player-mac/info.plist CFBundleVersion)"
if [ -z "$current_version" ]; then
  echo "Error: cannot read current version" 1>&2
  exit 1
fi

# Extract the version components
major=$(echo "$current_version" | awk -F '.' '{print $1}')
minor=$(echo "$current_version" | awk -F '.' '{print $2}')
patch=$(echo "$current_version" | awk -F '.' '{print $3}')

# Build the new version
case $release_type in
major)
  major=$(( $major + 1 ))
  minor=0
  patch=0
  ;;
minor)
  minor=$(( $minor + 1 ))
  patch=0
  ;;
patch)
  patch=$(( $patch + 1 ))
  ;;
esac
new_version="$major.$minor.$patch"

# Check with the user
echo "New version will be $new_version:" 1>&2
echo "  - version will be bumped in radiant-player-mac/info.plist" 1>&2
echo "  - changelog items in [unreleased] will be tagged with new release" 1>&2
echo "  - changes will be committed to git" 1>&2
echo "  - a git tag named v$new_version will be created and pushed" 1>&2
echo -n "Continue? (y/N) " 1>&2
read answer
if [[ ! "$answer" =~ (y|Y|yes) ]]; then
  exit 0
fi

# Check for an existing CHANGELOG entry
changelog_script="$(dirname $0)/changelog.sh"
existing_changelog="$($changelog_script $new_version 2>/dev/null)"
if [ ! -z "$existing_changelog" ]; then
  echo -n "CHANGELOG already has an entry for this version - continue? (y/N) " 1>&2
  read answer
  if [[ ! "$answer" =~ (y|Y|yes) ]]; then
    exit 0
  fi
fi

# Check for the existence of an [unreleased] CHANGELOG entry
if ! grep -Fxq '## [unreleased]' CHANGELOG.md; then
  echo -n "CHANGELOG is missing [unreleased] and will not be updated - continue? (y/N) " 1>&2
  read answer
  if [[ ! "$answer" =~ (y|Y|yes) ]]; then
    exit 0
  fi
fi

# Update the plist version
defaults write $PWD/radiant-player-mac/info.plist CFBundleVersion $new_version
defaults write $PWD/radiant-player-mac/info.plist CFBundleShortVersionString $new_version
plutil -convert xml1 $PWD/radiant-player-mac/info.plist

# Update the CHANGELOG
perl -i -pe "s/## \[unreleased\]/## [unreleased]\n\n## [$new_version]/" CHANGELOG.md

# Update git and show changes
git add -A
echo "Proposed changes:" 1>&2
git diff --staged
echo -n "Continue? (y/N) " 1>&2
read answer
if [[ ! "$answer" =~ (y|Y|yes) ]]; then
  exit 0
fi

git commit -m "v$new_version" > /dev/null
git tag -a v$new_version -m "v$new_version" > /dev/null

echo "Created new git tag:" 1>&2
echo "v$new_version"
