#!/usr/bin/env bash

# Exit on errors

set -e

# Only run on master

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi

# if [[ "$TRAVIS_BRANCH" != "master" ]]; then
#   echo "Testing on a branch other than master. No deployment will be done."
#   exit 0
# fi

if [[ -z "$TRAVIS_TAG" ]]; then
  echo "This is not a tagged commit. No deployment will be done."
  exit 0
fi

# Set up variables

ROOT_PATH="$PWD"
APPNAME="Radiant Player"
RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
CURRENT_VERSION="$(defaults read $PWD/radiant-player-mac/info.plist CFBundleVersion)"
OUTPUTDIR="$PWD/build/Release"
ARCHIVE_PATH="$OUTPUTDIR/app"
PRODUCT_PATH="$ARCHIVE_PATH.xcarchive/Products/Applications"
DSYM_PATH="$ARCHIVE_PATH.xcarchive/dSYMs/$APPNAME.app.dSYM"
APP_ARCHIVE_PATH="$OUTPUTDIR/radiant-player-v$CURRENT_VERSION.zip"

# Check for existing release

set +e
github-release info -u $GITHUB_USER -r $GITHUB_REPO -t v$CURRENT_VERSION > /dev/null
if [ $? -eq 0 ]; then
  echo "ERROR: v$CURRENT_VERSION has already been released - aborting" 1>&2
  exit 1
fi
set -e

# Check for changelog entries

CHANGELOG=`./scripts/changelog.sh $CURRENT_VERSION 2>/dev/null`
if [ -z "$CHANGELOG" ]; then
  echo "ERROR: changelog for v$CURRENT_VERSION is empty - aborting" 1>&2
  exit 1
fi

# Package the app and changelog

mkdir -p $OUTPUTDIR
xctool -workspace radiant-player-mac.xcworkspace -scheme Radiant\ Player archive -archivePath $ARCHIVE_PATH
cd $PRODUCT_PATH
zip -r "$APP_ARCHIVE_PATH" "Radiant Player.app" > /dev/null
cd $ROOT_PATH
./scripts/changelog.sh $CURRENT_VERSION | tail -n +2 > $OUTPUTDIR/changelog.md

# Sign the app

SIGNATURE="$(./scripts/sign-app.sh $APP_ARCHIVE_PATH)"
echo "Archive signature: $SIGNATURE" 1>&2
echo "" >> $OUTPUTDIR/changelog.md
echo "<!-- SPARKLESIG $SIGNATURE -->" >> $OUTPUTDIR/changelog.md

# Create the release

github-release release \
  --user $GITHUB_USER \
  --repo $GITHUB_REPO \
  --tag "v$CURRENT_VERSION" \
  --name "v$CURRENT_VERSION" \
  --description "$(cat $OUTPUTDIR/changelog.md)"

# Upload the finished archive

github-release upload \
  --user $GITHUB_USER \
  --repo $GITHUB_REPO \
  --tag "v$CURRENT_VERSION" \
  --name "$(basename $APP_ARCHIVE_PATH)" \
  --file $APP_ARCHIVE_PATH

# Remove the temporary files

rm -rf $OUTPUTDIR
