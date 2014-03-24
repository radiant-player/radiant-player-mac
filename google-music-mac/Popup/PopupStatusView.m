/*
 * PopupStatusView.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopupStatusView.h"

@implementation PopupStatusView

@synthesize popup;
@synthesize menu = _menu;
@synthesize statusItem;
@synthesize active;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setActive:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
    
    rect = NSInsetRect(rect, 2, 0);
	
    // Draw the status bar item (highlight or not).
    if (self.active) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(rect);
        
        NSImage *icon = [Utilities imageFromName:@"menuicon_white"];
        [icon drawInRect:NSInsetRect(rect, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    else {
        [[NSColor clearColor] set];
        NSRectFill(rect);
        
        NSImage *icon = [Utilities imageFromName:@"menuicon"];
        [icon drawInRect:NSInsetRect(rect, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.active) {
        [self hidePopup];
    }
    else {
        [self showPopup];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if (statusItem != nil && _menu != nil) {
        [statusItem popUpStatusItemMenu:_menu];
    }
}

- (void)showPopup
{
    [popup showRelativeToRect:[self frame] ofView:self preferredEdge:NSMinYEdge];
    
    if (self.globalMonitor == nil)
    {
        self.globalMonitor =
            [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUp|NSRightMouseUp
                     handler:^(NSEvent *ev) {
                         if ([popup isActive])
                             [self hidePopup];
                     }];
    }
}

- (void)hidePopup
{
    [self setActive:NO];
    [self setNeedsDisplay:YES];
    
    [popup close];
}

- (void)popupWillShow
{
    [self setActive:YES];
    [self setNeedsDisplay:YES];
}

- (void)popupWillClose
{
    [self setActive:NO];
    [self setNeedsDisplay:YES];
}

- (NSMenu *)menu
{
    return _menu;
}

- (void)setMenu:(NSMenu *)menu
{
    _menu = menu;
    [_menu setDelegate:self];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    // Hide the popup if it is visible.
    if ([popup isActive])
        [popup closeAndNotify:NO];
    
    // Highlight the status item when the menu opens.
    [self setActive:YES];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    // Unhighlight the status item when the menu closes.
    [self setActive:NO];
    [self setNeedsDisplay:YES];
}

@end
