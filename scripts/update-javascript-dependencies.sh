#!/usr/bin/env bash
set -e

echo "Running 'npm install'"
npm install

echo "Running 'npm update'"
npm update

echo "Copying 'gmusic.js' into 'radiant-player-mac/js'"
cp node_modules/gmusic.js/dist/gmusic.js ./radiant-player-mac/js/
