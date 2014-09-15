/*
 * PopupStatusView.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopupStatusView.h"
#import "PlaybackConstants.h"

@implementation PopupStatusView

@synthesize popup;
@synthesize menu = _menu;
@synthesize statusItem;
@synthesize active;
@synthesize playbackMode;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setActive:NO];
    }
    return self;
}

- (void)setupStatusItem
{
    if ([statusItem respondsToSelector:@selector(button)]) {
        id button = [statusItem button];
        [button setImage:[self buttonImage]];
        [button setTarget:self];
        [button setAction:@selector(buttonAction:)];
        [button sendActionOn:(NSLeftMouseDownMask|NSRightMouseDownMask|NSLeftMouseUpMask)];
    }
    else {
        [statusItem setView:self];
    }
}

- (NSImage *)buttonImage
{
    NSRect rect = [[self buttonView] frame];
    rect = NSInsetRect(rect, 3, 1);
    
    NSImage *image = [Utilities imageFromName:@"menuicon"];
    [image setTemplate:YES];
    [image setSize:rect.size];
    return image;
}

- (NSRect)buttonFrame
{
    if ([statusItem respondsToSelector:@selector(button)]) {
        id button = [statusItem button];
        NSRect rectInWindow = [button convertRect:[button bounds] toView:nil];
        NSRect screenRect = [[button window] convertRectToScreen:rectInWindow];
        
        return screenRect;
    }
    else {
        return [self frame];
    }
}

- (NSView *)buttonView {
    if ([statusItem respondsToSelector:@selector(button)]) {
        return [statusItem button];
    }
    else {
        return self;
    }
}

- (void)update
{
    
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
    
    rect = NSInsetRect(rect, 2, 0);
    
    NSString *imageName;
	
    // Draw the status bar item (highlight or not).
    if (self.active) {
        [[NSColor selectedMenuItemColor] set];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"miniplayer.show-playing-status"] &&
            playbackMode == MUSIC_PLAYING) {
            imageName = @"menuicon_playing_white";
        }
        else {
            imageName = @"menuicon_white";
        }
    }
    else {
        [[NSColor clearColor] set];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"miniplayer.show-playing-status"] &&
            playbackMode == MUSIC_PLAYING) {
            imageName = @"menuicon_playing";
        }
        else {
            imageName = @"menuicon";
        }
    }
    
    NSRectFill(rect);
    NSImage *icon = [Utilities imageFromName:imageName];
    [icon drawInRect:NSInsetRect(rect, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
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
        [statusItem popUpStatusItemMenu:_menu];\
    }
}

- (void)buttonAction:(id)sender
{
    NSEventType type = [[NSApp currentEvent] type];
    
    if (type == NSRightMouseDown) {
        [self rightMouseDown:nil];
    }
    else if (type == NSLeftMouseDown) {
        [self mouseDown:nil];
    }
}

- (void)showPopup
{
    [popup showRelativeToRect:[self buttonFrame] ofView:[self buttonView] preferredEdge:NSMinYEdge];
    
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
    [statusItem setMenu:menu];
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
