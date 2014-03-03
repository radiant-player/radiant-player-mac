/*
 * SwipeAnimation.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "SwipeView.h"

@class SwipeView;

@interface SwipeAnimation : NSAnimation {
    CGFloat _originalAmount;
}

@property (retain) SwipeView *swipeView;

- initWithSwipeView:(SwipeView *)view;

@end