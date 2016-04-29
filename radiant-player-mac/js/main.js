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

        var baraka;
              /*// Playback states
               STOPPED: 0, nothing playing
               PAUSED: 1,  music paused :O
               PLAYING: 2, yay music is playing */

        if (mode === 0) {
            if (document.querySelector("#baraka-toast") !== null) {
                document.getElementById("baraka-toast").style.display = "none";
            }

            if (document.querySelector("#lyric-overlay") !== null) {
                document.getElementById("lyric-overlay").style.display = "none";
            }

            if (document.querySelector("#baraka-lyrics") !== null) {
                document.querySelector("#baraka-lyrics").style.display = "none";
            }

            if (document.querySelector("#service") !== null) {
                document.getElementById("service").style.display = "none";
            }

            baraka = "fake remove BarakaLyrics";
        } else if (mode === 1) {
            if (document.querySelector('#service') !== null) {
                if (document.querySelector('#service').style.display == "" || document.querySelector('#service').style.display == "block") {
                    document.querySelector('#service').style.display = "none";
                } else {
                    document.querySelector('#service').style.display = "none";
                }
            }
              
            if (document.querySelector("#lyric-overlay") !== null) {
                if (document.querySelector('#lyric-overlay').style.display == "block" || document.querySelector('#lyric-overlay').style.display == "") {
                    document.querySelector('#lyric-overlay').style.display = "none";
                } else {
                    document.querySelector('#lyric-overlay').style.display = "none";
                }
            }

            baraka = "Hide BarakaLyrics";
        } else if (mode === 2) {
              /*if (document.querySelector('#service') !== null) {
                    if (document.querySelector('#service').style.display == "none") {
                        document.querySelector('#service').style.display = "block";
                    } else {
                        document.querySelector('#service').style.display = "none";
                    }
              }*/
            baraka = "Show BarakaLyrics";
        } else {
            // do nothing - baraka
        }

        if (DEBUG) console.info('change:playback', baraka + ': ' + mode);

    });

    gmusic.on('change:playback-time', function(info) {
        if (DEBUG && VERBOSE) console.info('change:playback-time', arguments);
        GoogleMusicApp.playbackTimeChanged(info.current, info.total);
    });

    gmusic.on('change:rating', function(rating) {
        if (DEBUG) console.info('change:rating', arguments);
        GoogleMusicApp.ratingChanged(rating);
    });
}
