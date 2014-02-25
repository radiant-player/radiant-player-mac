/*
 * CustomStatusView.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

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

- (void)popoverWillShow:(NSNotification *)notification
{
    self.active = YES;
    [self setNeedsDisplay:YES];
}

- (void)popoverWillClose:(NSNotification *)notification
{
    self.active = NO;
    [self setNeedsDisplay:YES];
}

@end
