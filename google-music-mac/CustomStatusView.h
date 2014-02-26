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

@interface CustomStatusView : NSView<PopupDelegate>

@property (retain) id globalMonitor;
@property (retain) PopupPanel *popup;
@property (assign) BOOL active;

- (void)showPopup;
- (void)hidePopup;

@end
