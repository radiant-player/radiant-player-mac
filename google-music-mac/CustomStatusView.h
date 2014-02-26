/*
 * CustomStatusView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "PopupPanel.h"

@interface CustomStatusView : NSView<NSPopoverDelegate, PopupDelegate>

@property (retain) id globalMonitor;
@property (retain) NSPopover *popover;
@property (retain) PopupPanel *popup;
@property (assign) BOOL active;

- (void)showPopover;
- (void)hidePopover;

@end
