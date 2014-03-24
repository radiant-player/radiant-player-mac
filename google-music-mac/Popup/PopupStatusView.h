/*
 * PopupStatusView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "PopupPanel.h"

@interface PopupStatusView : NSView<PopupDelegate, NSMenuDelegate>
{
    NSMenu *_menu;
}

@property (retain) id globalMonitor;
@property (retain) PopupPanel *popup;
@property (retain) NSMenu *menu;
@property (retain) NSStatusItem *statusItem;
@property (nonatomic) BOOL active;

- (void)showPopup;
- (void)hidePopup;

@end
