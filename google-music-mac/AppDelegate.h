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

#import "PopupStatusView.h"
#import "DummyWebViewPolicyDelegate.h"
#import "CustomWebView.h"
#import "PopupViewDelegate.h"
#import "PopupPanel.h"
#import "PreferencesWindowController.h"
#import "ApplicationStyle.h"

@class PopupViewDelegate;
@class PopupStatusView;
@class PopupPanel;

@interface AppDelegate : NSObject <NSApplicationDelegate, CustomWebViewDelegate, NSUserNotificationCenterDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
    
    NSMutableDictionary *_styles;
    
    WebView *dummyWebView;
    DummyWebViewPolicyDelegate *dummyWebViewDelegate;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) PopupStatusView *statusView;
@property (nonatomic, retain) IBOutlet PopupPanel *popup;
@property (assign) IBOutlet PopupViewDelegate *popupDelegate;

@property (assign) IBOutlet PreferencesWindowController *prefsController;
@property (assign) NSUserDefaults *defaults;

@property (copy, nonatomic) NSString *currentTitle;
@property (copy, nonatomic) NSString *currentArtist;
@property (copy, nonatomic) NSString *currentAlbum;
@property (assign) NSTimeInterval currentDuration;
@property (assign) NSTimeInterval currentTimestamp;

- (void) checkVersion;
- (void) initializeStatusBar;
- (NSMutableDictionary *) styles;
    
- (IBAction) webBrowserBack:(id)sender;
- (IBAction) webBrowserForward:(id)sender;

- (IBAction) setPlaybackTime:(NSInteger)milliseconds;

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

// Refer to PlaybackConstants.m
- (void) shuffleChanged:(NSString *)mode;
- (void) repeatChanged:(NSString *)mode;
- (void) playbackChanged:(NSInteger)mode;
- (void) playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void) ratingChanged:(NSInteger)rating;

- (id) preferenceForKey:(NSString *)key;

- (void) evaluateJavaScriptFile:(NSString *)name;
- (void) applyCSSFile:(NSString *)name;
+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel;
    
@end
