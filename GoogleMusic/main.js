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

                    title = (title) ? title.innerText : 'Unknown';
                    artist = (artist) ? artist.innerText : 'Unknown';
                    album = (album) ? album.innerText : 'Unknown';

                    // Make sure that this is the first of the notifications for the
                    // insertion of the song information elements.
                    if (lastTitle != title || lastArtist != artist || lastAlbum != album) {
                        window.googleMusicApp.notifySongWithArtistAndAlbum(title, artist, album); 

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