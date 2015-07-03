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

@class PopupPanel;
@protocol PopupDelegate;

@interface PopupStatusView : NSView<PopupDelegate, NSMenuDelegate>
{
    NSMenu *_menu;
}

@property (retain) id globalMonitor;
@property (retain) PopupPanel *popup;
@property (retain) NSMenu *menu;
@property (retain) NSStatusItem *statusItem;
@property (nonatomic) BOOL active;
@property (assign) NSInteger playbackMode;

- (void)setupStatusItem;
- (void)update;
- (NSRect)buttonFrame;
- (NSView *)buttonView;
- (NSImage *)buttonImage;

- (void)showPopup;
- (void)hidePopup;
- (void)dockPopup;

@end
