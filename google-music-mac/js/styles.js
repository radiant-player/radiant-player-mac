/*
 * js/styles.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, allowing custom styles to be applied.
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
        },
        
        removeStyle: function(key) {
            if (Styles.appliedStyles[key]) {
                Styles.appliedStyles[key].parentNode.removeChild(Styles.appliedStyles[key]);
                delete Styles.appliedStyles[key];
            }
        }
    };
}