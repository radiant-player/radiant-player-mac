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

@end

@class PopupView;

@interface PopupPanel : NSPanel<NSWindowDelegate>

@property (assign) id<PopupDelegate> popupDelegate;
@property (assign) IBOutlet PopupView *popupView;

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)edge;
- (BOOL)isActive;

- (void)closeAndNotify:(BOOL)notify;

@end
