/*
 * js/styles/none.js
 *
 * This script contains code needed for when styles aren't used.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.Styles.Applied === 'undefined') {
    window.Styles.Applied = true;
    window.Styles.None = true;
    
    window.Styles.Callbacks.onEnterFullScreen = function() {
        if (window.GoogleMusicApp.isYosemite()) {
            var el = document.querySelector('#oneGoogleWrapper > div:first-child > div:first-child > div:nth-child(2)');
            el.style.setProperty('margin-left', '20px', 'important');
            el.style.setProperty('margin-right', '20px', 'important');
        }
    };
    
    window.Styles.Callbacks.onExitFullScreen = function() {
        if (window.GoogleMusicApp.isYosemite()) {
            var el = document.querySelector('#oneGoogleWrapper > div:first-child > div:first-child > div:nth-child(2)');
            el.style.setProperty('margin-left', '90px', 'important');
            el.style.setProperty('margin-right', '20px', 'important');
        }
    };
}