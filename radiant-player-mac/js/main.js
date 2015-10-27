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
if (typeof window.MusicAPI === 'undefined') {
    window.MusicAPI = {};
    
    /* Set up for Safari versions less than 7. */
    if (typeof window.MutationObserver === 'undefined') {
        window.MutationObserver = WebKitMutationObserver;
    }

    /* Create a volume API. */
    MusicAPI.Volume = (function() {
        var V = {};
        
        // A reference to the volume slider element.
        var slider = document.querySelector('#material-vslider');
        slider.step = 1;
            
        // Get the current volume level.
        V.getVolume = function() {
            return parseInt(slider.value);
        };

        // Set the volume level (0 - 100).
        V.setVolume = function(vol) {
            var current = V.getVolume();

            if (vol > current) {
                V.increaseVolume(vol - current);
            }
            else if (vol < current) {
                V.decreaseVolume(current - vol);
            }
        };

        // Increase the volume by an amount (default of 1).
        V.increaseVolume = function(amount) {
            if (typeof amount === 'undefined') 
                amount = 1;

            for (var i = 0; i < amount; i++) {
                slider.increment();
            }
        };

        // Decrease the volume by an amount (default of 1).
        V.decreaseVolume = function(amount) {
            if (typeof amount === 'undefined') 
                amount = 1;

            for (var i = 0; i < amount; i++) {
                slider.decrement();
            }
        };
        
        return V;
    })();
    
    /* Create a playback API. */
    MusicAPI.Playback = (function() {
        var P = {};
        
        // References to the media playback elements.
        var _eplayPause =  document.querySelector('#player [data-id="play-pause"]');
        var _eforward =    document.querySelector('#player [data-id="forward"]');
        var _erewind =     document.querySelector('#player [data-id="rewind"]');
        var _eshuffle =    document.querySelector('#player [data-id="shuffle"]');
        var _erepeat =     document.querySelector('#player [data-id="repeat"]');
        var _eplayback =   document.querySelector('#player #material-player-progress');
        
        // Playback modes.
        P.STOPPED = 0;
        P.PAUSED = 1;
        P.PLAYING = 2;

        // Repeat modes.
        P.LIST_REPEAT =    'LIST_REPEAT';
        P.SINGLE_REPEAT =  'SINGLE_REPEAT';
        P.NO_REPEAT =      'NO_REPEAT';

        // Shuffle modes.
        P.ALL_SHUFFLE =    'ALL_SHUFFLE';
        P.NO_SHUFFLE =     'NO_SHUFFLE';
        
        P.getPlaybackTime = function() {
            return parseInt(_eplayback.value);
        };
        
        P.setPlaybackTime = function(milliseconds) {
            _eplayback.value = milliseconds;
            _eplayback.fire('change');
        };
        
        // Playback functions.
        P.playPause =      function() { _eplayPause.click(); };
        P.forward =        function() { _eforward.click(); };
        P.rewind =         function() { _erewind.click(); };

        P.getShuffle =     function() { return _eshuffle.getAttribute('value'); };
        P.toggleShuffle =  function() { _eshuffle.click(); };

        P.getRepeat = function() {
            return _erepeat.value;
        };

        P.changeRepeat = function(mode) { 
            if (!mode) {
                // Toggle between repeat modes once.
                _erepeat.click(); 
            }
            else {
                // Toggle between repeat modes until the desired mode is activated.
                while (P.getRepeat() !== mode) {
                    _erepeat.click();
                }
            }
        };

        // Taken from the Google Play Music page.
        P.toggleVisualization = function() {
            var el = document.querySelector('#hover-icon');
            
            if (el)
                el.click();
        };

        return P;
    })();

    /* Create a rating API. */
    MusicAPI.Rating = (function() {
        var R = {};
        
        // Determine whether the rating element is selected.
        R.isRatingSelected = function(el) {
            return el.icon.indexOf('-outline') == -1;
        };

        // Determine whether the rating system is thumbs or stars.
        R.isStarsRatingSystem = function() {
            return document.querySelector('.rating-container.stars') !== null;
        };

        // Get current rating.
        R.getRating = function() {
            var els = document.querySelectorAll('.player-rating-container [data-rating]');

            for (var i = 0; i < els.length; i++) {
                var el = els[i];
                
                if (R.isRatingSelected(el))
                    return parseInt(el.dataset.rating);
            }
            
            return 0;
        };

        // Thumbs up.
        R.toggleThumbsUp = function() {
            var el = document.querySelector('.player-rating-container [data-rating="5"]');

            if (el)
                el.click();
        };

        // Thumbs down.
        R.toggleThumbsDown = function() {
            var el = document.querySelector('.player-rating-container [data-rating="1"]');

            if (el)
                el.click();
        };

        // Set a star rating.
        R.setStarRating = function(rating) {
            var el = document.querySelector('.player-rating-container [data-rating="' + rating + '"]');

            if (el && !R.isRatingSelected(el))
                el.click();
        }
        
        return R;
    })();

    /* Miscellaneous functions. */
    MusicAPI.Extras = {

        // Get a shareable URL of the song on Google Play Music.
        getSongURL: function() {
            var albumEl = document.querySelector('#player .player-album');
            var artistEl = document.querySelector('#player .player-artist');

            var urlTemplate = 'https://play.google.com/music/m/';
            var url = null;

            var parseID = function(id) {
                return id.substring(0, id.indexOf('/'));
            };

            if (albumEl === null && aristEl === null) 
                return null;

            var albumId = parseID(albumEl.dataset.id);
            var artistId = parseID(artistEl.dataset.id);

            if (albumId) {
                url = urlTemplate + albumId;
            } 
            else if (artistId) {
                url = urlTemplate + artistId;
            }

            return url;
        }
    };

    var lastTitle = "";
    var lastArtist = "";
    var lastAlbum = "";
    
    var addObserver, 
        shuffleObserver,
        repeatObserver,
        playbackObserver,
        playbackTimeObserver,
        ratingObserver;
    
    addObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            for (var i = 0; i < m.addedNodes.length; i++) {
                var target = m.addedNodes[i];
                var name = target.id || target.className;

                if (name == 'now-playing-info-wrapper')  {
                    
                    // Fire the rating observer if the thumbs exist (no harm if already observing)
                    var ratingEls = document.querySelectorAll('.player-rating-container [data-rating]');
                    for (var j = 0; j < ratingEls.length; j++) {
                        var ratingEl = ratingEls[j];
                        
                        if (ratingEl.observe.icon != 'iconChanged_') {
                            ratingEl.observe.icon = 'iconChanged_';
                            ratingEl.iconChanged_ = function(oldIcon) {
                                this.iconChanged(oldIcon);
                                GoogleMusicApp.ratingChanged(MusicAPI.Rating.getRating());
                            };
                        }
                    }
                    GoogleMusicApp.ratingChanged(MusicAPI.Rating.getRating());
                    
                    var now = new Date();

                    var title = document.querySelector('#player #player-song-title');
                    var artist = document.querySelector('#player #player-artist');
                    var album = document.querySelector('#player .player-album');
                    var art = document.querySelector('#player #playingAlbumArt');
                    var duration = parseInt(document.querySelector('#player #material-player-progress').max) / 1000;

                    title = (title) ? title.innerText : 'Unknown';
                    artist = (artist) ? artist.innerText : 'Unknown';
                    album = (album) ? album.innerText : 'Unknown';
                    art = (art) ? art.src : null;

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
                }
            }
        });
    });

    shuffleObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            var target = m.target;
            var id = target.dataset.id;

            if (id == 'shuffle') {
                GoogleMusicApp.shuffleChanged(target.getAttribute('value'));
            }
        });
    });

    repeatObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            var target = m.target;
            var id = target.dataset.id;

            if (id == 'repeat') {
                GoogleMusicApp.repeatChanged(target.getAttribute('value'));
            }
        });
    });

    playbackObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            var target = m.target;
            var id = target.dataset.id;

            if (id == 'play-pause') {
                var mode;
                var playing = target.classList.contains('playing');

                if (playing) {
                    mode = MusicAPI.Playback.PLAYING;
                }
                else {
                    // If there is a current song, then the player is paused.
                    if (document.querySelector('#playerSongInfo').childNodes.length) {
                        mode = MusicAPI.Playback.PAUSED;
                    }
                    else {
                        mode = MusicAPI.Playback.STOPPED;
                    }
                }

                GoogleMusicApp.playbackChanged(mode);
            }
        });
    });

    playbackTimeObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            var target = m.target;
            var id = target.id;

            if (id == 'material-player-progress') {
                var currentTime = parseInt(target.value);
                var totalTime = parseInt(target.max);
                GoogleMusicApp.playbackTimeChanged(currentTime, totalTime);
            }
        });
    });

    addObserver.observe(document.querySelector('#player #playerSongInfo'), { childList: true, subtree: true });
    shuffleObserver.observe(document.querySelector('#player [data-id="shuffle"]'), { attributes: true });
    repeatObserver.observe(document.querySelector('#player [data-id="repeat"]'), { attributes: true });
    playbackObserver.observe(document.querySelector('#player [data-id="play-pause"]'), { attributes: true });
    playbackTimeObserver.observe(document.querySelector('#player #material-player-progress'), { attributes: true });
}