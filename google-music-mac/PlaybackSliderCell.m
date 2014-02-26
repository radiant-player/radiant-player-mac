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
    NSRect aRect = [self trackRect];
    NSFont *font = [NSFont fontWithName:@"Helvetica" size:9.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        font, NSFontAttributeName, nil
    ];
    
    NSPoint curPoint = NSMakePoint(aRect.origin.x, aRect.origin.y + 3);
    NSInteger curMinutes = ((self.integerValue / 1000) / 60);
    NSInteger curSeconds = ((self.integerValue / 1000) % 60);
    NSAttributedString *curTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:%02d", curMinutes, curSeconds]
                                                                  attributes:attributes];
    
    [[NSColor orangeColor] set];
    NSRect curTimeRect = NSMakeRect(curPoint.x, curPoint.y, curTime.size.width + 6, curTime.size.height + 2);
    NSRectFill(curTimeRect);
    
    curPoint.x += 3;
    curPoint.y += 1;
    [curTime drawAtPoint:curPoint];
    
    NSPoint totalPoint = NSMakePoint(aRect.size.width, aRect.origin.y + 3);
    NSInteger totalMinutes = ((int)(self.maxValue / 1000) / 60);
    NSInteger totalSeconds = ((int)(self.maxValue / 1000) % 60);
    NSAttributedString *totalTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:%02d", totalMinutes, totalSeconds]
                                                                    attributes:attributes];
    
    [[NSColor grayColor] set];
    NSRect totalTimeRect = NSMakeRect(totalPoint.x - totalTime.size.width - 6, totalPoint.y, totalTime.size.width + 6, totalTime.size.height + 2);
    NSRectFill(totalTimeRect);
    
    totalPoint.x = totalPoint.x - totalTime.size.width - 3;
    totalPoint.y += 1;
    [totalTime drawAtPoint:totalPoint];
}

@end
