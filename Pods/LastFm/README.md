# LastFm - block based Last.fm SDK for iOS and Mac OS X

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/LastFm/badge.png)](http://cocoadocs.org/docsets/LastFm)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/LastFm/badge.svg)](http://cocoadocs.org/docsets/LastFm)

Loosely based on LastFMService from the [old Last.fm iPhone app](https://github.com/lastfm/lastfm-iphone/blob/master/Classes/LastFMService.m), but non-blocking, more readable, much easier to use (and to extend) and with less dependencies.

### Features
- Block based for easier usage
- Only one dependency ([KissXML](https://github.com/robbiehanson/KissXML))
- Returns values in the correct data type (NSDate, NSURL, NSNumber, etc)
- Hook in your own caching methods (GVCache, NSCache, Core Data, SYCache, EGOCache, ...)
- Cancelable operations, perfect for when cells are scrolled off screen and you don't need to make the API calls after all
- Actively developed and maintained (it's used in the official Last.fm Scrobbler app!)

## Usage
```objective-c
// Set the Last.fm session info
[LastFm sharedInstance].apiKey = @"xxx";
[LastFm sharedInstance].apiSecret = @"xxx";
[LastFm sharedInstance].session = session;
[LastFm sharedInstance].username = username;

// Get artist info
[[LastFm sharedInstance] getInfoForArtist:@"Pink Floyd" successHandler:^(NSDictionary *result) {
    NSLog(@"result: %@", result);
} failureHandler:^(NSError *error) {
    NSLog(@"error: %@", error);
}];

// Get images for an artist
[[LastFm sharedInstance] getImagesForArtist:@"Cher" successHandler:^(NSArray *result) {
    NSLog(@"result: %@", result);
} failureHandler:^(NSError *error) {
    NSLog(@"error: %@", error);
}];

// Scrobble a track
[[LastFm sharedInstance] sendScrobbledTrack:@"Wish You Were Here" byArtist:@"Pink Floyd" onAlbum:@"Wish You Were Here" withDuration:534 atTimestamp:(int)[[NSDate date] timeIntervalSince1970] successHandler:^(NSDictionary *result) {
    NSLog(@"result: %@", result);
} failureHandler:^(NSError *error) {
    NSLog(@"error: %@", error);
}];
```

Save the username and session you get with `getSessionForUser:password:successHandler:failureHandler:` somewhere, for example in `NSUserDefaults`, and on app start up set it back on `[LastFm sharedInstance].username` and `[LastFm sharedInstance].session`.

See the included iOS project for examples on login, logout, getting artist info and more.


### Example app
There's an extensive example app available which handles login, logout, getting lots of artists in a tableview and showing their details, caching, canceling API calls, and much more.

To install the example app, you need to use [CocoaPods](http://cocoapods.org): `pod install`. You can also try it by running `pod try LastFm`.

_The example app only works in iOS 5 and higher due to the usage of storyboards. The SDK itself works in iOS 4 and higher._


## Installation
You can install LastFm with [CocoaPods](http://cocoapods.org). Just add the following line to your Podfile, and run `pod install`:

    pod 'LastFm'

You can also simply clone the repository and drag the LastFm subfolder into your Xcode project. Be sure to install KissXML yourself.

### Requirements
* LastFm is built using ARC and modern Objective-C syntax. You will need iOS 4 and Xcode 4.4 or higher to use it in your project.
* You will need your own API key by registering at http://www.last.fm/api.
* [KissXML](https://github.com/robbiehanson/KissXML)


## Issues and questions
Have a bug? Please [create an issue on GitHub](https://github.com/gangverk/LastFm/issues)!


## Apps using LastFm
* Last.fm Scrobbler
* MetroLyrics
* Radio.com

Are you using LastFm in your iOS or Mac OS X app? Send a pull request with an updated README.md file to be included.


## License
LastFm is available under the MIT license. See the LICENSE file for more info.
