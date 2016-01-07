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
#import "DDHidAppleRemote.h"
#import "DDHidAppleMikey.h"

#import <Sparkle/Sparkle.h>

@implementation AppDelegate

@synthesize webView;
@synthesize titleView;
@synthesize window;
@synthesize toolbar;
@synthesize menu;
@synthesize controlsMenu;
@synthesize statusItem;
@synthesize statusView;
@synthesize popup;
@synthesize popupDelegate;

@synthesize loadingIndicator;
@synthesize loadingMessage;
@synthesize reloadButton;

@synthesize thumbsUpMenuItem;
@synthesize thumbsDownMenuItem;
@synthesize ratingsSeparatorMenuItem;

@synthesize defaults;
@synthesize prefsController;
@synthesize lastfmPopover;

@synthesize currentTitle;
@synthesize currentArtist;
@synthesize currentAlbum;
@synthesize currentArtURL;
@synthesize currentArt;
@synthesize currentDuration;
@synthesize currentTimestamp;
@synthesize currentPlaybackMode;

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

- (void)receiveSleepNotification:(NSNotification*)notification
{
    if (currentPlaybackMode == MUSIC_PLAYING)
        [self playPause:self];
}

/**
 * Application finished launching, we will register the event tap callback.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window setDelegate:self];

    // Load the user preferences.
    defaults = [NSUserDefaults standardUserDefaults];

    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
    {
        BOOL customTitlebarEnabled = [defaults boolForKey:@"titlebar.enabled"];
        BOOL stylesEnabled = [defaults boolForKey:@"styles.enabled"];

        if (customTitlebarEnabled)
        {
            [self useTallTitleBar];
        }
        else
        {
            [self useNormalTitleBar];
        }

        [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantLight];

        // If the custom titlebar is enabled, register an observer to switch views on maximize/minimize
        if (customTitlebarEnabled)
        {
            [[NSNotificationCenter defaultCenter]
                addObserverForName:NSWindowWillEnterFullScreenNotification
                object:window
                queue:nil
                usingBlock:^(NSNotification *note) {
                    [webView stringByEvaluatingJavaScriptFromString:@"window.Styles.Callbacks.onEnterFullScreen();"];
                    [self useNormalTitleBar];
                }
            ];

            [[NSNotificationCenter defaultCenter]
                addObserverForName:NSWindowWillExitFullScreenNotification
                object:window
                queue:nil
                usingBlock:^(NSNotification *note) {
                    [webView stringByEvaluatingJavaScriptFromString:@"window.Styles.Callbacks.onExitFullScreen();"];
                    [self useTallTitleBar];
                }
            ];
        }
    }
    else
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
    }
    // Set notifications for this window being inactive or active.
    [[NSNotificationCenter defaultCenter]
         addObserverForName:NSWindowDidBecomeMainNotification
         object:window
         queue:nil
         usingBlock:^(NSNotification *note) {
             [webView stringByEvaluatingJavaScriptFromString:@"window.Styles.Callbacks.onWindowDidBecomeActive();"];
         }
     ];

    [[NSNotificationCenter defaultCenter]
         addObserverForName:NSWindowDidResignKeyNotification
         object:window
         queue:nil
         usingBlock:^(NSNotification *note) {
             [webView stringByEvaluatingJavaScriptFromString:@"window.Styles.Callbacks.onWindowDidBecomeInactive();"];
         }
    ];

    // Check if we should be a dock icon or not.
    if (([defaults boolForKey:@"miniplayer.enabled"] && [defaults boolForKey:@"miniplayer.hide-dock-icon"]))
    {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

        // We can't go full screen if we're not a normal application.
        [window setCollectionBehavior:NSWindowCollectionBehaviorDefault];
    }
    else
    {
        // Check if we should be launching in full screen.
        if ([defaults boolForKey:@"window.full-screen"])
        {
            [window toggleFullScreen:self];
        }

        // Keep track of when we enter and exit full screen.
        [[NSNotificationCenter defaultCenter]
             addObserverForName:NSWindowDidEnterFullScreenNotification
             object:nil
             queue:nil
             usingBlock:^(NSNotification *note) {
                 [defaults setBool:YES forKey:@"window.full-screen"];
             }
        ];

        [[NSNotificationCenter defaultCenter]
             addObserverForName:NSWindowDidExitFullScreenNotification
             object:nil
             queue:nil
             usingBlock:^(NSNotification *note) {
                 [defaults setBool:NO forKey:@"window.full-screen"];
             }
        ];
    }

    [[NotificationCenter center] setDelegate:self];

    // Register our custom download protocols.
    [NSURLProtocol registerClass:[SpriteDownloadURLProtocol class]];
    [NSURLProtocol registerClass:[InvertedSpriteURLProtocol class]];
    [NSURLProtocol registerClass:[ImageURLProtocol class]];
    [NSURLProtocol registerClass:[JSURLProtocol class]];

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
    [self refreshMikeys];

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
    [self load:self];

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

    if ([[SUUpdater sharedUpdater] automaticallyChecksForUpdates]) {
        // Run the version check after 10 seconds.
        [[SUUpdater sharedUpdater] performSelector:@selector(checkForUpdatesInBackground) withObject:nil afterDelay:10.0];
    }

    // Load the dummy WebView (for opening links in the default browser).
    dummyWebViewDelegate = [[DummyWebViewPolicyDelegate alloc] init];
    dummyWebView = [[WebView alloc] init];
    [dummyWebView setPolicyDelegate:dummyWebViewDelegate];

    // Register for machine sleep notifications
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSleepNotification:) name:NSWorkspaceWillSleepNotification object:nil];
}

- (NSMutableDictionary *)styles
{
    if (_styles == nil)
    {
        _styles = [ApplicationStyle styles];
        [_styles setObject:[[GoogleStyle alloc] init] forKey:@"Google"];
    }

    return _styles;
}

- (void)initializeStatusBar
{
    statusView = [[PopupStatusView alloc] initWithFrame:NSMakeRect(0, 0, NSSquareStatusItemLength, NSSquareStatusItemLength)];
    [statusView setPopup:popup];
    [statusView setMenu:menu];
    [popup setPopupDelegate:statusView];

    // Toggle the size of the mini-player.
    if ([defaults boolForKey:@"miniplayer.large"] == YES) {
        [[[popup popupView] delegate] togglePlayerSize:self];
    }

    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setHighlightMode:YES];

    [statusView setStatusItem:statusItem];
    [statusView setupStatusItem];
}

- (void)dockPopup:(id)sender
{
    [statusView dockPopup];
}

- (void)setupRatingMenuItems
{
    // Add the appropriate menu items.
    [self setupThumbsUpRatingView];
    [thumbsUpMenuItem setHidden:NO];
    [thumbsDownMenuItem setHidden:NO];
    [ratingsSeparatorMenuItem setHidden:NO];
}

- (void)setupThumbsUpRatingView
{
    [thumbsUpMenuItem setHidden:NO];
    [thumbsDownMenuItem setHidden:NO];
}

/*
 * Modified from @weAreYeah's BSD-licensed WAYWindow
 * https://github.com/weAreYeah/WAYWindow
 */
