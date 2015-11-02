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
if (typeof window.googleMusic === 'undefined') {
  var googleMusic = window.googleMusic = new window.GoogleMusic(window);

  googleMusic.on('change:rating', function(rating) {
    GoogleMusicApp.ratingChanged(rating);
  });

  googleMusic.on('change:song', function(song) {
    GoogleMusicApp.notifySong(
      song.title, song.artist, song.album, song.art, song.duration
    );
  });

  googleMusic.on('change:shuffle', function(mode) {
    GoogleMusicApp.shuffleChanged(mode);
  });

  googleMusic.on('change:repeat', function(mode) {
    GoogleMusicApp.repeatChanged(mode);
  });

  googleMusic.on('change:playback', function(mode) {
    GoogleMusicApp.playbackChanged(mode);
  });

  googleMusic.on('change:playback-time', function(playbackInfo) {
    GoogleMusicApp.playbackTimeChanged(
      playbackInfo.currentTime, playbackInfo.totalTime
    );
  });
}
