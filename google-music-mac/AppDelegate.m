/*
 * AppDelegate.m
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "AppDelegate.h"
#import "LastFmService.h"

@implementation AppDelegate

@synthesize webView;
@synthesize titleView;
@synthesize window;
@synthesize statusItem;
@synthesize statusView;
@synthesize popup;
@synthesize popupMenu;
@synthesize popupDelegate;
@synthesize defaults;
@synthesize prefsController;
@synthesize lastfmPopover;

@synthesize currentTitle;
@synthesize currentArtist;
@synthesize currentAlbum;
@synthesize currentDuration;
@synthesize currentTimestamp;

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
    [NSApp hide:self];
    return NO;
}

/**
 * Application finished launching, we will register the event tap callback.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Put in our custom title text view.
    titleView = [[TitleBarTextView alloc] initWithFrame:[[[window contentView] superview] bounds]];
    [titleView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [titleView setTitle:window.title];
    [titleView setColor:nil];

    [[window.contentView superview] addSubview:titleView
                                    positioned:NSWindowBelow
                                    relativeTo:[[[window.contentView superview] subviews] firstObject]];
    
    // Change the title bar color.
    [window setTitle:@""];
    [window setBackgroundColor:[NSColor colorWithSRGBRed:0.945 green:0.945 blue:0.945 alpha:1]];
    
    // Load the user preferences.
    defaults = [NSUserDefaults standardUserDefaults];
    
    // Check if we should be a dock icon or not.
    if (([defaults boolForKey:@"miniplayer.enabled"] && [defaults boolForKey:@"miniplayer.hide-dock-icon"]))
    {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [window setCollectionBehavior:NSWindowCollectionBehaviorDefault];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Register our custom download protocols.
    [NSURLProtocol registerClass:[SpriteDownloadURLProtocol class]];
    [NSURLProtocol registerClass:[InvertedSpriteURLProtocol class]];
    [NSURLProtocol registerClass:[ImageURLProtocol class]];

	// Add an event tap to intercept the system defined media key events
    CGEventMask mask = ([defaults boolForKey:@"eventtap.alternative-method"])
                        ? kCGEventMaskForAllEvents
                        : NX_SYSDEFINEDMASK;
    
    eventTap = CGEventTapCreate(kCGSessionEventTap,
                                kCGHeadInsertEventTap,
                                kCGEventTapOptionDefault,
                                mask,
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
    
    if ([defaults boolForKey:@"miniplayer.enabled"]) {
        // Initialize the system status bar menu.
        [self initializeStatusBar];
    }
    else {
        popup = nil;
        popupDelegate = nil;
    }
    
    if ([defaults boolForKey:@"updates.check"]) {
        // Run the version check after 5 seconds.
        [self performSelector:@selector(checkVersion) withObject:nil afterDelay:10.0];
    }

    // Load the dummy WebView (for opening links in the default browser).
    dummyWebViewDelegate = [[DummyWebViewPolicyDelegate alloc] init];
    dummyWebView = [[WebView alloc] init];
    [dummyWebView setPolicyDelegate:dummyWebViewDelegate];
}

- (void)checkVersion
{
    NSString *appName = [Utilities applicationName];
    NSString *appVersion = [Utilities applicationVersion];
    NSString *latestVersion = [Utilities latestVersionFromGithub];
    
    if (latestVersion != nil && [Utilities isVersionUpToDateWithApplication:appVersion latest:latestVersion] == NO) {
        // Application is out of date.
        NSString *messageFormat = @"You are running version %@ of %@, but the latest version is %@. Do you want to be taken to the download page?";
        NSString *message = [NSString stringWithFormat:messageFormat, appVersion, appName, latestVersion];
        
        NSAlert *updateAlert = [[NSAlert alloc] init];
        [updateAlert setIcon:[NSApp applicationIconImage]];
        [updateAlert setMessageText:@"Update Available"];
        [updateAlert setInformativeText:message];
        [updateAlert addButtonWithTitle:@"OK"];
        [updateAlert addButtonWithTitle:@"Cancel"];
        [updateAlert addButtonWithTitle:@"Don't check for updates"];
        
        NSButton *dontButton = [[updateAlert buttons] objectAtIndex:2];
        [dontButton setButtonType:NSSwitchButton];
        [dontButton setState:NSOffState];
        [dontButton setAction:nil];
        [dontButton setTarget:nil];
        
        NSModalResponse response = [updateAlert runModal];
        
        // If the user hit OK, open the homepage in the default browser.
        if (response == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[Utilities applicationHomepage]]];
        }
        
        // If the user selected "dont check for updates", set that preference.
        if ([dontButton state] == NSOnState) {
            [defaults setBool:NO forKey:@"updates.check"];
            [defaults synchronize];
        }
    }
}

- (NSMutableDictionary *)styles
{
    if (_styles == nil)
        _styles = [ApplicationStyle styles];
    
    return _styles;
}

- (void)initializeStatusBar
{
    statusView = [[PopupStatusView alloc] initWithFrame:NSMakeRect(0, 0, NSSquareStatusItemLength, NSSquareStatusItemLength)];
    [statusView setPopup:popup];
    [statusView setMenu:popupMenu];
    [popup setPopupDelegate:statusView];
    
    // Toggle the size of the mini-player.
    if ([defaults boolForKey:@"miniplayer.large"] == YES) {
        [[[popup popupView] delegate] togglePlayerSize:self];
    }
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setView:statusView];
    
    [statusView setStatusItem:statusItem];
}

- (void)showLastFmPopover:(id)sender
{
    if ([lastfmPopover isShown] == NO)
    {
        DOMDocument *document = [webView mainFrameDocument];
        DOMElement *lastfmButton = [document querySelector:@"#lastfmButton"];
        
        if (lastfmButton != nil)
        {
            // The coordinate systems are different:
            //   - Cocoa's x-axis is on the bottom of the screen
            //   - DOM's x-axis is on the top of the screen
            NSRect webviewRect = [webView bounds];
            NSRect buttonRect = [lastfmButton boundingBox];
            buttonRect.origin.y = webviewRect.size.height - buttonRect.origin.y - buttonRect.size.height;
            
            [lastfmPopover showRelativeToRect:buttonRect ofView:webView preferredEdge:NSMaxYEdge];
            [lastfmPopover refreshTracks];
        }
    }
    else
    {
        [lastfmPopover performClose:sender];
    }
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
    
    if (type != NX_SYSDEFINED)
        return event;
    
    NSEvent* keyEvent = [NSEvent eventWithCGEvent: event];
    if (keyEvent.type != NSSystemDefined || keyEvent.subtype != 8)
        return event;
    
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
 * setPlaybackTime changes the time of the song to the number of milliseconds
 */
