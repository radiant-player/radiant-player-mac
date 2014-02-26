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

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [NSGraphicsContext restoreGraphicsState];
    
    aRect.origin.y += 1;
    aRect.size.height -= 2;
    
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
    
    [[NSColor grayColor] set];
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
    NSAttributedString *curTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:%02d", curMinutes, curSeconds]
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
    NSAttributedString *totalTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:%02d", totalMinutes, totalSeconds]
                                                                    attributes:attributes];
    
    [[NSColor grayColor] set];
    NSBezierPath *totalTimePath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(totalPoint.x - totalTime.size.width - 6, totalPoint.y, totalTime.size.width + 6, totalTime.size.height + 2)
                                                                  xRadius:3
                                                                  yRadius:3];
    [totalTimePath fill];
    
    totalPoint.x = totalPoint.x - totalTime.size.width - 3;
    [totalTime drawAtPoint:totalPoint];
}

@end
