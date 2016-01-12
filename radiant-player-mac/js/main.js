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
  var lastTitle = "";
  var lastArtist = "";
  var lastAlbum = "";

  gmusic.on('change:rating', function(rating) {
    GoogleMusicApp.ratingChanged(rating);
  });

  gmusic.on('change:song', function(song) {
    var title = (song.title) ? song.title : 'Unknown';
    var artist = (song.artist) ? song.artist : 'Unknown';
    var album = (song.album) ? song.album : 'Unknown';
    var art = (song.art) ? song.art : null;
    var duration = (song.duration) ? song.duration : null;

    // The art may be a protocol-relative URL, so normalize it to HTTPS.
    if (art && art.slice(0, 2) === '//') {
        art = 'https:' + art;
    }

    // Make sure that this is the first of the notifications for the
    // insertion of the song information elements.
    if (lastTitle != title || lastArtist != artist || lastAlbum != album) {
        GoogleMusicApp.notifySong(title, artist, album, art, duration);
        lastTitle = title;
        lastArtist = artist;
        lastAlbum = album;
    }
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
