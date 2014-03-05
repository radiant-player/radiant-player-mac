/*
 * SwipeAnimation.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "SwipeAnimation.h"

@implementation SwipeAnimation

@synthesize swipeView;

- (id)initWithSwipeView:(SwipeIndicatorView *)view
{
    self = [self initWithDuration:1.0 animationCurve:NSAnimationEaseOut];
    
    if (self) {
        _originalAmount = [view swipeAmount];
        [self setSwipeView:view];
        [self setFrameRate:30];
        [self setAnimationBlockingMode:NSAnimationNonblocking];
    }
    
    return self;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];
    [swipeView setSwipeAmount:(1 - progress)*_originalAmount];
    [swipeView setNeedsDisplay:YES];
}

@end