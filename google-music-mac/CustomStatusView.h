/*
 * CustomStatusView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface CustomStatusView : NSView<NSPopoverDelegate>

@property (retain) id globalMonitor;
@property (retain) NSPopover *popover;
@property (assign) BOOL active;

- (void)showPopover;
- (void)hidePopover;

@end