float _defaultTitleBarHeight() {
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask: NSTitledWindowMask];
    return NSHeight(frame) - NSHeight(contentRect);
}

- (void)_adjustTitleBar
{
    if (![window respondsToSelector:@selector(titlebarAccessoryViewControllers)]) {
        return;
    }

    while ([[window titlebarAccessoryViewControllers] count]) {
        [window removeTitlebarAccessoryViewControllerAtIndex:0];
    }

    if (_isTall) {

        float height = 60 - _defaultTitleBarHeight();

        NSView *accessory = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 10, height)];
        NSTitlebarAccessoryViewController *controller = [[NSTitlebarAccessoryViewController alloc] init];
        [controller setView:accessory];
        [window addTitlebarAccessoryViewController:controller];
    }

    NSArray *buttons = @[
        [window standardWindowButton:NSWindowCloseButton],
        [window standardWindowButton:NSWindowMiniaturizeButton],
        [window standardWindowButton:NSWindowZoomButton]
    ];

    if (_isTall)
    {
        [buttons enumerateObjectsUsingBlock:^(NSButton *button, NSUInteger i, BOOL *stop) {
            NSRect frame = [button frame];
            frame.origin.x += 10;
            frame.origin.y = NSHeight(button.superview.frame)/2 - NSHeight(button.frame)/2;
            [button setFrame:frame];
        }];
    }
}

- (void)useTallTitleBar
{
    _isTall = YES;
    [self _adjustTitleBar];

    NSRect frame = [[self window] frame];
    [window setStyleMask:(window.styleMask | NSFullSizeContentViewWindowMask)];
    [window setTitlebarAppearsTransparent:YES];
    [window setTitleVisibility:NSWindowTitleHidden];
    [[self window] setFrame:frame display:NO];
}

- (void)useNormalTitleBar
{
    _isTall = NO;
    [self _adjustTitleBar];

    NSRect frame = [[self window] frame];
    [window setStyleMask:(window.styleMask & ~NSFullSizeContentViewWindowMask)];
    [window setTitlebarAppearsTransparent:NO];
    [window setTitleVisibility:NSWindowTitleHidden];
    [[self window] setFrame:frame display:NO];
}

