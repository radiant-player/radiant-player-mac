EDStarRating
---------------

A configurable star rating control for OSX and iOS, similar to those found in iTunes and the App Store.


###Installation

The easiest way to install EDStarRating is via [CocoaPods](http://cocoapods.org). Add this line to your Podfile:

```ruby
pod 'EDStarRating'
```

and run `pod install`. 

You can also install it manually by copying to project these two files: EDStarRating.h and EDStarRating.m

### Usage

 In order to use EDStarRating, you can instantiate it programmatically, or create a custom view in Interface Builder and assign it to an ivar of your app. Once you have an instance, you can use the control properties to configure it.

Example:

```

  starRating.starImage = [NSImage imageNamed:@"star.png"];
  starRating.starHighlightedImage = [NSImage imageNamed:@"starhighlighted.png"];
  starRating.maxRating = 5.0;
  starRating.delegate = self;
  starRating.horizontalMargin = 12;
  starRating.editable=YES;
  displayMode=EDStarRatingDisplayFull;


  starRating.rating= 2.5;

```
### Compatiblity
This control should work in ARC and not ARC projects. On OS X 10.6+ and iOS 4.x+.
But i've only tested it with ARC and Lion 10.7 and iOS 5.0. Let me now if it works fine for you in other environments.
  

### Screenshots

![EDStarRating](https://github.com/erndev/EDStarRating/raw/master/edstarrating.png)
![EDStarRating](https://github.com/erndev/EDStarRating/raw/master/edstarrating-ios.png)

### License
BSD License.
Copyright (c) 2011, Ernesto García
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### Star icons
The star icons and backgrounds used in the sample have been created by [Dan Deming-Henes
](http://strandeddesign.com).
