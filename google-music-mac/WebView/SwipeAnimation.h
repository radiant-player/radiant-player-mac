/*
 * SwipeAnimation.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "SwipeIndicatorView.h"

@class SwipeIndicatorView;

@interface SwipeAnimation : NSAnimation {
    CGFloat _originalAmount;
}

@property (retain) SwipeIndicatorView *swipeView;

- initWithSwipeView:(SwipeIndicatorView *)view;

@end