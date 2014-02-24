//
//  CustomStatusView.m
//  google-music-mac
//
//  Created by Sajid Anwar on 23/02/2014.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import "CustomStatusView.h"

@implementation CustomStatusView

@synthesize popover;
@synthesize active;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.active = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
    // Draw the status bar item (highlight or not).
    if (self.active) {
        [[NSColor selectedMenuItemColor] set];
    }
    else {
        [[NSColor clearColor] set];
    }
    
    NSRectFill(rect);
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.active) {
        [self hidePopover];
    }
    else {
        [self showPopover];
    }
}

- (void)showPopover
{
    self.active = YES;
    [self setNeedsDisplay:YES];
    
    [popover showRelativeToRect:[self frame] ofView:self preferredEdge:NSMinYEdge];
    
    if (self.globalMonitor == nil)
    {
        self.globalMonitor =
            [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUp|NSRightMouseUp
                     handler:^(NSEvent *ev) {
                         [self hidePopover];
                     }];
    }
}

- (void)hidePopover
{
    self.active = NO;
    [self setNeedsDisplay:YES];
    
    [popover close];
}

@end
