/*
 * SwipeView.m
 *
 * Created by Sajid Anwar. 
 *
 * Arrow drawing code taken from Kapeli:
 * https://github.com/Kapeli/SwipableWebView
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "SwipeView.h"

@implementation SwipeView

@synthesize webView;
@synthesize swipeAmount;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAcceptsTouchEvents:YES];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat amount = swipeAmount;
    
    if (amount < -1*SWIPE_MINIMUM_THRESHOLD && [self.webView canGoBack]) {
        amount *= -1;
        amount -= SWIPE_MINIMUM_THRESHOLD;
        
        CGFloat progress = MIN(amount / (SWIPE_MINIMUM_LENGTH - SWIPE_MINIMUM_THRESHOLD), 1.0);
        NSRect frame = NSMakeRect(SWIPE_INDICATOR_WIDTH*progress - SWIPE_INDICATOR_WIDTH, NSMidY(self.frame) - 50, SWIPE_INDICATOR_WIDTH, 100);
        
        CGFloat alpha = (progress >= 1.0) ? 0.8 : (progress * 0.5);
        [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alpha] setFill];
        NSPoint center = NSMakePoint(NSMinX(frame), NSMidY(frame));
        
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:SWIPE_INDICATOR_SCALE_Y];
        [transform translateXBy:0 yBy:-1*0.5*(SWIPE_INDICATOR_SCALE_Y - 1)*NSMidY(frame)];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:center radius:SWIPE_INDICATOR_WIDTH startAngle:-90 endAngle:90];
        [path transformUsingAffineTransform:transform];
        [path fill];
        
        // Adapted from SwipableWebView.
        frame.origin.x -= 3;
        frame.origin.y += 15;
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
    else if (amount > SWIPE_MINIMUM_THRESHOLD && [self.webView canGoForward]) {
        amount -= SWIPE_MINIMUM_THRESHOLD;
        
        CGFloat progress = MIN(amount / (SWIPE_MINIMUM_LENGTH - SWIPE_MINIMUM_THRESHOLD), 1.0);
        NSRect frame = NSMakeRect(NSMaxX(self.frame) + SWIPE_INDICATOR_WIDTH - SWIPE_INDICATOR_WIDTH*progress, NSMidY(self.frame) - 50, SWIPE_INDICATOR_WIDTH, 100);
        
        CGFloat alpha = (progress >= 1.0) ? 0.8 : (progress * 0.5);
        [[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:alpha] setFill];
        NSPoint center = NSMakePoint(NSMinX(frame), NSMidY(frame));
        
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:SWIPE_INDICATOR_SCALE_Y];
        [transform translateXBy:0 yBy:-1*0.5*(SWIPE_INDICATOR_SCALE_Y - 1)*NSMidY(frame)];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:center radius:SWIPE_INDICATOR_WIDTH startAngle:90 endAngle:-90];
        [path transformUsingAffineTransform:transform];
        [path fill];
        
        // Adapted from SwipableWebView.
        frame.origin.x -= SWIPE_INDICATOR_WIDTH - 3;
        frame.origin.y += 15;
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
}

// Three fingers gesture, Lion (if enabled) and Leopard
- (void)swipeWithEvent:(NSEvent *)event {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"navigation.swipe.enabled"] == NO)
        return;
    
    CGFloat x = [event deltaX];
    
    if (x != 0) {
		if (x > 0)
            [self.webView goBack];
        else
            [self.webView goForward];
	}
}


-(BOOL) recognizeTwoFingerGestures
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"AppleEnableSwipeNavigateWithScrolls"];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"navigation.swipe.enabled"] == NO)
        return;
    
    if (![self recognizeTwoFingerGestures])
        return;
    
    swipeAmount = 0;
    
    if (_animation != nil) {
        [_animation stopAnimation];
    }
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    _touches = [[NSMutableDictionary alloc] init];
    
    for (NSTouch *touch in touches) {
        [_touches setObject:touch forKey:touch.identity];
    }
}

- (void)endGestureWithEvent:(NSEvent *)event
{
    if (!_touches)
        return;
    
    _animation = [[SwipeAnimation alloc] initWithSwipeView:self];
    [_animation startAnimation];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    // release twoFingersTouches early
    NSMutableDictionary *beginTouches = [_touches copy];
    _touches = nil;
    
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
    
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
        
        if (!beginTouch) continue;
        
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
    
    // Need at least two points
    if ([magnitudes count] < 2) return;
    
    CGFloat sum = 0;
    
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        sum *= -1;
    
    // See if absolute sum is long enough to be considered a complete gesture
    CGFloat absoluteSum = fabsf(sum);
    
    if (absoluteSum < SWIPE_MINIMUM_LENGTH)
        return;
    
    // Handle the actual swipe
    if (sum > 0)
    {
        [self.webView goForward];
    } else
    {
        [self.webView goBack];
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    if (!_touches)
        return;
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
    
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [_touches objectForKey:touch.identity];
        
        if (!beginTouch)
            continue;
        
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
    
    // Need at least two points
    if ([magnitudes count] < 2) {
        return;
    }
    
    CGFloat sum = 0;

    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        sum *= -1;
    
    swipeAmount = sum;
    [self setNeedsDisplay:YES];
}


@end
