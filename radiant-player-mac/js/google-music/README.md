# google-music.js

Browser-side JS library for controlling [Google Music][].

[Google Music]: https://play.google.com/music/

This was built as part of [google-music-webkit][], a [node-webkit][] wrapper around [Google Music][]. It was forked from [radiant-player-mac@v1.3.1][], developed and created by [Sajid Anwar][] and [James Fator][] to make it reusable and well tested.

[google-music-webkit]: https://github.com/twolfson/google-music-webkit
[node-webkit]: https://github.com/rogerwang/node-webkit
[radiant-player-mac@v1.3.1]: https://github.com/kbhomes/radiant-player-mac/tree/v1.3.1
[Sajid Anwar]: https://github.com/kbhomes/
[James Fator]: http://jamesfator.com/

## Breaking changes in 3.0.0
On Thursday May 14, 2015 Google launched a Material redesign of the site. This broke a lot of selectors/functionality. In 3.0.0, we updated our integration to handle those changes. The developer-facing interface has not changed but the underlying system was a breaking change so we decided to make it a major release.

## Getting Started
### npm
Install the module with: `npm install google-music`

```js
// Load and initialize GoogleMusic
var GoogleMusic = require('google-music');
window.googleMusic = new GoogleMusic(window);

// Access volume
window.googleMusic.volume.getVolume(); // 50 (ranges from 0 to 100)
```

### bower
Install the module with: `bower install google-music`

Once installed, add it to your HTML and access it via `window.GoogleMusic`.

```html
<script src="bower_components/google-music/dist/google-music.min.js"></script>
<script>
  window.googleMusic = new window.GoogleMusic(window); // Our Google Music API
</script>
```

### Vanilla
If you are not using a package manager, download the latest script at:

https://raw.githubusercontent.com/twolfson/google-music.js/master/dist/google-music.min.js

Then, add it to your HTML and access it via `window.GoogleMusic`.

```html
<script src="google-music.min.js"></script>
<script>
  window.googleMusic = new window.GoogleMusic(window); // Our Google Music API
</script>
```

## Documentation
`google-music.js` exposes a constructor, `GoogleMusic` as its `module.exports` (`window.GoogleMusic` for `bower`/vanilla).

### `new GoogleMusic(window)`
Constructor for a new Google Music API. For usage with `node-webkit`, we require `window` to be passed in rather than assumed from global scope.

- window `Object` - Global `window` object for target browser window

### Volume
`googleMusic.volume` exposes interfaces to the volume controls of Google Music. Volume can range from 0 to 100 in steps of 5 (e.g. 10, 15, 20).

#### `volume.getVolume()`
Retrieve the current volume setting

**Returns:**

- retVal `Number` - Integer from 0 to 100 representing volume

#### `volume.setVolume(vol)`
Change the volume setting

- vol `Number` - Integer to set volume to

#### `volume.increaseVolume(amount)`
Raise the volume by an amount

- amount `Number` - Optional number to raise volume by
    - For example, if volume is 50 and amount is 5, then the volume will change to 55
    - If we exceed 100 when adding new values, volume will stop at 100
    - By default, this is 5

#### `volume.decreaseVolume(amount)`
Lower the volume by an amount

- amount `Number` - Optional number to lower volume by
    - For example, if volume is 50 and amount is 5, then the volume will change to 45
    - If we exceed 0 when subtracting new values, volume will stop at 0
    - By default, this is 5

### Playback
`googleMusic.playback` exposes interfaces to the state of music playback and its behavior (e.g. shuffle).

#### `playback.getPlaybackTime()`
Retrieve the current progress in a song

**Returns:**

- retVal `Number` - Integer representing milliseconds from the start of the song

#### `playback.setPlaybackTime(milliseconds)`
Jump the current song to a time

- milliseconds `Number` - Integer representing milliseconds to jump the current track to

#### `playback.playPause()`
Toggle between play and pause for the current song

