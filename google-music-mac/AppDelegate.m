/*
 * AppDelegate.m
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize webView;
@synthesize window;
@synthesize statusItem;
@synthesize statusView;
@synthesize popup;
@synthesize popupDelegate;
@synthesize defaults;

/**
 * Closing the application, hides the player window but keeps music playing in the background.
 */

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    
    [window makeKeyAndOrderFront:self];
    
    return YES;
}

- (BOOL)windowShouldClose:(NSNotification *)notification
{
    [window orderOut:self];
    return NO;
}

/**
 * Set defaults.
 */
+ (void)initialize
{
    // Register default preferences.
    NSString *prefsPath = [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
}

/**
 * Application finished launching, we will register the event tap callback.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Load the user preferences.
    defaults = [NSUserDefaults standardUserDefaults];
    
	// Add an event tap to intercept the system defined media key events
    eventTap = CGEventTapCreate(kCGSessionEventTap,
                                kCGHeadInsertEventTap,
                                kCGEventTapOptionDefault,
                                CGEventMaskBit(NX_SYSDEFINED),
                                event_tap_callback,
                                (__bridge void *)(self));
	if (!eventTap) {
		fprintf(stderr, "failed to create event tap\n");
		exit(1);
	}
    
	//Create a run loop source.
	eventPortSource = CFMachPortCreateRunLoopSource( kCFAllocatorDefault, eventTap, 0 );
    
	//Enable the event tap.
    CGEventTapEnable(eventTap, true);
    
    // Let's do this in a separate thread so that a slow app doesn't lag the event tap
    [NSThread detachNewThreadSelector:@selector(eventTapThread) toTarget:self withObject:nil];
    
    [webView setAppDelegate:self];
    
    // Load the main page
    NSURL *url = [NSURL URLWithString:@"https://play.google.com/music"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:request];
    
    WebPreferences *preferences = [webView preferences];
    [preferences setPlugInsEnabled:YES];
    
    if ([defaults boolForKey:@"menupopup.enabled"])
    {
        // Initialize the system status bar menu.
        [self initializeStatusBar];
    }
    else
    {
        popup = nil;
        popupDelegate = nil;
    }

    // Load the dummy WebView (for opening links in the default browser).
    dummyWebViewDelegate = [[DummyWebViewPolicyDelegate alloc] init];
    dummyWebView = [[WebView alloc] init];
    [dummyWebView setPolicyDelegate:dummyWebViewDelegate];
}

- (void)initializeStatusBar
{
    statusView = [[PopupStatusView alloc] initWithFrame:NSMakeRect(0, 0,
                                                                    NSSquareStatusItemLength,
                                                                    NSSquareStatusItemLength)];
    statusView.popup = popup;
    [popup setPopupDelegate:statusView];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setView:statusView];
}


#pragma mark - Event tap methods

/**
 * eventTapThread is the selector that adds the callback thread into the loop.
 */
- (void)eventTapThread
{
    CFRunLoopRef tapThreadRL = CFRunLoopGetCurrent();
    CFRunLoopAddSource( tapThreadRL, eventPortSource, kCFRunLoopCommonModes );
    CFRunLoopRun();
}

/**
 * event_tap_callback is the event callback that recognizes the keys we want
 *   and launches the assigned commands.
 */
static CGEventRef event_tap_callback(CGEventTapProxy proxy,
                                     CGEventType type,
                                     CGEventRef event,
                                     void *refcon)
{
    AppDelegate *self = (__bridge AppDelegate *)(refcon);
    
    if(type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        CGEventTapEnable(self->eventTap, TRUE);
        return event;
    }
    
    if (!(type == NX_SYSDEFINED) || (type == NX_KEYDOWN))
        return event;
    
    NSEvent* keyEvent = [NSEvent eventWithCGEvent: event];
    if (keyEvent.type != NSSystemDefined || keyEvent.subtype != 8) return event;
    
    int keyCode = (([keyEvent data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([keyEvent data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    
    OSStatus err = noErr;
    ProcessSerialNumber psn;
    err = GetProcessForPID([[NSProcessInfo processInfo] processIdentifier], &psn);
    
    switch( keyCode )
    {
		case NX_KEYTYPE_PLAY:   // F8
			if( keyState == 0 ) {
                [self performSelectorOnMainThread:@selector(playPause:)
                                       withObject:nil waitUntilDone:NO];
            }
            return NULL;
            
		case NX_KEYTYPE_FAST:   // F9
        case NX_KEYTYPE_NEXT:
			if( keyState == 0 ) {
                [self performSelectorOnMainThread:@selector(forwardAction:)
                                       withObject:nil waitUntilDone:NO];
            }
            return NULL;
            
		case NX_KEYTYPE_REWIND:   // F7
        case NX_KEYTYPE_PREVIOUS:
			if( keyState == 0 ) {
                [self performSelectorOnMainThread:@selector(backAction:)
                                       withObject:nil waitUntilDone:NO];
            }
            return NULL;
    }
    return event;
}

#pragma mark - Web Browser Actions

- (void) webBrowserBack:(id)sender
{
    [webView goBack];
}

- (void) webBrowserForward:(id)sender
{
    [webView goForward];
}

- (void)moveWindowWithDeltaX:(CGFloat)deltaX andDeltaY:(CGFloat)deltaY
{
    // Position starts at the bottom left, so the y-value is reversed.
    NSPoint position = window.frame.origin;
    position.x += deltaX;
    position.y -= deltaY;
    
    [window setFrameOrigin:position];
}

#pragma mark - Play Actions

/**
 * playPause toggles the playing status for the app
 */
- (IBAction) playPause:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.playPause()"];
}

/**
 * forwardAction skips track forward
 */
- (IBAction) forwardAction:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.forward()"];
}

/**
 * backAction skips track backwards
 */
- (IBAction) backAction:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.rewind()"];
}

/**
 * Increases volume of Google Music by 10.
 */
- (IBAction) volumeUp:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Volume.increaseVolume(10)"];
}

/**
 * Decreases volume of Google Music by 10.
 */
- (IBAction) volumeDown:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Volume.decreaseVolume(10)"];
}

/**
 * Toggle the song's thumbs up rating.
 */
- (IBAction) toggleThumbsUp:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Rating.toggleThumbsUp()"];
}

