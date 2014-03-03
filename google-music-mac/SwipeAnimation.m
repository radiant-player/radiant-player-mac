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

- (id)initWithSwipeView:(SwipeView *)view
{
    self = [self initWithDuration:0.5 animationCurve:NSAnimationEaseOut];
    
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