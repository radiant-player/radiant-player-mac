/*
 * js/styles.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Music page, allowing custom styles to be applied.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.Styles === 'undefined') {
    window.Styles = {
        appliedStyles: {},
        
        applyStyle: function(key, css) {
            if (Styles.appliedStyles[key]) {
                Styles.appliedStyles[key].disabled = false;
            }
            else {
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = css;
                style.id = 'style-' + key;
                
                document.getElementsByTagName('head')[0].appendChild(style);
                Styles.appliedStyles[key] = style;
            }
        },
        
        disableStyle: function(key) {
            if (Styles.appliedStyles[key]) {
                Styles.appliedStyles[key].disabled = true;
            }
        }
    };
    
    // Here, apply styles that cannot be calculated in CSS alone.
    
    // Thumbs up and down styles.
    (function() {
        // Create dummy elements to get the computed styles for these elements.
        var td = document.createElement('td');
        td.dataset.col = 'rating';

        var el = document.createElement('div');
        el.className = 'song-row';
        el.appendChild(td);
        el.style.display = 'none';
        document.body.appendChild(el);

        // Get the background-position for thumbs up.
        td.dataset.rating = '5';
        var thumbsUpStyle = document.defaultView.getComputedStyle(td, null);
        var thumbsUpBackX = parseInt(thumbsUpStyle.backgroundPositionX);
        var thumbsUpBackY = parseInt(thumbsUpStyle.backgroundPositionY);

        // Get the background-position for thumbs down.
        td.dataset.rating = '1';
        var thumbsDownStyle = document.defaultView.getComputedStyle(td, null);
        var thumbsDownBackX = parseInt(thumbsDownStyle.backgroundPositionX);
        var thumbsDownBackY = parseInt(thumbsDownStyle.backgroundPositionY);

        // Remove the element.
        document.body.removeChild(el);
     
        // Apply a new stylesheet for the new thumbs up and down positions.
        thumbsUpBackY -= 9;
        thumbsDownBackY -= 7;
     
        var thumbsUpPosition = thumbsUpBackX + 'px ' + thumbsUpBackY + 'px';
        var thumbsDownPosition = thumbsDownBackX + 'px ' + thumbsDownBackY + 'px';
     
        window.Styles.applyStyle('thumbsUpDown',
            '.song-row [data-col="rating"][data-rating="5"] { background-position: ' + thumbsUpPosition + ' !important; } ' +

            '.song-row [data-col="rating"][data-rating="1"], ' +
            '.song-row [data-col="rating"][data-rating="2"] { background-position: ' + thumbsDownPosition + ' !important; } '
        );
    })();
}