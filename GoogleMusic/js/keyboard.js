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