- (void) toggleDockArt:(BOOL)showArt
{
    if (showArt && currentArt) {
        [NSApp setApplicationIconImage:currentArt];
    }
    else
    {
        [NSApp setApplicationIconImage:nil];
    }
}

- (void) windowDidResize:(NSNotification *)notification
{
    [self _adjustTitleBar];
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

- (void) pressKey:(NSUInteger)keytype
{
    [self keyEvent:keytype state:0xA]; // key down
    [self keyEvent:keytype state:0xB]; // key up
}

- (void) keyEvent:(NSUInteger)keytype state:(NSUInteger)state
{
    NSEvent *event = [NSEvent otherEventWithType:NSSystemDefined
                                        location:NSZeroPoint
                                   modifierFlags:(state << 2)
                                       timestamp:0
                                    windowNumber:0
                                         context:nil
                                         subtype:0x8
                                           data1:(keytype << 16) | (state << 8)
                                           data2:-1];
    CGEventPost(0, [event CGEvent]);
}

- (void) refreshAllControllers:(NSNotification *) note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshMikeys];
    });
}

- (void) refreshMikeys
{
    NSLog(@"Reset Mikeys");

    if (_mikeys != nil) {
        @try {
            [_mikeys makeObjectsPerformSelector:@selector(stopListening)];
        }
        @catch (NSException *exception) {
            NSLog(@"Error when stopListening on device: %@", exception);
        }
    }
    @try {
        NSArray *mikeys = [DDHidAppleMikey allMikeys];
        _mikeys = [NSMutableArray arrayWithCapacity:mikeys.count];
        for (DDHidAppleMikey *item in mikeys) {
            @try {
                [item setDelegate:self];
                [item setListenInExclusiveMode:NO];
                [item startListening];
                [_mikeys addObject:item];
            }
            @catch (NSException *exception) {
                NSLog(@"Error when startListning on device: %@, exception %@", item, exception);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error obtaining HID devices: %@", [exception description]);
    }
}

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned)usageId upOrDown:(BOOL)upOrDown
{
    if (upOrDown == TRUE) {
        switch (usageId) {
            case kHIDUsage_GD_SystemMenu:
                [self performSelectorOnMainThread:@selector(playPause:)
                                       withObject:nil waitUntilDone:NO];
                break;
            case kHIDUsage_GD_SystemMenuRight:
                [self performSelectorOnMainThread:@selector(forwardAction:)
                                       withObject:nil waitUntilDone:NO];
                break;
            case kHIDUsage_GD_SystemMenuLeft:
                [self performSelectorOnMainThread:@selector(backAction:)
                                       withObject:nil waitUntilDone:NO];
                break;
            case kHIDUsage_GD_SystemMenuUp:
                // [self pressKey:NX_KEYTYPE_SOUND_UP];
                break;
            case kHIDUsage_GD_SystemMenuDown:
                // [self pressKey:NX_KEYTYPE_SOUND_DOWN];
                break;
            default:
                NSLog(@"Unknown key press seen %d", usageId);
        }
    }
}

#pragma mark - Web Browser Actions

- (void) load:(id)sender
{
    [loadingIndicator setHidden:NO];
    [loadingIndicator startAnimation:self];
    [loadingMessage setHidden:NO];
    [loadingMessage setStringValue:@"Loading Google Play Music..."];
    [reloadButton setHidden:YES];
    [[reloadButton superview] setHidden:NO];

    NSURL *url = [NSURL URLWithString:@"https://play.google.com/music"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:request];
}

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
    // We can only move the window if we're not in full screen mode.
    if (([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask)
        return;

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
 * Sets the volume of Google Play Music.
 */
- (void) setVolume:(int)volume
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MusicAPI.Volume.setVolume(%d)", volume]];
}

- (IBAction) volumeSliderChanged:(id)sender
{
    [self setVolume:[sender intValue]];
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

/**
 * Sets focus on the search bar
 */
- (IBAction) focusSearch:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.querySelector('#material-one-middle input.sj-search-box').select()"];
}

/**
 * Allow the user to Select All on the web view.
 */
- (IBAction) selectAll:(id)sender
{
    [webView selectAll:sender];
}

- (void)notifySong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album art:(NSString *)art duration:(NSTimeInterval)duration
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];

    if ([defaults boolForKey:@"lastfm.enabled"])
    {
        [LastFmService scrobbleSong:currentTitle withArtist:currentArtist album:currentAlbum duration:currentDuration timestamp:currentTimestamp percentage:[defaults stringForKey:@"lastfm.percentage"]];
        [LastFmService sendNowPlaying:title withArtist:artist album:album duration:duration timestamp:timestamp];
    }

    [self setupRatingMenuItems];


    // Update our current data.
    currentTitle = title;
    currentArtist = artist;
    currentAlbum = album;
    currentArtURL = art;
    currentArt = nil;
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
        [[NotificationCenter center] scheduleNotificationWithTitle:title artist:artist album:album imageURL:art];
    }

    if ([defaults boolForKey:@"dock.show-art"])
    {
        if (art != nil) {
            [self performSelectorInBackground:@selector(downloadAlbumArt:) withObject:art];
        }
        else
        {
            [NSApp setApplicationIconImage: nil];
        }
    }
}

