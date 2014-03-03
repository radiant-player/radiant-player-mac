/*
 * SwipeView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SwipeAnimation.h"

#define SWIPE_MINIMUM_LENGTH 0.6
#define SWIPE_MINIMUM_THRESHOLD 0.35
#define SWIPE_INDICATOR_WIDTH 50
#define SWIPE_INDICATOR_SCALE_Y 1.1

@class SwipeAnimation;

@interface SwipeView : NSView<NSAnimationDelegate> {
    NSMutableDictionary *_touches;
    CGFloat _swipeAmount;
    SwipeAnimation *_animation;
}

@property (retain) WebView *webView;
@property (assign) CGFloat swipeAmount;

@end
