/*
 * SwipeIndicatorView.m
 *
 * Created by Sajid Anwar. 
 *
 * Arrow drawing code taken from Kapeli:
 * https://github.com/Kapeli/SwipableWebView
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "SwipeIndicatorView.h"

@implementation SwipeIndicatorView

@synthesize webView;
@synthesize swipeAmount;

- (NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat amount = swipeAmount;
    
    if (amount < -1*SWIPE_MINIMUM_THRESHOLD && [self.webView canGoBack]) {
        amount *= -1;
        amount -= SWIPE_MINIMUM_THRESHOLD;
        
        CGFloat progress = MIN(amount / (SWIPE_MINIMUM_LENGTH - SWIPE_MINIMUM_THRESHOLD), 1.0);
        NSRect frame = NSMakeRect(NSMaxX(self.frame) + SWIPE_INDICATOR_WIDTH - SWIPE_INDICATOR_WIDTH*progress, NSMidY(self.frame) - SWIPE_INDICATOR_WIDTH, SWIPE_INDICATOR_WIDTH, 2*SWIPE_INDICATOR_WIDTH);
        
        CGFloat alpha = (progress >= 1.0) ? 0.8 : (progress * 0.5);
        [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alpha] setFill];
        NSPoint center = NSMakePoint(NSMinX(frame), NSMidY(frame));
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:center radius:SWIPE_INDICATOR_WIDTH startAngle:90 endAngle:-90];
        [path fill];
        
        // Adapted from SwipableWebView.
        frame.origin.x -= SWIPE_INDICATOR_WIDTH;
        NSBezierPath* arrowPath = [NSBezierPath bezierPath];
        [arrowPath moveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 37.93)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 42.17) controlPoint1: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 39.1) controlPoint2: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 41)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.76, NSMaxY(frame) - 47)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 12, NSMaxY(frame) - 47)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 10.34, NSMaxY(frame) - 47) controlPoint2: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 48.34)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 12, NSMaxY(frame) - 53) controlPoint1: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 51.66) controlPoint2: NSMakePoint(NSMinX(frame) + 10.34, NSMaxY(frame) - 53)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.76, NSMaxY(frame) - 53)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 57.83)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 59) controlPoint2: NSMakePoint(NSMinX(frame) + 23.76, NSMaxY(frame) - 60.9)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 29.17, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 26.1, NSMaxY(frame) - 63.24) controlPoint2: NSMakePoint(NSMinX(frame) + 28, NSMaxY(frame) - 63.24)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 39.07, NSMaxY(frame) - 52.17)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 39.65, NSMaxY(frame) - 51.6) controlPoint2: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50.84)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 39.1, NSMaxY(frame) - 47.85) controlPoint1: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 49.16) controlPoint2: NSMakePoint(NSMinX(frame) + 39.65, NSMaxY(frame) - 48.4)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 29.17, NSMaxY(frame) - 37.93)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.93, NSMaxY(frame) - 37.93) controlPoint1: NSMakePoint(NSMinX(frame) + 28, NSMaxY(frame) - 36.76) controlPoint2: NSMakePoint(NSMinX(frame) + 26.1, NSMaxY(frame) - 36.76)];
        [arrowPath closePath];
        [[NSColor whiteColor] setFill];
        [arrowPath fill];
    }
    else if (amount > SWIPE_MINIMUM_THRESHOLD && [self.webView canGoForward]) {
        amount -= SWIPE_MINIMUM_THRESHOLD;
        
        CGFloat progress = MIN(amount / (SWIPE_MINIMUM_LENGTH - SWIPE_MINIMUM_THRESHOLD), 1.0);
        NSRect frame = NSMakeRect(SWIPE_INDICATOR_WIDTH*progress - SWIPE_INDICATOR_WIDTH, NSMidY(self.frame) - SWIPE_INDICATOR_WIDTH, SWIPE_INDICATOR_WIDTH, 2*SWIPE_INDICATOR_WIDTH);
        
        CGFloat alpha = (progress >= 1.0) ? 0.8 : (progress * 0.5);
        [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alpha] setFill];
        NSPoint center = NSMakePoint(NSMinX(frame), NSMidY(frame));
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:center radius:SWIPE_INDICATOR_WIDTH startAngle:-90 endAngle:90];
        [path fill];
        
        // Adapted from SwipableWebView.
        NSBezierPath* arrowPath = [NSBezierPath bezierPath];
        [arrowPath moveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 37.93)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 42.17) controlPoint1: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 39.1) controlPoint2: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 41)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.24, NSMaxY(frame) - 47)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 37, NSMaxY(frame) - 47)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 38.66, NSMaxY(frame) - 47) controlPoint2: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 48.34)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 37, NSMaxY(frame) - 53) controlPoint1: NSMakePoint(NSMinX(frame) + 40, NSMaxY(frame) - 51.66) controlPoint2: NSMakePoint(NSMinX(frame) + 38.66, NSMaxY(frame) - 53)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.24, NSMaxY(frame) - 53)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 57.83)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 59) controlPoint2: NSMakePoint(NSMinX(frame) + 25.24, NSMaxY(frame) - 60.9)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 19.83, NSMaxY(frame) - 62.07) controlPoint1: NSMakePoint(NSMinX(frame) + 22.9, NSMaxY(frame) - 63.24) controlPoint2: NSMakePoint(NSMinX(frame) + 21, NSMaxY(frame) - 63.24)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 9.93, NSMaxY(frame) - 52.17)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50) controlPoint1: NSMakePoint(NSMinX(frame) + 9.35, NSMaxY(frame) - 51.6) controlPoint2: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 50.84)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 9.9, NSMaxY(frame) - 47.85) controlPoint1: NSMakePoint(NSMinX(frame) + 9, NSMaxY(frame) - 49.16) controlPoint2: NSMakePoint(NSMinX(frame) + 9.35, NSMaxY(frame) - 48.4)];
        [arrowPath lineToPoint: NSMakePoint(NSMinX(frame) + 19.83, NSMaxY(frame) - 37.93)];
        [arrowPath curveToPoint: NSMakePoint(NSMinX(frame) + 24.07, NSMaxY(frame) - 37.93) controlPoint1: NSMakePoint(NSMinX(frame) + 21, NSMaxY(frame) - 36.76) controlPoint2: NSMakePoint(NSMinX(frame) + 22.9, NSMaxY(frame) - 36.76)];
        [arrowPath closePath];
        [[NSColor whiteColor] setFill];
        [arrowPath fill];
    }
}

- (void)startAnimation
{
    _animation = [[SwipeAnimation alloc] initWithSwipeView:self];
    [_animation startAnimation];
}

- (void)stopAnimation
{
    [_animation stopAnimation];
}

@end
