/*
 * PopupPanel.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopupPanel.h"

@implementation PopupPanel

@synthesize popupDelegate;
@synthesize popupView;

-(void)awakeFromNib
{
    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];
    [self setLevel:NSPopUpMenuWindowLevel];
    [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorTransient];
    [self setFloatingPanel:YES];
    [self setHidesOnDeactivate:NO];
    [self setDelegate:self];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    [self close];
}

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)edge
{
    if (popupDelegate)
        [popupDelegate popupWillShow];
    
    NSRect statusRect = [view.window convertRectToScreen:view.bounds];
    NSRect screenRect = [[NSScreen mainScreen] frame];
    
    NSRect frame = NSMakeRect(statusRect.origin.x,
                              statusRect.origin.y - self.frame.size.height - 2,
                              self.frame.size.width,
                              self.frame.size.height);
    
    frame.origin.x = NSMidX(statusRect) - (frame.size.width / 2);
    
    // Check if the frame goes off screen.
    if (NSMaxX(frame) > NSMaxX(screenRect)) {
        frame.origin.x -= NSMaxX(frame) - NSMaxX(screenRect);
    }
    
    CGFloat arrowX = NSMidX(statusRect) - NSMinX(frame);
    [popupView setArrowX:arrowX];
    
    statusRect.origin.x -= statusRect.size.width / 2;
    
    [self setAlphaValue:0];
    [self setFrame:frame display:YES];
    [self makeKeyAndOrderFront:nil];
    [self.popupView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    [[self animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (BOOL)isActive
{
    return [self isKeyWindow];
}

- (void)close
{
    [self closeAndNotify:YES];
}

- (void)closeAndNotify:(BOOL)notify
{
    if (notify && popupDelegate != nil)
        [popupDelegate popupWillClose];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.15];
    [[self animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];

}

@end
