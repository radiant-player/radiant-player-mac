/*
 * PopupPanel.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PopupViewDelegate.h"
#import "../Support/VisualEffectView.h"

#define MINI_PLAYER_LARGE_HEIGHT 356.0
#define MINI_PLAYER_SMALL_HEIGHT 152.0

#define NO_SONGS_PLAYING_TAG 1
#define EXPAND_ART_TAG 2

@class PopupViewDelegate;

@interface PopupView : VisualEffectView {
//    NSView *_backgroundView;
    CGFloat _hoverAlphaMultiplier;
}

@property (assign) BOOL isLargePlayer;
@property (retain) NSTrackingArea *trackingArea;
@property (retain) NSImage *backgroundImage;
@property (assign) CGFloat hoverAlphaMultiplier;

@property (assign) NSInteger arrowX;

@property (retain) IBOutlet PopupViewDelegate *delegate;

- (void) togglePlayerSize;
- (BOOL) isDarkAppearance;
- (BOOL) useWhiteIcons;

@end
