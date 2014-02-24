/*
 * AppDelegate.h
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import <WebKit/WebKit.h>

#import "CustomStatusView.h"
#import "CustomWebView.h"
#import "PopoverDelegate.h"

@class PopoverDelegate;

@interface AppDelegate : NSObject <NSApplicationDelegate, CustomWebViewDelegate, NSUserNotificationCenterDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) CustomStatusView *statusView;
@property (nonatomic, retain) IBOutlet NSPopover *popover;
@property (assign) IBOutlet PopoverDelegate *popoverDelegate;

@property (assign) NSUserDefaults *defaults;

- (void) initializeStatusBar;

- (IBAction) playPause:(id)sender;
- (IBAction) forwardAction:(id)sender;
- (IBAction) backAction:(id)sender;

- (IBAction) volumeUp:(id)sender;
- (IBAction) volumeDown:(id)sender;

- (IBAction) toggleThumbsUp:(id)sender;
- (IBAction) toggleThumbsDown:(id)sender;

- (IBAction) toggleRepeatMode:(id)sender;
- (IBAction) repeatNone:(id)sender;
- (IBAction) repeatSingle:(id)sender;
- (IBAction) repeatList:(id)sender;

- (IBAction) toggleShuffle:(id)sender;
- (IBAction) toggleVisualization:(id)sender;

- (void) notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art;

- (void) evaluateJavaScriptFile:(NSString *)name;
- (void) applyCSSFile:(NSString *)name;
+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel;

@end
