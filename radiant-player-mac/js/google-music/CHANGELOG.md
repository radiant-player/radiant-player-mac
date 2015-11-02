# google-music changelog
3.2.0 - Added assertions for elements and made selectors cross-version

3.1.1 - Added `foundry` for release

3.1.0 - Removed duplicate events from `change:playback` event and fixed "Stop" detection

3.0.0 - Updated integration to handle Material design release

2.0.5 - Fixed `package.main` reference

2.0.4 - Moved from `setStarRating` to `setRating`, renamed `changeRepeat` to `toggleRepeat`, and moved `notifySong` to provide duration in millseconds

2.0.3 - Moved to EventEmitter for hooks

2.0.2 - Refactored internals, moved constants as class properties

2.0.1 - Fixed style issues and moved all method keys to lower case for OOP consistency

2.0.0 - Moved to constructor and off of `window` to support `node-webkit`

1.2.0 - Added build scripts for `bower` and vanilla JS

1.1.0 - Completed tests and fixed bug in `Rating.getRating()`

1.0.0 - Initial release
