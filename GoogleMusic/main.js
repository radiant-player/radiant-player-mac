/*
 * Created by Sajid Anwar, 2014.
 *
 * This script is part of the JavaScript interface used by GoogleMusicMac to interact with
 * the Google Music page, in order to provide notifications functionality.
 *
 * https://github.com/kbhomes/GoogleMusicMac
 */

// This check ensures that, even though this script is run multiple times, our code is only attached once.
if (typeof window.macosx === 'undefined') {
    window.macosx = true;

    var lastTitle = "";
    var lastArtist = "";
    var lastAlbum = "";

    var addObserver = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
            for (var i = 0; i < m.addedNodes.length; i++) {
                var target = m.addedNodes[i];
                var name = target.id || target.className;

                if (name == 'text-wrapper')  {
                    var now = new Date();

                    var title = document.querySelector('#playerSongTitle');
                    var artist = document.querySelector('#player-artist');
                    var album = document.querySelector('.player-album');
                    var art = document.querySelector('#playingAlbumArt');

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
                        window.googleMusicApp.notifySong(title, artist, album, art); 

                        lastTitle = title;
                        lastArtist = artist;
                        lastAlbum = album;
                    }
                }
            }
        });
    });

    addObserver.observe(document.querySelector('#playerSongInfo'), { childList: true, subtree: true });
}