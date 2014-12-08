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
#import <EDStarRating/EDStarRating.h>

#import "Notifications/NotificationCenter.h"

#import "DummyWebViewPolicyDelegate.h"
#import "CustomWebView.h"
#import "InvertedSpriteURLProtocol.h"
#import "SpriteDownloadURLProtocol.h"
#import "ImageURLProtocol.h"

#import "PopupStatusView.h"
#import "PopupViewDelegate.h"
#import "PopupPanel.h"

#import "PreferencesWindowController.h"
#import "ApplicationStyle.h"
#import "LastFmPopover.h"
#import "TitleBarTextView.h"

@class PopupViewDelegate;
@class PopupStatusView;
@class PopupPanel;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, CustomWebViewDelegate, EDStarRatingProtocol, NotificationCenterDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
    
    NSMutableDictionary *_styles;
    BOOL _isTall;
    
    WebView *dummyWebView;
    DummyWebViewPolicyDelegate *dummyWebViewDelegate;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSMenu *menu;
@property (assign) IBOutlet NSMenu *controlsMenu;

@property (assign) IBOutlet NSProgressIndicator *loadingIndicator;
@property (assign) IBOutlet NSTextField *loadingMessage;
@property (assign) IBOutlet NSButton *reloadButton;

@property (nonatomic, retain) TitleBarTextView *titleView;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) PopupStatusView *statusView;
@property (nonatomic, retain) IBOutlet PopupPanel *popup;
@property (assign) IBOutlet PopupViewDelegate *popupDelegate;

@property (assign) IBOutlet NSMenuItem *thumbsUpMenuItem;
@property (assign) IBOutlet NSMenuItem *thumbsDownMenuItem;
@property (assign) IBOutlet NSMenuItem *starRatingMenuItem;
@property (assign) IBOutlet EDStarRating *starRatingView;
@property (assign) IBOutlet NSTextField *starRatingLabel;
@property (assign) IBOutlet NSMenuItem *ratingsSeparatorMenuItem;

@property (nonatomic, retain) IBOutlet LastFmPopover *lastfmPopover;

@property (assign) IBOutlet PreferencesWindowController *prefsController;
@property (assign) NSUserDefaults *defaults;

@property (copy, nonatomic) NSString *currentTitle;
@property (copy, nonatomic) NSString *currentArtist;
@property (copy, nonatomic) NSString *currentAlbum;
@property (copy, nonatomic) NSString *currentArtURL;
@property (copy, nonatomic) NSImage *currentArt;
@property (assign) NSTimeInterval currentDuration;
@property (assign) NSTimeInterval currentTimestamp;
@property (assign) NSInteger currentPlaybackMode;
@property (assign) BOOL isStarsRatingSystem;

- (void) checkVersion;
- (void) initializeStatusBar;
- (NSMutableDictionary *) styles;
- (void) setupThumbsUpRatingView;
- (void) setupStarRatingView;
- (void) setupRatingMenuItems;
- (void) useTallTitleBar;
- (void) useNormalTitleBar;

- (IBAction) load:(id)sender;
- (IBAction) webBrowserBack:(id)sender;
- (IBAction) webBrowserForward:(id)sender;

- (IBAction) setPlaybackTime:(NSInteger)milliseconds;

- (IBAction) playPause:(id)sender;
- (IBAction) forwardAction:(id)sender;
- (IBAction) backAction:(id)sender;

- (IBAction) volumeSliderChanged:(id)sender;
- (IBAction) volumeUp:(id)sender;
- (IBAction) volumeDown:(id)sender;
- (void) setVolume:(int)value;

- (IBAction) toggleThumbsUp:(id)sender;
- (IBAction) toggleThumbsDown:(id)sender;
- (void) setStarRating:(NSInteger)rating;

- (IBAction) toggleRepeatMode:(id)sender;
- (IBAction) repeatNone:(id)sender;
- (IBAction) repeatSingle:(id)sender;
- (IBAction) repeatList:(id)sender;

- (IBAction) toggleShuffle:(id)sender;
- (IBAction) toggleVisualization:(id)sender;
- (IBAction) focusSearch:(id)sender;

- (NSString *) currentSongURL;

- (void) moveWindowWithDeltaX:(CGFloat)deltaX andDeltaY:(CGFloat)deltaY;
- (void) showLastFmPopover:(id)sender;
- (void) notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art duration:(NSTimeInterval)duration;

// Refer to PlaybackConstants.m
- (void) shuffleChanged:(NSString *)mode;
- (void) repeatChanged:(NSString *)mode;
- (void) playbackChanged:(NSInteger)mode;
- (void) playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void) ratingChanged:(NSInteger)rating;

- (id) preferenceForKey:(NSString *)key;
- (BOOL) isYosemite;

- (void) evaluateJavaScriptFile:(NSString *)name;
- (void) applyCSSFile:(NSString *)name;
+ (NSString *) webScriptNameForSelector:(SEL)sel;
+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel;
    
@end
