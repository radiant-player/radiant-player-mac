# Change Log
All notable changes to this project will be documented in this file.
This file should follow the standards specified on [keepachangelog.com](http://keepachangelog.com/)
This project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]
### Added
* Option to switch between standard and custom title bar. This is set to standard by default to fix a UI freeze issue in El Capitan - to switch back, go to preferences > appearance > use custom title bar ([#480](https://github.com/radiant-player/radiant-player-mac/pull/480)

### Changed
* Updated mini player to use Play Music orange consistently ([#476](https://github.com/radiant-player/radiant-player-mac/pull/476)
* Always show notifications, even if window is in focus ([#472](https://github.com/radiant-player/radiant-player-mac/pull/472), [@jscheel](https://github.com/jscheel))
* Various legacy code cleanup / removal ([#465](https://github.com/radiant-player/radiant-player-mac/pull/465))

### Fixed
* Fixed player randomly freezing after minimizing ([#480](https://github.com/radiant-player/radiant-player-mac/pull/480)
* Fixed choppiness/lag when dragging the player ([#480](https://github.com/radiant-player/radiant-player-mac/pull/480)

## [1.6.2] - 2015-12-20
### Fixed
* Fixed a bug introduced in 1.6.0 where Radiant would hang when external HID devices were connected ([#463](https://github.com/radiant-player/radiant-player-mac/pull/463)).  Note that there is still an outstanding bug where the headphone play/pause buttons open iTunes in addition to controlling Radiant.  That is still being investigated.

## [1.6.1] - 2015-12-20
### Fixed
* Applied ratings button fill fix ([#436](https://github.com/radiant-player/radiant-player-mac/pull/436)) to Rdiant theme ([#462](https://github.com/radiant-player/radiant-player-mac/pull/462))

## [1.6.0] - 2015-12-19
### Added
* Added Dark Cyan theme ([#424](https://github.com/radiant-player/radiant-player-mac/pull/424))
* Added Rdiant theme ([#444](https://github.com/radiant-player/radiant-player-mac/pull/444), [@andrewnorell](https://github.com/andrewnorell))
* Added [contribution guidelines](https://github.com/radiant-player/radiant-player-mac/blob/master/CONTRIBUTING.md) for anyone wanting to contribute code to Radiant ([#401](https://github.com/radiant-player/radiant-player-mac/pull/401))
* Added abilty to specify how much of a song has to be listened to before it's scrobbled, between 50-100% (in line with the official last.fm scrobbler) ([#428](https://github.com/radiant-player/radiant-player-mac/pull/428))
* Added support for headphone hardware controls, like EarPods ([#450](https://github.com/radiant-player/radiant-player-mac/pull/450), [@megalithic](https://github.com/megalithic))

### Changed
* Updated to work with Google's latest updates ([#397](https://github.com/radiant-player/radiant-player-mac/pull/397))
* Updated referenced selectors to reflect Google's changes ([#446](https://github.com/radiant-player/radiant-player-mac/pull/446), [#452](https://github.com/radiant-player/radiant-player-mac/pull/452))
* Revamped website and application deployment ([#433](https://github.com/radiant-player/radiant-player-mac/pull/433), [#435](https://github.com/radiant-player/radiant-player-mac/pull/435),
[#449](https://github.com/radiant-player/radiant-player-mac/pull/449))
* Website made mobile-friendly ([#453](https://github.com/radiant-player/radiant-player-mac/pull/453), [@PythonProdigy](https://github.com/PythonProdigy))
* Added new website favicon ([#456](https://github.com/radiant-player/radiant-player-mac/pull/456), [@andrewnorell](https://github.com/andrewnorell))

### Fixed
* Fixed tracks being "randomly" loved/unloved on last.fm ([#426](https://github.com/radiant-player/radiant-player-mac/pull/426))
* Fixed Spotify layout ([#424](https://github.com/radiant-player/radiant-player-mac/pull/424), [#431](https://github.com/radiant-player/radiant-player-mac/pull/431))
* Fixed header element names ([#418](https://github.com/radiant-player/radiant-player-mac/pull/418)) (Thanks [@jcurtis](https://github.com/jcurtis))
* Fixed broken notifications and mini-player updates ([#400](https://github.com/radiant-player/radiant-player-mac/pull/400))
* Fixed crash when opening Last.fm history by allowing communication with Last.fm API servers ([#389](https://github.com/radiant-player/radiant-player-mac/pull/389), [#400](https://github.com/radiant-player/radiant-player-mac/pull/400))
* Restored the ability to move the window by the title bar ([#413](https://github.com/radiant-player/radiant-player-mac/pull/413))
* Fixed broken keyboard shortcut for search ([#413](https://github.com/radiant-player/radiant-player-mac/pull/413))
* Fixed track ratings not being reflected in the now playing bar ([#436](https://github.com/radiant-player/radiant-player-mac/pull/436))
* Fixed shrinking nav/menu buttons at narrow widths ([#443](https://github.com/radiant-player/radiant-player-mac/pull/443)) (Thanks [@davepagurek](https://github.com/davepagurek))
* Fixed AppleScript scripting ([#432](https://github.com/radiant-player/radiant-player-mac/pull/432))
* Many other small bugfixes

## [1.5.0] - 2015-10-31
This release is largely to fix issues affecting the usability of Radiant Player. However, the largest piece of news is that development of Radiant Player has been moved into an organization on GitHub, and a few collaborators have been brought on board in order to help develop Radiant Player and fix outstanding issues. Thank you to everyone who pushed for this! I'm sorry for the incredible delay between versions and addressing major issues, but hopefully this will be less of concern going forward with the new organization.

### Changed
* Use the Sparkle update framework for more intuitive and user-friendly update process

### Fixed
* Fix broken styling in Black theme (thanks [@shawn-mitch](https://github.com/shawn-mitch))
* Fix broken media keys by catching up to Google update
* Fix broken Last.fm scrobbling in OS X 10.11 El Capitan (thanks [@chrismou](https://github.com/chrismou))

## [1.4.1] - 2015-09-14
This is a small release that fixes the main bugs that made Radiant Player entirely unusable for a little while now. My apologies to everyone for being so unavailable, and thank you to those that provided unofficial binaries and code changes.

### Fixed
* Fixed styling errors (fixes [#340](https://github.com/radiant-player/radiant-player-mac/issues/340))
* Used new copy of Web Components fallback (fixes [#352](https://github.com/radiant-player/radiant-player-mac/issues/352), thank you [@jacobwgillespie](https://github.com/jacobwgillespie))
* Radiant Player launches properly on OS X El Capitan

## [1.4.0] - 2015-06-04
At long last, the actual next version!  Many thanks to all the testers of the two beta releases, and I will certainly be continuing to look into the outstanding issues that a couple users have reported. Also, *very many thanks* to everybody who was patiently waiting for this release ever since the Google Play Music redesign! I would have liked a much shorter release window, but hopefully this version is satisfactory enough to forgive that! Enjoy.

### Added
* Support Google Play Music's latest redesign
* Add support for `⌘[` and `⌘]` keyboard shortcuts to go forward and backward (fixes [#296](https://github.com/radiant-player/radiant-player-mac/issues/296), thanks [@gholts](https://github.com/gholts))
* Implement `⌘A` (select all) shortcut (fixes [#317](https://github.com/radiant-player/radiant-player-mac/issues/317))

### Changes
* Mac OS X 10.8 is no longer supported (see [#291](https://github.com/radiant-player/radiant-player-mac/issues/291) for progress, if any, on the possibility of re-instating support)
* Removed all styles except for Google and Black (formerly Spotify Black) due to incompatibility with the new redesign; I will be looking into porting one or two of the original styles to the new design
* Allow mini player to be used in other full screen applications (fixes [#79](https://github.com/radiant-player/radiant-player-mac/issues/79))
* Open release page instead of home page when a new version is available

### Fixed
* Prevent brief 'ghost' mini player while switching spaces (fixes [#309](https://github.com/radiant-player/radiant-player-mac/issues/309))
* Allow reload button to be clicked when internet connectivity is lost while first loading Google Play Music (fixes [#313](https://github.com/radiant-player/radiant-player-mac/issues/313))
* Prevent dragging of file onto main window (fixes [#307](https://github.com/radiant-player/radiant-player-mac/issues/307), thanks [@nielstholenaar](https://github.com/nielstholenaar))

## [1.3.3.2-beta] - 2015-06-03

This second `beta` has a few minor changes, and unless there are app-breaking bugs, the `stable` version will be released no later than tomorrow night. The main changes:

* Minor polish of the dark style
* Tweak stylesheet to support when songs are selected
* Re-enable ⌘A functionality to select all
* Allow reload button to be clicked when internet connectivity is lost

There was also a change that will prevent the startup crashes on Mac OS X 10.8, which have been present since v1.3.3. However, for my machine, Google Play Music does not load in Radiant Player, while it does work properly in Safari. It appears that, at least for me, the version of WebKit used by applications and the version used by Safari differ on the same machine. In order to allow the majority of users to appreciate the working version of Radiant Player, **I will be releasing the next `stable` version while dropping official support for Mac OS X 10.8**. If you are on Mountain Lion and this beta does work properly, please do contact me! I will also try to investigate in the future whether it will be possible to re-extend support to include Mac OS X 10.8.

My apologies everyone for getting this out so late! Between a family emergency and a new internship, it's been difficult to find the time to work on Radiant Player recently but I am still fully intending to support the application!

## [1.3.3.1-beta] - 2015-05-20

This beta release catches up to the Google Play Music redesign, along with a few other fixes. Some themes have been deprecated as they no longer work with the redesign, although I will look into porting selected ones to the new design (probably the iTunes-type styles). Currently, there is the default Google style and there is the Black style (formerly Spotify Black).

## [1.3.3] - 2015-04-05

My apologies! In a major oversight, I managed to include the usage of a OS X 10.10 only method which appears to be causing crashes on OS X 10.9 and below. This new version contains that fix!

It also contains a new feature, which is a preference that allows you to show the current song's album art as the dock icon! Many thanks to [@matthewlloyd](https://github.com/matthewlloyd) for that one.

## [1.3.2] - 2015-04-04
This release took a ridiculous amount of time, my apologies!

Many thanks to all of the contributors and users! With the creation of the beta release channel, it should be easier to get new features out to users to test without harming the experience of users who want the stable product.

### Added
* Introduce release channels `stable` and `beta`, which can be changed in the Preferences menu
* New style, Light (thanks [@stevenla](https://github.com/stevenla))
* Warn user when Flash plug-in is out-of-date and blocked
* Mini player can be undocked by dragging it away from the menu

### Fixed
* Dramatically improved CPU performance
* Use high-quality album art for mini-player (fixes [#270](https://github.com/radiant-player/radiant-player-mac/issues/270))
* Fix thumbs and star ratings (fixes [#245](https://github.com/radiant-player/radiant-player-mac/issues/245), [#250](https://github.com/radiant-player/radiant-player-mac/issues/250), [#254](https://github.com/radiant-player/radiant-player-mac/issues/254))
* Asynchronously load album art for notifications (fixes [#262](https://github.com/radiant-player/radiant-player-mac/issues/262))
* Many, many others!

## [1.3.1] - 2014-10-16
### Fixed
* The option to "Use Safari cookies" was broken in the recently released 1.3.0, so this is a quick release that fixes that bug.

## [1.3.0] - 2014-10-16
Radiant Player is (for the most part), Yosemite ready! There will be some problems here and there where I wasn't able to get to polishing the release for the sake of having this out before Yosemite is publicly released, so let me know about all the dents and scratches that I can work on.

My apologies that it took so long to release something, and that many of you in the beta were stuck with the pesky Library error. Please let me know if there are issues with this release on any platform!

### Added
* Create Yosemite style and Spotify Black Vibrant style

### Changed
* Update styles for OS X Yosemite

### Fixed
* Fix separate cookie storage

## [1.2.1] - 2015-06-18
Many thanks to [@tonybaroneee](https://github.com/tonybaroneee) for style updates, as well as to all the contributors that reported this problem.

### Fixed
* Fix bug due to Google Play Music site change that caused Radiant Player to not work correctly (see [#196](https://github.com/radiant-player/radiant-player-mac/issues/196))

## [1.2.0] - 2015-06-05
Lots of new features! In this release, the project has also finally completed the transition from `google-music-mac` to the name `radiant-player-mac`.

Many thanks to [@tonybaroneee](https://github.com/tonybaroneee), [@joshgordon](https://github.com/joshgordon), [@se-bastiaan](https://github.com/se-bastiaan), [@codingismy11to7](https://github.com/codingismy11to7), [@apfelbox](https://github.com/apfelbox), and all of the contributors and users!

### Added
* Separate cookie storage from Safari by default (for OS X 10.9 and above only)
* Support 5-star rating system (in Google Play Music labs) with style fixes, 5-star rating controls in the menu and in the mini player
* Show playing status in mini player's icon
* Optionally use Growl notifications instead of Notification Center if Growl is available
* Pause music when system sleeps

### Fixed
* Prevent usage of discrete GPU (fixes [#142](https://github.com/radiant-player/radiant-player-mac/issues/142))
* Fix bugs related to application of navigation features and account information (fixes [#151](https://github.com/radiant-player/radiant-player-mac/issues/151), [#157](https://github.com/radiant-player/radiant-player-mac/issues/157), [#158](https://github.com/radiant-player/radiant-player-mac/issues/158))
* Fix bugs related to erratic movement of Radiant Player window when dragging (fixes [#168](https://github.com/radiant-player/radiant-player-mac/issues/168))
* Prevent full screen when in no-dock-icon mode (fixes [#152](https://github.com/radiant-player/radiant-player-mac/issues/152), [#153](https://github.com/radiant-player/radiant-player-mac/issues/153))
* Fix title bar text colors of certain styles (fixes [#135](https://github.com/radiant-player/radiant-player-mac/issues/135))

## [1.1.3] - 2014-04-12
### Added
* New theme: [Dark Flat](http://radiant-player.github.io/radiant-player-mac/images/styles/dark-flat.png) (thanks to [@hoffi](https://github.com/hoffi))
* New theme: [Spotify Black](http://radiant-player.github.io/radiant-player-mac/images/styles/spotify-black.png) (thanks to [@tonybaroneee](https://github.com/tonybaroneee))
* Last.fm button that shows a popover with your most recent tracks ([preview](http://radiant-player.github.io/radiant-player-mac/images/lastfm-button.png))
* Ability to automatically love/unlove a track on Last.fm based on the song's rating (thumbs up/down)
* Ability to hide the Google apps and notifications buttons

### Fixed
* Multiple fixes for proper Mac OS X 10.8 support
* Fix: don't accidentally break Quick Look due to media keys support (fixes [#117](https://github.com/radiant-player/radiant-player-mac/issues/117))
* Fix: performance of dark styles dramatically improved (fixes [#90](https://github.com/radiant-player/radiant-player-mac/issues/90), [#120](https://github.com/radiant-player/radiant-player-mac/issues/120))
* Fix: mini player supports multiple screens, edge of current screen (fixes [#108](https://github.com/radiant-player/radiant-player-mac/issues/108))

## [1.1.2] - 2014-03-27
So the name change is a pretty noticeable feature. Google's trademark team contacted me recently and politely asked that I change the name of the application and use a different logo. This is what I came up with (picking a name is surprisingly difficult, as is icon design). This release is a little light on new features as I had to implement this name change as soon as possible.

Update checking should work correctly for now as the repository name is still correct, though given enough time (maybe a week) I will rename the repository to something like `radiant-player-mac`.

### Added
* Introduce alternate mini player ([preview](http://radiant-player.github.io/radiant-player-mac/images/mini-player-alternate.png))
* Implement seamless title bar for original Google theme [#73](https://github.com/radiant-player/radiant-player-mac/issues/72))
* Introduce dark style, similar to Spotify

### Fixed
* Prevent crash when internet or GitHub is down (fixes [#73](https://github.com/radiant-player/radiant-player-mac/issues/73))
* Activate application when clicking on a notification (fixes [#66](https://github.com/radiant-player/radiant-player-mac/issues/66))
* Prevent crash when using the wrong password for Last.fm on OS X 10.8 (fixes [#81](https://github.com/radiant-player/radiant-player-mac/issues/81))

## [1.1.1] - 2014-03-09
### Fixed
- Seems that the uploaded version v1.1.0 build had a problem with the preferences window not properly opening. This v1.1.1 should be working correctly.

## [1.1.0] - 2014-03-09
Many thanks to [@JamesFator](https://github.com/JamesFator), [@anantn](https://github.com/anantn), [@zfy0701](https://github.com/zfy0701), [@daktales](https://github.com/daktales), [@zwaldowski](https://github.com/zwaldowski), and everybody who opened up issues for progress towards this release.

### Added
* Mini player popup in menu bar
* Last.fm integration - [#33](https://github.com/radiant-player/radiant-player-mac/issues/33)
* Automatically check and notify for version updates
* Added menu to dock icon (identical to Controls menu) - [#53](https://github.com/radiant-player/radiant-player-mac/issues/53)
* Enable two and three finger swipe to go back/forward
* Enable AppleScript support - [#60](https://github.com/radiant-player/radiant-player-mac/issues/60)
* Add option to use iTunes-style notifications (skip button, album art as main image) - [#61](https://github.com/radiant-player/radiant-player-mac/issues/61)
* Add option to keep Google Play logo instead of replacing fully with back/forward buttons - [#52](https://github.com/radiant-player/radiant-player-mac/issues/52)
* Add option to hide dock icon when mini player is enabled

### Fixed
* Implemented file upload dialog - [#45](https://github.com/radiant-player/radiant-player-mac/issues/45), [#62](https://github.com/radiant-player/radiant-player-mac/issues/62)
* Implemented select all (⌘A) - [#57](https://github.com/radiant-player/radiant-player-mac/issues/57)
* Fixed thumbs up/down images - [#56](https://github.com/radiant-player/radiant-player-mac/issues/56), [#59](https://github.com/radiant-player/radiant-player-mac/issues/59)
* Fixed bug preventing Adobe Fireworks mouse interaction - [#40](https://github.com/radiant-player/radiant-player-mac/issues/40)

## [1.0.3] - 2014-02-27
### Added
- In Mac OS X appearance, allow dragging of the application title bar

### Changed
- Clicking the close button on the window hides it instead; music will remain playing in the background
- Replace Google Play logo with back and forward buttons
- Open links in the default browser

### Fixed
Updated thumbs up and down sprite positions

## [1.0.2] - 2014-02-20
### Changed
- Unbundled Flash player for smaller download and easier updating

## [1.0.0] - 2014-02-20
- Initial release of Google Music for Mac
