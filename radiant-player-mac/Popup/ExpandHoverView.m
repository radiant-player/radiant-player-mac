/*
 * ExpandHoverView.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "ExpandHoverView.h"

@implementation ExpandHoverView

@synthesize trackingArea;

- (void)awakeFromNib
{
    [self setAlphaValue:0.0];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[self animator] setAlphaValue:1.0];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[self animator] setAlphaValue:0.0];
}

- (void)updateTrackingAreas
{
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

@end
