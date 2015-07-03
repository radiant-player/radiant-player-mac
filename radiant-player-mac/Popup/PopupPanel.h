/*
 * PopupPanel.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "PopupView.h"

@protocol PopupDelegate <NSObject>

- (void)popupWillShow;
- (void)popupWillClose;
- (void)popupDidDock;
- (void)popupDidUndock;

@end

@class PopupView;

@interface PopupPanel : NSPanel<NSWindowDelegate> {
    BOOL _docked;
    BOOL _undocking;
    NSPoint _undockStartMouse;
    NSRect _undockStartFrame;
}

@property (assign) id<PopupDelegate> popupDelegate;
@property (assign) IBOutlet PopupView *popupView;
@property (assign) BOOL docked;
@property (assign) BOOL isAlwaysOnTop;

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)edge;
- (void)show;
- (void)dock;
- (void)undock;
- (BOOL)isActive;
- (void)closeAndNotify:(BOOL)notify;
- (IBAction)toggleAlwaysOnTop:(id)sender;

@end
