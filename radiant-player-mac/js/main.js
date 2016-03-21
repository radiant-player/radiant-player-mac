/*
 * js/main.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, in order to provide notifications functionality.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.gmusic === 'undefined') {
  var gmusic = window.gmusic = new window.GMusic(window);

  // Hook into parent app

  var DEBUG = false;
  var VERBOSE = false;

  gmusic.on('change:song', function(song) {
    if (DEBUG) console.info('change:song', arguments);
    GoogleMusicApp.notifySong(
      song.title, song.artist, song.album, song.art, song.duration
    );
  });

  gmusic.on('change:shuffle', function(mode) {
    if (DEBUG) console.info('change:shuffle', arguments);
    GoogleMusicApp.shuffleChanged(mode);
  });

  gmusic.on('change:repeat', function(mode) {
    if (DEBUG) console.info('change:repeat', arguments);
    GoogleMusicApp.repeatChanged(mode);
  });

  gmusic.on('change:playback', function(mode) {
    if (DEBUG) console.info('change:playback', arguments);
    GoogleMusicApp.playbackChanged(mode);
  });

  gmusic.on('change:playback-time', function(info) {
    if (DEBUG && VERBOSE) console.info('change:playback-time', arguments);
    GoogleMusicApp.playbackTimeChanged(info.current, info.total);
  });

  gmusic.on('change:rating', function (rating) {
    if (DEBUG) console.info('change:rating', arguments);
    GoogleMusicApp.ratingChanged(rating);
  });
}
