/*
 * PlaybackSliderCell.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PlaybackSliderCell.h"

@implementation PlaybackSliderCell

@synthesize changing;

/* Don't allow changing of the slider when it is being dragged */
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    [self setChanging:NO];
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    [self setChanging:YES];
    return [super startTrackingAt:startPoint inView:controlView];
}

- (void)setDoubleValue:(double)aDouble
{
    if ([self changing])
        return;
    
    [super setDoubleValue:aDouble];
}

- (void)setIntegerValue:(NSInteger)anInteger
{
    if ([self changing])
        return;
    
    [super setIntegerValue:anInteger];
}

- (NSRect)barRectFlipped:(BOOL)flipped
{
    NSRect rect = [[self controlView] bounds];
    rect = NSInsetRect(rect, 3, 9);
    return rect;
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [NSGraphicsContext restoreGraphicsState];
    
    NSRect knobRect = [self knobRectFlipped:true];
    
    NSRect left = aRect;
    left.size.width = knobRect.origin.x + knobRect.size.width - 5;
    [[NSColor orangeColor] set];
    NSRectFill(left);
    
    NSRect right = aRect;
    right.origin.x = left.size.width;
    right.size.width = right.size.width - right.origin.x;
    [[NSColor grayColor] set];
    NSRectFill(right);
    
    [NSGraphicsContext saveGraphicsState];
}

- (void)drawKnob:(NSRect)knobRect
{
    knobRect = NSInsetRect(knobRect, 5, 5);
    
    [[NSColor orangeColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:knobRect];
    [path fill];
    
    /* Draw the current and total times. */
    NSRect aRect = NSInsetRect([self trackRect], 2, 0);
    NSFont *font = [NSFont boldSystemFontOfSize:9.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        font, NSFontAttributeName,
        nil
    ];
    
    NSPoint curPoint = NSMakePoint(aRect.origin.x, aRect.origin.y + 3);
    NSInteger curMinutes = ((self.integerValue / 1000) / 60);
    NSInteger curSeconds = ((self.integerValue / 1000) % 60);
    NSAttributedString *curTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld:%02ld", (long)curMinutes, (long)curSeconds]
                                                                  attributes:attributes];
    
    [[NSColor orangeColor] set];
    NSBezierPath *curTimePath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(curPoint.x, curPoint.y, curTime.size.width + 6, curTime.size.height + 2)
                                                                xRadius:3
                                                                yRadius:3];
    [curTimePath fill];
    
    curPoint.x += 3;
    [curTime drawAtPoint:curPoint];
    
    NSPoint totalPoint = NSMakePoint(aRect.size.width, aRect.origin.y + 3);
    NSInteger totalMinutes = ((int)(self.maxValue / 1000) / 60);
    NSInteger totalSeconds = ((int)(self.maxValue / 1000) % 60);
    NSAttributedString *totalTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld:%02ld", (long)totalMinutes, (long)totalSeconds]
                                                                    attributes:attributes];
    
    [[NSColor grayColor] set];
    NSBezierPath *totalTimePath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(totalPoint.x - totalTime.size.width - 4, totalPoint.y, totalTime.size.width + 6, totalTime.size.height + 2)
                                                                  xRadius:3
                                                                  yRadius:3];
    [totalTimePath fill];
    
    totalPoint.x = totalPoint.x - totalTime.size.width - 1;
    [totalTime drawAtPoint:totalPoint];
}

- (void) drawWithFrame: (NSRect)cellFrame inView: (NSView*)controlView {
    NSRect barFrame = [self barRectFlipped:[controlView isFlipped]];
    [self drawBarInside:barFrame flipped:[controlView isFlipped]];
    [self drawKnob];
}

@end
