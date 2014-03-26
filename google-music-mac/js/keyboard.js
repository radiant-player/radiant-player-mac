/*
 * js/keyboard.js
 *
 * This script is part of the JavaScript interface used to interact with
 * the Google Play Music page, allowing key events to be sent to elements.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

if (typeof window.Keyboard === 'undefined') {
    window.Keyboard = {
    	// Key constants
    	KEY_UP: 0x26,
    	KEY_DOWN: 0x28,

        sendKey: function (element, key) {
			var ev = document.createEvent('Events');
			ev.initEvent("keydown", true, true);
			ev.keyCode = key;
			ev.which = key;

			element.dispatchEvent(ev);
		}
    };
}