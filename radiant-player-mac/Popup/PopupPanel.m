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
@synthesize docked = _docked;
@synthesize isAlwaysOnTop;

-(void)awakeFromNib
{
    
    _docked = NO;
    _undockStartMouse = NSMakePoint(0, 0);
    _undockStartFrame = [self frame];
    _undocking = NO;
    
    self.isAlwaysOnTop = [[NSUserDefaults standardUserDefaults] boolForKey:@"miniplayer.always-on-top"];
    
    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];
    [self setLevel:NSPopUpMenuWindowLevel];
    [self setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace|NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorFullScreenAuxiliary];
    [self setFloatingPanel:self.isAlwaysOnTop];
    [self setHidesOnDeactivate:NO];
    [self setDelegate:self];
    [self dock];
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(isAlwaysOnTop)) options:0 context:NULL];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (_docked)
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
    [self toggleAlwaysOnTop:nil];
    [self toggleAlwaysOnTop:nil];
    
    [self.popupView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    [[self animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)show
{
    if (popupDelegate)
        [popupDelegate popupWillShow];
    
    [self setAlphaValue:0];
    
    [self makeKeyAndOrderFront:nil];
    [self toggleAlwaysOnTop:nil];
    [self toggleAlwaysOnTop:nil];
    
    [self.popupView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    [[self animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (BOOL)isActive
{
    return [self isKeyWindow] || ([self isFloatingPanel] && [self alphaValue] > 0);
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

- (void)mouseDown:(NSEvent *)ev
{
    if (_docked) {
        _undockStartMouse = [NSEvent mouseLocation];
        _undockStartFrame = [self frame];
        _undocking = YES;
    }
}

- (void)mouseUp:(NSEvent *)ev
{
    if (_undocking) {
        _undockStartFrame = [self frame];
        _undockStartMouse = NSMakePoint(0, 0);
        _undocking = NO;
    }
    
    [self setMovableByWindowBackground:!_docked];
}

- (void)mouseDragged:(NSEvent *)ev
{
    if (_undocking) {
        NSPoint mouseOrigin = [NSEvent mouseLocation];
        float deltaX = mouseOrigin.x - _undockStartMouse.x;
        float deltaY = mouseOrigin.y - _undockStartMouse.y;
        float distance = sqrt(deltaX * deltaX + deltaY * deltaY);
        
        if (distance < 30) {
            [self setFrame:_undockStartFrame display:NO];
            [self dock];
        }
        else {
            NSRect newFrame = _undockStartFrame;
            newFrame.origin.x += deltaX;
            newFrame.origin.y += deltaY;
            [self setFrame:newFrame display:NO];
            [self undock];
        }
    }
}

- (void)dock
{
    if (!_docked)
    {
        _docked = YES;
        [[popupView delegate] popupDidDock];
        
        if (popupDelegate && [popupDelegate respondsToSelector:@selector(popupDidDock)])
            [popupDelegate popupDidDock];
    }
}

- (void)undock
{
    if (_docked)
    {
        _docked = NO;
        [[popupView delegate] popupDidUndock];
        
        if (popupDelegate && [popupDelegate respondsToSelector:@selector(popupDidUndock)])
            [popupDelegate popupDidUndock];
    }
}

- (void)toggleAlwaysOnTop:(id)sender
{
    self.isAlwaysOnTop = !self.isAlwaysOnTop;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isAlwaysOnTop))])
    {
        [self setFloatingPanel:self.isAlwaysOnTop];
        [[NSUserDefaults standardUserDefaults] setBool:isAlwaysOnTop forKey:@"miniplayer.always-on-top"];
    }
}

@end
