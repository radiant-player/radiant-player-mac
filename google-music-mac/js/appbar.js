/*
 * js/appbar.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, enabling dragging of the application bar.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.GMAppBar === 'undefined') {
    window.GMAppBar = true;
    
    // Handle dragging of the application bar.
    var exclude = [];
    exclude.push(document.querySelector('#gm-back'));
    exclude.push(document.querySelector('#gm-forward'));
    exclude.push(document.querySelector('#oneGoogleWrapper input[name="q"]').parentNode);
    exclude.push(document.querySelector('#oneGoogleWrapper > div:first-child > div:first-child > div:first-child > div:first-child'));
    exclude.concat(document.querySelectorAll('#oneGoogleWrapper > div:first-child > div:first-child > div:first-child > div:nth-child(2) > div > div:first-child'));
    
    var appBar = document.querySelector('#oneGoogleWrapper');

    var isDescendantOfExcludedElements = function(el) {
        for (var i = 0; i < exclude.length; i++) {
            if (exclude[i] != null && exclude[i].contains(el))
                return true;
        }
        
        return false;
    };

    appBar.addEventListener('mousedown', function(evt) {
        // Only allow left clicks.
        if (evt.button != 0)
            return;

        // Get the element at this location.
        var el = document.elementFromPoint(evt.pageX, evt.pageY);

        // If it is one of the excluded elements or their descendents, skip it.
        if (isDescendantOfExcludedElements(el)) {
            return true;
        }

        // Keep track of dragging.
        window._mouseDown = true;
        window._lastX = evt.screenX;
        window._lastY = evt.screenY;
    });

    appBar.addEventListener('mouseup', function(evt) {
        window._mouseDown = false;
        window._lastX = 0;
        window._lastY = 0;
    });

    document.addEventListener('mousemove', function (evt) {
        // Left button is not pressed for whatever reason, so we should stop.
        if (evt.button != 0) {
            window._mouseDown = false;
            window._lastX = 0;
            window._lastY = 0;
        }

        if (window._mouseDown) {
            // Compute the mouse position changes and report them to the application.
            var deltaX = evt.screenX - window._lastX;
            var deltaY = evt.screenY - window._lastY;

            window._lastX = evt.screenX;
            window._lastY = evt.screenY;
            window.GoogleMusicApp.moveWindow(deltaX, deltaY);
        }
    });
}