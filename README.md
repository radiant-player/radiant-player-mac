[Radiant Player for Google Play Music™][1] [![Build Status](https://travis-ci.org/radiant-player/radiant-player-mac.svg)](https://travis-ci.org/radiant-player/radiant-player-mac)
=========================

![](https://raw.githubusercontent.com/radiant-player/radiant-player-mac/master/website/images/styles/google.png)

Turn Google Play Music into a separate, beautiful application that integrates with your Mac.

Developed by [Sajid Anwar][2]. Originally created by [James Fator][3] at [JamesFator/GoogleMusicMac][4].

No affiliation with Google. Google Play is a trademark of Google Inc.

[1]: http://kbhomes.github.io/radiant-player-mac/
[2]: https://github.com/kbhomes/
[3]: http://jamesfator.com/
[4]: https://github.com/JamesFator/GoogleMusicMac

Requirements
------------

* Mac OS X 10.8 or later
* [Adobe Flash Player for Mac OS X, _NPAPI version_][5]

[5]: https://get.adobe.com/flashplayer/

_Adobe recently changed their install to try to auto-detect your browser. If you are using Google Chrome it will automatically select the incorrect (PPAPI) version needed for Radiant Player. [Select a version manually][6] and choose the NPAPI version when prompeted_

[6]: https://get.adobe.com/flashplayer/otherversions/

Development
-----------

This project uses [CocoaPods][7] to handle its dependencies, though it may be cloned
and developed without having CocoaPods installed. Just be sure to open
`radiant-player-mac.xcworkspace` instead of `radiant-player-mac.xcodeproj` in order to
correctly pull in the dependencies into Xcode.

A few JavaScript dependencies are installed via `npm` - to update these dependences, ensure that `package.json` specifies the target version and run `./scripts/update-javascript-dependencies.sh`.

[7]: http://cocoapods.org/

License
-------

The MIT License (MIT)

Copyright (c) 2016 Sajid Anwar

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