- (IBAction) setPlaybackTime:(NSInteger)milliseconds
{
    NSString *js = [NSString stringWithFormat:@"MusicAPI.Playback.setPlaybackTime(%ld)", (long)milliseconds];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

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
 * Increases volume of Google Play Music by 10.
 */
- (IBAction) volumeUp:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"MusicAPI.Volume.increaseVolume(10)"];
}

/**
 * Decreases volume of Google Play Music by 10.
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

- (void)notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art duration:(NSTimeInterval)duration
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    if ([defaults boolForKey:@"lastfm.enabled"])
    {
        [LastFmService scrobbleSong:currentTitle withArtist:currentArtist album:currentAlbum duration:currentDuration timestamp:currentTimestamp];
        [LastFmService sendNowPlaying:title withArtist:artist album:album duration:duration timestamp:timestamp];
    }
    
    // Update our current data.
    currentTitle = title;
    currentArtist = artist;
    currentAlbum = album;
    currentDuration = duration;
    currentTimestamp = timestamp;
    
    if (popup != nil && popupDelegate != nil)
    {
        [popupDelegate updateSong:title artist:artist album:album art:art];
        
        // Don't show the notification if the popup is visible.
        if ([popup isVisible])
            return;
    }

    if ([defaults boolForKey:@"notifications.enabled"])
    {
        NSUserNotification *notif = [[NSUserNotification alloc] init];
        notif.title = title;
        
        if ([defaults boolForKey:@"notifications.itunes-style"]) {
            notif.subtitle = [NSString stringWithFormat:@"%@ — %@", artist, album];
            [notif setValue:@YES forKey:@"_showsButtons"];
        }
        else {
            notif.informativeText = [NSString stringWithFormat:@"%@ — %@", artist, album];
        }
        
        // Make sure the version of OS X supports this.
        if ([notif respondsToSelector:@selector(setContentImage:)])
        {
            // Try to load the album art if possible.
            if ([defaults boolForKey:@"notifications.show-album-art"] && art)
            {
                NSURL *url = [NSURL URLWithString:art];
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
                
                if ([defaults boolForKey:@"notifications.itunes-style"]) {
                    [notif setValue:image forKey:@"_identityImage"];
                }
                else {
                    notif.contentImage = image;
                }
            }
        }
        
        notif.actionButtonTitle = @"Skip";
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

        // Remove the previous notifications in order to make this notification appear immediately.
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        
        // Deliver the notification.
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notif];
    }
}

#pragma mark - Playback Notifications

- (void)playbackChanged:(NSInteger)mode
{
    [popupDelegate playbackChanged:mode];
    [statusView setPlaybackMode:mode];
    [statusView setNeedsDisplay:YES];
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
    if ([defaults boolForKey:@"lastfm.thumbsup.enabled"])
    {
        // Notify Last.fm of the rating change.
        if (rating == MUSIC_RATING_THUMBSUP) {
            id failureHandler = ^(NSError *error) { NSLog(@"Couldn't love track: %@", error); };
            [LastFmService loveTrack:currentTitle artist:currentArtist successHandler:nil failureHandler:failureHandler];
        }
        else {
            id failureHandler = ^(NSError *error) { NSLog(@"Couldn't unlove track: %@", error); };
            [LastFmService unloveTrack:currentTitle artist:currentArtist successHandler:nil failureHandler:failureHandler];
        }
    }
    
    [popupDelegate ratingChanged:rating];
}

#pragma mark - Web

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:self forKey:@"GoogleMusicApp"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self evaluateJavaScriptFile:@"keyboard"];
    [self evaluateJavaScriptFile:@"mouse"];
    [self evaluateJavaScriptFile:@"main"];
    [self evaluateJavaScriptFile:@"styles"];
    
    // Apply the navigation styles.
    [self applyCSSFile:@"navigation"];
    [self evaluateJavaScriptFile:@"navigation"];
    
    // Apply the Last.fm JS and CSS.
    if ([defaults boolForKey:@"lastfm.button.enabled"])
    {
        [self applyCSSFile:@"lastfm"];
        [self evaluateJavaScriptFile:@"lastfm"];
    }
    
    [self evaluateJavaScriptFile:@"appbar"];
    
    // Apply certain styles and JS only if the user prefers.
    BOOL stylesEnabled = [defaults boolForKey:@"styles.enabled"];
    NSString *styleName = [defaults stringForKey:@"styles.name"];
    ApplicationStyle *style = [_styles objectForKey:styleName];
    
    if (stylesEnabled && style)
    {
        [style applyToWebView:webView];
        [window setBackgroundColor:[style windowColor]];
        [titleView setColor:[style titleColor]];
    }
}

- (id)preferenceForKey:(NSString *)key
{
    if (key != nil)
        return [defaults valueForKey:key];
    else
        return nil;
}
    
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
    if (sel == @selector(notifySong:withArtist:album:art:duration:))
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
    
    if (sel == @selector(showLastFmPopover:))
        return @"showLastFmPopover";
    
    if (sel == @selector(preferenceForKey:))
        return @"preferenceForKey";
    
    return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)sel
{
    if (sel == @selector(notifySong:withArtist:album:art:duration:) ||
        sel == @selector(playbackChanged:) ||
        sel == @selector(playbackTimeChanged:totalTime:) ||
        sel == @selector(repeatChanged:) ||
        sel == @selector(shuffleChanged:) ||
        sel == @selector(ratingChanged:) ||
        sel == @selector(moveWindowWithDeltaX:andDeltaY:) ||
        sel == @selector(showLastFmPopover:) ||
        sel == @selector(preferenceForKey:))
        return NO;
    
    return YES;
}


- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    
    if ([panel runModal] == NSOKButton) {
        [resultListener chooseFilename:[[panel URL] relativePath]];
    }
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSLog(@"%@", message);
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
        [self forwardAction:center];
    }
    else if (notification.activationType == NSUserNotificationActivationTypeContentsClicked) {
        [NSApp activateIgnoringOtherApps:YES];
        [window makeKeyAndOrderFront:self];
    }
}

@end
