/*
 * RatingBadgeButton.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "RatingBadgeButton.h"

@implementation RatingBadgeButton

@synthesize starRatingView;
@synthesize infoView;

-(void)awakeFromNib
{
    _entered = NO;
    
    NSRect badgeRect = [self frame];
    NSRect starRect = [starRatingView frame];
    NSRect box = NSMakeRect(NSMinX(starRect),
                            NSMinY(starRect),
                            NSMaxX(badgeRect) - NSMinX(starRect),
                            NSMaxY(badgeRect) - NSMinY(starRect));
    
    NSRect badgeBounds = [self bounds];
    badgeBounds = NSInsetRect(badgeBounds, 1, 1);
    
    /*
     * The idea is to enter on the badge area, but exit for the combined badge and rating view.
     */
    
    NSTrackingArea *boxArea = [[NSTrackingArea alloc]
                               initWithRect:[self convertRectFromBacking:box]
                                    options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
                                    owner:self
                                    userInfo:@{@"badge": [NSNumber numberWithBool:NO]}];
    
    NSTrackingArea *badgeArea = [[NSTrackingArea alloc]
                                    initWithRect:badgeBounds
                                    options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
                                    owner:self
                                    userInfo:@{@"badge": [NSNumber numberWithBool:YES]}];
    
    [self addTrackingArea:boxArea];
    [self addTrackingArea:badgeArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSDictionary *info = (NSDictionary *)[theEvent userData];
    
    if (info && [[info objectForKey:@"badge"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        _entered = YES;
        
        [starRatingView setEnabled:YES];
        [[starRatingView animator] setAlphaValue:1.0];
        [[infoView animator] setAlphaValue:0.1];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSDictionary *info = (NSDictionary *)[theEvent userData];
    
    if (info && [[info objectForKey:@"badge"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        _entered = NO;
        
        [starRatingView setEnabled:NO];
        [[starRatingView animator] setAlphaValue:0.0];
        [[infoView animator] setAlphaValue:1.0];
    }
}

@end
