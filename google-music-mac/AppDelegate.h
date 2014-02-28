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

#import "DummyWebViewPolicyDelegate.h"
#import "CustomWebView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, CustomWebViewDelegate, NSUserNotificationCenterDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
    
    WebView *dummyWebView;
    DummyWebViewPolicyDelegate *dummyWebViewDelegate;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;

@property (assign) NSUserDefaults *defaults;

@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *authorizeButton;

@property (copy, nonatomic) NSString *prevTitle;
@property (copy, nonatomic) NSString *prevArtist;
@property (copy, nonatomic) NSString *prevAlbum;
@property NSTimeInterval prevDuration;
@property NSTimeInterval prevTimestamp;

- (void) syncLastFm;
- (IBAction)authorizeScrobble:(NSButton *)sender;
- (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration;

- (IBAction) webBrowserBack:(id)sender;
- (IBAction) webBrowserForward:(id)sender;

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

- (void) moveWindowWithDeltaX:(CGFloat)deltaX andDeltaY:(CGFloat)deltaY;

- (void) notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art duration:(NSTimeInterval)duration;

- (void) evaluateJavaScriptFile:(NSString *)name;
- (void) applyCSSFile:(NSString *)name;
+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel;

@end
