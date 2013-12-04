//
//  AppDelegate.h
//  GoogleMusic
//
//  Created by James Fator on 5/16/13.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import <WebKit/WebKit.h>

#import "CustomWebView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, CustomWebViewDelegate>
{
	CFMachPortRef eventTap;
    CFRunLoopSourceRef eventPortSource;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet CustomWebView *webView;

- (void) playPause;
- (void) forwardAction;
- (void) backAction;

@end
