//
//  AppDelegate.h
//  GoogleMusic
//
//  Created by James Fator on 5/16/13.
//  Modified by Sajid Anwar, 2014.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import <WebKit/WebKit.h>

#import "CustomWebView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, CustomWebViewDelegate, NSUserNotificationCenterDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;

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
