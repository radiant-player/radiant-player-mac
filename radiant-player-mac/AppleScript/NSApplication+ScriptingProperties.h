/*
 * NSApplication+ScriptingProperties.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface NSApplication (ScriptingProperties)

- (AppDelegate *) appDelegate;

- (NSString *) currentTitle;
- (NSString *) currentArtist;
- (NSString *) currentAlbum;
- (NSImage *) currentArt;
- (NSString *) currentSongURL;
- (NSInteger) currentPlaybackMode;

@end