**This will not work if there are no songs in the queue.**

#### `playback.forward()`
Move to the next song

#### `playback.rewind()`
Move to the previous song

#### `playback.getShuffle()`
Retrieve the status of shuffle

**Returns:**

- retVal `String` - Current state of shuffle (e.g. `ALL_SHUFFLE`, `NO_SHUFFLE`)
    - `ALL_SHUFFLE` will shuffle between all tracks
    - `NO_SHUFFLE` will play the tracks in the order they were added
    - We created constants named `GoogleMusic.Playback.ALL_SHUFFLE` or `GoogleMusic.Playback.NO_SHUFFLE`

#### `playback.toggleShuffle()`
Toggle to between shuffle being active or inactive

#### `playback.getRepeat()`
Retrieve the current setting for repeat

**Returns:**

- retVal `String` - Current setting for repeat (e.g. `LIST_REPEAT`, `SINGLE_REPEAT`, `NO_REPEAT`)
    - `LIST_REPEAT` will repeat the queue when it reaches the last song
    - `SINGLE_REPEAT` will repeat the current song indefinitely
    - `NO_REPEAT` will not repeat the queue
    - We created constants named `GoogleMusic.Playback.LIST_REPEAT`, `GoogleMusic.Playback.SINGLE_REPEAT`, `GoogleMusic.Playback.NO_REPEAT`

#### `playback.toggleRepeat(mode)`
Change the current setting for repeat

- mode `String` - Optional mode to change repeat to
    - If not specified, we will toggle to the next mode
        - The order is `NO_REPEAT`, `LIST_REPEAT`, `SINGLE_REPEAT`
    - Valid values are `NO_REPEAT`, `LIST_REPEAT`, `SINGLE_REPEAT`
        - See `playback.getRepeat()` for meaning

#### `playback.toggleVisualization()`
Trigger a visualization for the track. This is typically album art.

**This is an untested method.**

### Rating
`googleMusic.rating` exposes interfaces to the rating the current song.

#### `rating.getRating()`
Retrieve the rating for the current track.

**Returns:**

- retVal `String` - Rating for current song. This varies from 0 to 5
    - If 0, then there has been no rating
    - On a thumbs system, thumbs down is 1 and thumbs up is 5

#### `rating.toggleThumbsUp()`
Switch between thumbs up and no thumbs up for the current track. If thumbs down was set, this will remove the thumbs down rating.

#### `rating.toggleThumbsDown()`
Switch between thumbs down and no thumbs down for the current track. If thumbs up was set, this will remove the thumbs up rating.

#### `rating.setRating(rating)`
Set the rating for the current track

- rating `String` - Rating to set for the current track. This should be between 1 and 5

### Extras
`googleMusic.Extras` is a collection of utility functions for Google Music

#### `Extras.getSongURL()`
Retrieve the URL of the current song for sharing

**This is an untested method**

**Returns:**

- retVal `String` - URL for current song

