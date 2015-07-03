/*
 * SwipeIndicatorView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SwipeAnimation.h"

#define SWIPE_MINIMUM_LENGTH 0.55
#define SWIPE_MINIMUM_THRESHOLD 0.25
#define SWIPE_INDICATOR_WIDTH 50
#define SWIPE_INDICATOR_SCALE_Y 1.1
#define SWIPE_AMOUNT_MULTIPLIER 1.5

@class SwipeAnimation;

@interface SwipeIndicatorView : NSView<NSAnimationDelegate> {
    NSMutableDictionary *_touches;
    CGFloat _swipeAmount;
    SwipeAnimation *_animation;
}

@property (retain) WebView *webView;
@property (assign) CGFloat swipeAmount;

- (void)startAnimation;
- (void)stopAnimation;

@end