/**
 * Toggle the song's thumbs down rating.
 */
- (IBAction) toggleThumbsDown:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Rating.toggleThumbsDown()"];
}

/**
 * Cycle between the repeat modes.
 */
- (IBAction) toggleRepeatMode:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.changeRepeat()"];
}

/**
 * Set to NO_REPEAT.
 */
- (IBAction) repeatNone:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.changeRepeat(MusicAPI.Playback.NO_REPEAT)"];
}

/**
 * Set to SINGLE_REPEAT.
 */
- (IBAction) repeatSingle:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.changeRepeat(MusicAPI.Playback.SINGLE_REPEAT)"];
}

/**
 * Set to LIST_REPEAT.
 */
- (IBAction) repeatList:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.changeRepeat(MusicAPI.Playback.LIST_REPEAT)"];
}

/**
 * Toggle the shuffle mode.
 */
- (IBAction) toggleShuffle:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.toggleShuffle()"];
}

/**
 * Toggle the player's visualization.
 */
- (IBAction) toggleVisualization:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Playback.toggleVisualization()"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self evaluateJavaScriptFile:@"main"];
    [self evaluateJavaScriptFile:@"keyboard"];
    [self evaluateJavaScriptFile:@"styles"];
    [self evaluateJavaScriptFile:@"navigation"];
    [[sender windowScriptObject] setValue:self forKey:@"googleMusicApp"];
    
    // Always apply the navigation styles.
    [self applyCSSFile:@"navigation"];
    
    // Apply certain styles and JS only if the user prefers.
    if ([defaults boolForKey:@"styles.enabled"])
    {
        [window setBackgroundColor:[NSColor colorWithCalibratedRed:0.88f green:0.88f blue:0.88f alpha:1.0f]];
        [self applyCSSFile:@"cocoa"];
        [self evaluateJavaScriptFile:@"appbar"];
    }
}

- (void)notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art
{
    if ([defaults boolForKey:@"notifications.enabled"])
    {
        if (popup != nil && popupDelegate != nil) {
            [popupDelegate updateSong:title artist:artist album:album art:art];
            
            if ([popup isVisible])
                return;
        }
        
        NSUserNotification *notif = [[NSUserNotification alloc] init];
        notif.title = title;
        notif.informativeText = [NSString stringWithFormat:@"%@ — %@", artist, album];
        
        // Try to load the album art if possible.
        if ([defaults boolForKey:@"notifications.showAlbumArt"] && art)
         {
            NSURL *url = [NSURL URLWithString:art];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
            
            notif.contentImage = image;
        }
        
        // Remove the previous notifications in order to make this notification appear immediately.
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        
        // Deliver the notification.
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notif];
    }
}

#pragma mark - Playback Notifications

- (void)playbackChanged:(NSInteger)mode
{
    [popupDelegate playbackChanged:mode];
}

- (void)playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime
{
    [popupDelegate playbackTimeChanged:currentTime totalTime:totalTime];
}

- (void)repeatChanged:(NSString *)mode
{
    [popupDelegate repeatChanged:mode];
}

- (void)shuffleChanged:(NSString *)mode
{
    [popupDelegate shuffleChanged:mode];
}
    
- (void)ratingChanged:(NSInteger)rating
{
    [popupDelegate ratingChanged:rating];
}

#pragma mark - Web
    
- (void) evaluateJavaScriptFile:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"js/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
}

- (void) applyCSSFile:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"css/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"css"];
    NSString *css = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    css = [css stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    css = [css stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *bootstrap = @"Styles.applyStyle(\"%@\", \"%@\");";
    NSString *final = [NSString stringWithFormat:bootstrap, name, css];
    
    [webView stringByEvaluatingJavaScriptFromString:final];
}

/*
 * Some links expect a new WebView (a tab or a window), but instead we'll try to 
 * pass the URL to a dummy WebView, which will open it in the default browser.
 */
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    return dummyWebView;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(notifySong:withArtist:album:art:))
        return @"notifySong";
    
    if (sel == @selector(playbackChanged:))
        return @"playbackChanged";
    
    if (sel == @selector(playbackTimeChanged:totalTime:))
        return @"playbackTimeChanged";
    
    if (sel == @selector(repeatChanged:))
        return @"repeatChanged";
    
    if (sel == @selector(shuffleChanged:))
        return @"shuffleChanged";
    
    if (sel == @selector(ratingChanged:))
        return @"ratingChanged";
    
    if (sel == @selector(moveWindowWithDeltaX:andDeltaY:))
        return @"moveWindow";
    
    return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(notifySong:withArtist:album:art:) ||
        sel == @selector(playbackChanged:) ||
        sel == @selector(playbackTimeChanged:totalTime:) ||
        sel == @selector(repeatChanged:) ||
        sel == @selector(shuffleChanged:) ||
        sel == @selector(ratingChanged:) ||
        sel == @selector(moveWindowWithDeltaX:andDeltaY:))
        return NO;
    
    return YES;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSLog(@"%@", message);
}
    
    
    
+ (NSImage *)imageFromName:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"images/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"png"];
    
    return [[NSImage alloc] initWithContentsOfFile:path];
}

@end
