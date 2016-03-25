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
    window.GMAppBar = {
        _lastX: 0,
        _lastY: 0,
        _mouseDown: false
    };

    (function() {
        // Handle dragging of the application bar.
        var exclude = []
            .concat([].slice.call(document.querySelectorAll('.gm-nav-button')))
            .concat([].slice.call(document.querySelectorAll('#material-one-right > div:first-child > div:first-child > div:first-child > *')));

        var el = document.querySelector('#material-one-middle input.sj-search-box');
        if (el) exclude = exclude.concat(el.parentNode);

        var appBar = document.querySelector('#material-app-bar');

        var isDescendantOfExcludedElements = function(el) {
            for (var i = 0; i < exclude.length; i++) {
                if (exclude[i] && exclude[i].contains(el))
                    return true;
            }

            return false;
        };

        var mouseDown = function(evt) {
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
            window.GMAppBar._mouseDown = true;
            window.GMAppBar._lastX = evt.screenX;
            window.GMAppBar._lastY = evt.screenY;
        };

        var mouseUp = function(evt) {
            window.GMAppBar._mouseDown = false;
            window.GMAppBar._lastX = 0;
            window.GMAppBar._lastY = 0;
        };

        var mouseMove = function (evt) {
            // Left button is not pressed for whatever reason, so we should stop.
            if (evt.button != 0) {
                window.GMAppBar._mouseDown = false;
                window.GMAppBar._lastX = 0;
                window.GMAppBar._lastY = 0;
            }

            if (window.GMAppBar._mouseDown) {
                // Compute the mouse position changes and report them to the application.
                var deltaX = evt.screenX - window.GMAppBar._lastX;
                var deltaY = evt.screenY - window.GMAppBar._lastY;

                window.GMAppBar._lastX = evt.screenX;
                window.GMAppBar._lastY = evt.screenY;
                window.GoogleMusicApp.moveWindow(deltaX, deltaY);
            }
        };

        appBar.addEventListener('mousedown', mouseDown);
        appBar.addEventListener('mouseup', mouseUp);
        window.addEventListener('mouseup', mouseUp);
        window.addEventListener('mousemove', mouseMove);
    })();
}
