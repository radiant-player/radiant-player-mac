/*
 * js/lastfm.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, adding a Last.fm button that lets you view
 * which tracks were most recently scrobbled, as well as allowing you to
 * perform actions on Last.fm like loving a track.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.LastFmButton === 'undefined') {
    window.LastFmButton = true;

    // Obtain the area on the top-right, containing the Google account information.
    var rightArea = document.querySelector('#oneGoogleWrapper > div:first-child > div:first-child > div:first-child');
    
    // Remove the +Google name in the top-right area.
    if (rightArea.childNodes.length)
        rightArea.removeChild(rightArea.childNodes[0]);

    // Add a button that, when clicked, opens the Last.fm popover.
    var lastfmButton = document.createElement('a');
    lastfmButton.id = 'lastfmButton';
    lastfmButton.addEventListener('click', function(e) {
        window.GoogleMusicApp.showLastFmPopover();
        e.preventDefault();
    });

    rightArea.appendChild(lastfmButton);
}
