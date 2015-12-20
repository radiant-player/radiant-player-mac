/*
 * js/main.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, in order to provide notifications functionality.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

// This check ensures that, even though this script is run multiple times, our code is only attached once.
if (typeof window.gmusic === 'undefined') {
  var gmusic = window.gmusic = new window.GMusic(window);

  gmusic.on('change:rating', function(rating) {
    GoogleMusicApp.ratingChanged(rating);
  });

  gmusic.on('change:song', function(song) {
    console.info('change:song', song.title, song.artist, song.album, song.art, song.duration);
    GoogleMusicApp.notifySong(
      song.title, song.artist, song.album, song.art, song.duration
    );
  });

  gmusic.on('change:shuffle', function(mode) {
    GoogleMusicApp.shuffleChanged(mode);
  });

  gmusic.on('change:repeat', function(mode) {
    GoogleMusicApp.repeatChanged(mode);
  });

  gmusic.on('change:playback', function(mode) {
    console.info('change:playback', mode);
    GoogleMusicApp.playbackChanged(mode);
  });

  gmusic.on('change:playback-time', function(playbackInfo) {
    GoogleMusicApp.playbackTimeChanged(
      playbackInfo.currentTime, playbackInfo.totalTime
    );
  });
}