- (void)downloadAlbumArt:(NSString *)art
{
    NSURL *url = [NSURL URLWithString:art];
    currentArt = [[NSImage alloc] initWithContentsOfURL:url];

    [self toggleDockArt:[defaults boolForKey:@"dock.show-art"]];
}

- (NSString *)currentSongURL
{
    // Get the shareable URL of the current song.
    return [webView stringByEvaluatingJavaScriptFromString:@"window.MusicAPI.Extras.getSongURL()"];
}

#pragma mark - Playback Notifications

- (void)playbackChanged:(NSInteger)mode
{
    currentPlaybackMode = mode;
    [popupDelegate playbackChanged:mode];
    [statusView setPlaybackMode:mode];
    [statusView setNeedsDisplay:YES];

    if (mode == MUSIC_STOPPED) {
        [NSApp setApplicationIconImage: nil];
        currentArt = nil;
    }
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

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    NSString *url = [[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey];
    NSString *reason = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];

    if ([url isEqualToString:@"https://play.google.com/music"]) {
        [loadingIndicator stopAnimation:self];
        [loadingMessage setStringValue:reason];
        [reloadButton setHidden:NO];
        [[reloadButton superview] setHidden:NO];
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    NSString *url = [[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey];
    NSString *reason = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];

    if ([url isEqualToString:@"https://play.google.com/music"]) {
        [loadingIndicator stopAnimation:self];
        [loadingMessage setStringValue:reason];
        [reloadButton setHidden:NO];
        [[reloadButton superview] setHidden:NO];
    }
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
    NSString *url = [[[[frame dataSource] request] URL] absoluteString];

    if ([url isEqualToString:@"https://play.google.com/music/listen"]) {
        [loadingIndicator setHidden:YES];
        [loadingMessage setHidden:YES];
        [reloadButton setHidden:YES];
        [[reloadButton superview] setHidden:YES];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // Only apply the main script file when the player is ready.
    if ([[webView mainFrameDocument] querySelector:@"#playerSongInfo"]) {
        [self evaluateJavaScriptFile:@"main"];
    }

    [self evaluateJavaScriptFile:@"styles"];

    // Apply common styles.
    [self applyCSSFile:@"common"];

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

    if (!style) {
        [defaults setObject:@"Google" forKey:@"styles.name"];
        [defaults synchronize];
    }

    if (!stylesEnabled || !style)
        style = [_styles objectForKey:@"Google"];

    [style applyToWebView:webView window:window];

    [self setupRatingMenuItems];

    // Communicate with the navigation system on the new status of the back-forward list.
    BOOL canGoBack = [webView canGoBack];
    BOOL canGoForward = [webView canGoForward];
    NSString *call = [NSString stringWithFormat:@"window.GMNavigation.Callbacks.onHistoryChange(%@, %@)", canGoBack ? @"true" : @"false", canGoForward ? @"true" : @"false"];
    [[webView windowScriptObject] evaluateWebScript:call];
}

- (id)preferenceForKey:(NSString *)key
{
    if (key != nil)
        return [defaults valueForKey:key];
    else
        return nil;
}

- (BOOL)isYosemite
{
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
}

- (void) evaluateJavaScriptFile:(NSString *)name
{
    NSString *template =
        @"if (document.querySelector('#rp-script-%1$@') == null) {"
        "    var js = document.createElement('script');"
        "    js.id = 'rp-script-%1$@';"
        "    js.src = 'https://radiant-player-mac/js/%1$@.js';"
        "    document.head.appendChild(js);"
        "}";
    NSString *insert = [NSString stringWithFormat:template, name];
    [webView stringByEvaluatingJavaScriptFromString:insert];
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

    if (sel == @selector(isYosemite))
        return @"isYosemite";

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
        sel == @selector(preferenceForKey:) ||
        sel == @selector(isYosemite))
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

#pragma mark - NotificationActivationDelegate

- (void) notificationWasActivated:(NotificationActivationType)activationType
{
    if (activationType == NotificationActivationTypeButtonClicked) {
        [self forwardAction:self];
    }
    else if (activationType == NotificationActivationTypeContentsClicked) {
        [NSApp activateIgnoringOtherApps:YES];
        [window makeKeyAndOrderFront:self];
    }
}

@end