### Hooks
Hooks are currently bound via `.on` and other corresponding methods for [node's EventEmitter][EventEmitter]

[EventEmitter]: http://nodejs.org/api/events.html

```js
googleMusic.on('change:song', function (song) {
});
```

#### `.on('change:song')`
Triggers when a song changes

```js
googleMusic.on('change:song', function (song) {
});
```

- song `Object` - Container for song info
    - title `String` - Name of the song
    - artist `String` - Artist of the song
    - album `String` - Album of the song
    - art `String` - URL for album art of the song
    - duration `Number` - Milliseconds that the track will last for

#### `.on('change:shuffle')`
Triggers when shuffle is toggled

```js
googleMusic.on('change:shuffle', function (mode) {
});
```

- mode `String` - Mode that shuffle changed to
    - Values are consistent with `playback.getShuffle()`

#### `.on('change:repeat')`
Triggers when repeat is toggled

```js
googleMusic.on('change:repeat', function (mode) {
});
```

- mode `String` - Mode that repeat changed to
    - Values are consistent with `playback.getRepeat()`

#### `.on('change:playback')`
Triggers when a song is started, paused, or stopped

```js
googleMusic.on('change:playback', function (mode) {
});
```

- mode `String` - Phase that a song is in (e.g. 0, 1, 2)
    - 0 - Song is stopped
    - 1 - Song is paused
    - 2 - Song is playing
    - Values are available via `GoogleMusic.Playback.STOPPED`, `GoogleMusic.Playback.PAUSED`, and `GoogleMusic.Playback.PLAYING`

#### `.on('change:playback-time')`
Triggers when playback shifts

```js
googleMusic.on('change:playback-time', function (playbackInfo) {
});
```

- playbackInfo `Object` - Container for playback info
    - currentTime `Number` - Milliseconds of how far a track has progressed
    - totalTime `Number` - Milliseconds of how long a track is

#### `.on('change:rating')`
Triggers when the current song is rated

```js
googleMusic.on('change:rating', function (rating) {
});
```

- rating `Number` - Rating the current song changed to
    - Consistent with values provided by `rating.getRating()`

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint via `npm run lint` and test via `npm test`.

### Testing
Currently, we require a personal Google account exclusively for testing. We will be rating tracks, changing repeat settings, and need predictable track titles. We are using the following songs (at least 3 required):

> Credentials: musopen@mt2014.com / password

https://musopen.org/music/1333/wolfgang-amadeus-mozart/the-marriage-of-figaro-k-492/

> Music cannot be uploaded via webdriver instance nor incognito window
>
> If you don't want to contaminate your personal account, create a new user profile in Chrome.

For exactly one track, set the following via "Edit Info" in Google Music:

```
Name:
this-is-a-name

Artist:
this-is-an-artist

Album Artist:
this-is-an-album-artist

Album:
this-is-an-album

Composer:
this-is-a-composer

Genre:
this-is-a-genre

Year:
2000

Track #:
1 of 10

Disc #:
3 of 5

Explicit:
Unchecked
```

Once your Google account is registered and the music is uploaded, extract the cookies for our test suite via:

```
# Enter into the node CLI
node

# Inside of the CLI, dump our cookies
var browser = require('wd').remote();
browser.init({browserName: 'chrome'}, console.log);
// Wait for browser window to open
browser.get('https://play.google.com/music/listen', console.log);
// Wait for redirect to accounts.google.com
// Manually log in to page
// When you are logged in to Google Music, dump the output of the following into `test/cookies.json`
browser.allCookies(function (err, cookies) { fs.writeFileSync('test/cookies.json', JSON.stringify(cookies, null, 4), 'utf8'); });
```

Finally, we can run the test suite:

```bash
# Start up a Selenium server
npm run webdriver-manager-start &

# Run our tests
npm test
```

## Donating
Support this project and [others by twolfson][gratipay] via [gratipay][].

[![Support via Gratipay][gratipay-badge]][gratipay]

[gratipay-badge]: https://cdn.rawgit.com/gratipay/gratipay-badge/2.x.x/dist/gratipay.png
[gratipay]: https://www.gratipay.com/twolfson/

## License
All files were originally licensed at `5ccfa7b3c7bc5231284f8e42c6a2f2e7fe1e1532` under the MIT license. This can be viewed its [`LICENSE.md`][]. It has been renamed to [LICENSE-MIT][] for ease of disambiguity.

[`LICENSE.md`]: https://github.com/twolfson/google-music.js/blob/5ccfa7b3c7bc5231284f8e42c6a2f2e7fe1e1532/LICENSE.md
[LICENSE-MIT]: LICENSE-MIT

After this commit, all alterations made by Todd Wolfson and future contributors are released to the Public Domain under the [UNLICENSE][].

[UNLICENSE]: UNLICENSE
