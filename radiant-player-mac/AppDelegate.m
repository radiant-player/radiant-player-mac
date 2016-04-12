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
#import "BarakaLyricGenius.h"
#import "BarakaLyricWikia.h"
#import "BarakaLyricMetro.h"
#import "BarakaLyricAZ.h"

#import <Sparkle/Sparkle.h>

@interface AppDelegate ()
@property (strong, nonatomic) NSMutableArray *BarakaGetLyrics;
@end

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
                    [webView stringByEvaluatingJavaScriptFromString:@"try{window.RadiantStyle.Callbacks.onEnterFullScreen();}catch(e){}"];
                    [self useNormalTitleBar];
                }
            ];

            [[NSNotificationCenter defaultCenter]
                addObserverForName:NSWindowWillExitFullScreenNotification
                object:window
                queue:nil
                usingBlock:^(NSNotification *note) {
                    [webView stringByEvaluatingJavaScriptFromString:@"try{window.RadiantStyle.Callbacks.onExitFullScreen();}catch(e){}"];
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
             [webView stringByEvaluatingJavaScriptFromString:@"try{window.RadiantStyle.Callbacks.onWindowDidBecomeActive();}catch(e){}"];
         }
     ];

    [[NSNotificationCenter defaultCenter]
         addObserverForName:NSWindowDidResignKeyNotification
         object:window
         queue:nil
         usingBlock:^(NSNotification *note) {
             [webView stringByEvaluatingJavaScriptFromString:@"try{window.RadiantStyle.Callbacks.onWindowDidBecomeInactive();}catch(e){}"];
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
    NSString *js = [NSString stringWithFormat:@"gmusic.playback.setPlaybackTime(%ld)", (long)milliseconds];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

/**
 * playPause toggles the playing status for the app
 */
- (IBAction) playPause:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.playPause()"];
}

/**
 * forwardAction skips track forward
 */
- (IBAction) forwardAction:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.forward()"];
}

/**
 * backAction skips track backwards
 */
- (IBAction) backAction:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.rewind()"];
}

/**
 * Increases volume of Google Play Music by 10.
 */
- (IBAction) volumeUp:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.volume.increaseVolume(10)"];
}

/**
 * Decreases volume of Google Play Music by 10.
 */
- (IBAction) volumeDown:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.volume.decreaseVolume(10)"];
}

/**
 * Sets the volume of Google Play Music.
 */
- (void) setVolume:(int)volume
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"gmusic.volume.setVolume(%d)", volume]];
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
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.rating.toggleThumbsUp()"];
}

/**
 * Toggle the song's thumbs down rating.
 */
- (IBAction) toggleThumbsDown:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.rating.toggleThumbsDown()"];
}

/**
 * Cycle between the repeat modes.
 */
- (IBAction) toggleRepeatMode:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.toggleRepeat()"];
}

/**
 * Set to NO_REPEAT.
 */
- (IBAction) repeatNone:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.changeRepeat(GMusic.Playback.NO_REPEAT)"];
}

/**
 * Set to SINGLE_REPEAT.
 */
- (IBAction) repeatSingle:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.changeRepeat(GMusic.Playback.SINGLE_REPEAT)"];
}

/**
 * Set to LIST_REPEAT.
 */
- (IBAction) repeatList:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.changeRepeat(GMusic.Playback.LIST_REPEAT)"];
}

/**
 * Toggle the shuffle mode.
 */
- (IBAction) toggleShuffle:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.toggleShuffle()"];
}

/**
 * Toggle the player's visualization.
 */
- (IBAction) toggleVisualization:(id)sender
{
    [webView stringByEvaluatingJavaScriptFromString:@"gmusic.playback.toggleVisualization()"];
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
        
        /* Start BarakaLyrics */
        [self fetchBarakaLyrics:currentTitle withArtist:currentArtist album:currentAlbum];
        
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
    return [webView stringByEvaluatingJavaScriptFromString:@"window.gmusic.extras.getSongURL()"];
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
        [self evaluateJavaScriptFile:@"gmusic"];
        [self evaluateJavaScriptFile:@"main"];
    }

    [self evaluateJavaScriptFile:@"styles"];

    // Apply common styles.
    [self applyCSSFile:@"common"];

    // Apply flexbox fix for Yosemite and Mavericks
    if ([self isYosemite] || [self isMavericks]) {
        [self applyCSSFile:@"flexfix"];
    }

    // Apply zindex fix for El Capitan
    if ([self isElCapitan]) {
        [self applyCSSFile:@"zindex"];
    }

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

- (BOOL)isElCapitan
{
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_10_Max;
}

- (BOOL)isYosemite
{
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
}

- (BOOL)isMavericks
{
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8;
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

    NSString *bootstrap = @"try{window.RadiantStyle.applyStyle(\"%@\", \"%@\");}catch(e){}";
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

- (void) fetchBarakaLyrics:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album {
    
    if (![defaults boolForKey:@"BarakaLyrics"]) {
        return;
    }
    
    [self.BarakaGetLyrics Jumble];
    self.BarakaGetLyrics = [NSMutableArray arrayWithArray:@[[BarakaLyricGenius new],[BarakaLyricWikia new],[BarakaLyricMetro new],[BarakaLyricAZ new]]];
    
    /* Lets Inject our LyricObject Handler And BarakaModals */
    NSString *format =@"%@";
    NSString *var =@"var BarakaLyrics = {};if(typeof BarakaRadiant==\"undefined\"&&typeof BarakaModal==\"undefined\"){var BarakaRadiant={}}BarakaRadiant={hasLyrics:null,init:function(){var b=BarakaRadiant.create('<style id=\"baraka-modal\">.BarakaModal{will-change:visibility, opacity;display:-webkit-box;display:-webkit-flex;display:flex;-webkit-box-align:center;-webkit-align-items:center;align-items:center;-webkit-box-pack:center;-webkit-justify-content:center;justify-content:center;position:fixed;z-index:2;top:7.7%;left:0px;right:0px;visibility:hidden;opacity:0;/*-webkit-transition:all .5s cubic-bezier(0.23, 1, 0.32, 1);transition:all .5s cubic-bezier(0.23,1,0.32,1);*/-webkit-transition-delay:0s;transition-delay:0s}.BarakaModal-active{visibility:visible;opacity:1}.BarakaModal-align-top{-webkit-box-align:start;-webkit-align-items:flex-start;align-items:flex-start}.BarakaModal_bg{background:transparent}.BarakaModal_dialog{max-width:800px;/*padding: 1.2rem;*/position:relative;z-index:9;top:7.7%;left:0%;right:0%;bottom:0%;margin:0 auto}.BarakaModal_dialog:before,.BarakaModal_dialog:after{content:\"\";width:99.1%;height:24px;position:absolute;left:1px;z-index:100}.BarakaModal_dialog:before{background-image:-webkit-linear-gradient(bottom, rgba(255, 255, 255, 0) 0%, rgb(255, 255, 255) 100%);background-image:linear-gradient(bottom, rgba(255, 255, 255, 0) 0%, rgb(255, 255, 255) 100%);top:1px;border-top-left-radius:6px;border-top-right-radius:6px}.BarakaModal_dialog:after{background-image:-webkit-linear-gradient(top, rgba(255, 255, 255, 0) 0%, rgb(255, 255, 255) 100%);background-image:linear-gradient(top, rgba(255, 255, 255, 0) 0%, rgb(255, 255, 255) 100%);bottom:1px;border-bottom-left-radius:6px;border-bottom-right-radius:6px}.BarakaModal_content{will-change:transform, opacity;position:relative;padding:2.4rem;background:rgba(255, 255, 255, 0.9);background-clip:padding-box;box-shadow:0 12px 15px 0 rgba(0, 0, 0, 0.25);opacity:0;-webkit-transition:all .25s cubic-bezier(0.23, 1, 0.32, 1);transition:all .25s cubic-bezier(0.23, 1, 0.32, 1);border:1px solid #ddd;border-radius:6px;-webkit-border-radius:6px;font-weight:700!important;font-family:\"Helvetica Neue\",Helvetica,Arial,sans-serif!important;white-space:pre-line}.BarakaModal_content-active{opacity:1;max-height:400px;overflow:auto}.BarakaModal_close{z-index:1100;cursor:pointer}.BarakaModal_trigger{-webkit-transition:all .5s cubic-bezier(0.23, 1, 0.32, 1);transition:all .5s cubic-bezier(0.23,1,0.32,1)}.BarakaModal_trigger-active{z-index:10}.BarakaModal_trigger:hover{background:#ddd}#BarakaModal_temp{will-change:transform, opacity;position:absolute;top:50%;left:0;right:0;bottom:0;background:transparent;-webkit-transform:none;transform:none;opacity:1;-webkit-transition:opacity .1s ease-out, -webkit-transform .5s cubic-bezier(0.23, 1, 0.32, 1);transition:opacity .1s ease-out, transform .5s cubic-bezier(0.23,1,0.32,1)}.bd-close{position:absolute;top:0;right:0;margin:1.8rem;padding: .2rem;height:23px;background:rgba(0, 0, 0, 0.3);border-radius:50%;-webkit-transition:all .5s cubic-bezier(0.23, 1, 0.32, 1);transition:all .5s cubic-bezier(0.23, 1, 0.32, 1)}.bd-close svg{width:24px;fill:#fff;pointer-events:none;vertical-align:top}.bd-close:hover{background:rgba(0,0,0,0.9)}.BarakaMaterial-box{overflow:scroll;width:300px;max-height:136px;position:absolute;z-index:99;transform:translateY(15px);opacity:0;visibility:hidden;-webkit-transition:all 250ms cubic-bezier(0.4, 0, 0.2, 1);transition:all 250ms cubic-bezier(0.4,0,0.2,1)}.BarakaModal::-webkit-scrollbar,.BarakaModal_content::-webkit-scrollbar,.BarakaMaterial-box::-webkit-scrollbar{display:none}.BarakaMaterial-box .BarakaMaterial-box__inner{position:relative;border-radius:3px;color:#fff;overflow:hidden}.BarakaMaterial-box .BarakaMaterial-box__content{background:rgba(255, 255, 255, 0.9);width:300px;height:auto;position:relative;z-index:3;opacity:0;-webkit-transition:all 300ms cubic-bezier(0.4, 0, 0.2, 1);transition:all 300ms cubic-bezier(0.4, 0, 0.2, 1);font-weight:700!important;font-family:\"Helvetica Neue\",Helvetica,Arial,sans-serif!important}.BarakaMaterial-box .BarakaMaterial-box__circle{width:10px;height:10px;background:rgba(255, 255, 255, 0.9);position:absolute;left:46%;bottom:-35%;border-radius:50%;z-index:2;-webkit-transition:all 400ms cubic-bezier(0.4, 0, 0.2, 1);transition:all 400ms cubic-bezier(0.4, 0, 0.2, 1)}.BarakaMaterial-box .BarakaMaterial-box__header{margin:0 -16px -16px;padding:10px 15px;line-height:initial;text-align:center;border-bottom:1px solid #cacaca;color:black}.BarakaMaterial-box--show{opacity:1;visibility:visible;transform:translateY(0);border-radius:4px;border:1px solid #cacaca;box-shadow:0 12px 15px 0 rgba(0, 0, 0, 0.25)}.BarakaMaterial-box--show .BarakaMaterial-box__content{opacity:1}.BarakaMaterial-box--show .BarakaMaterial-box__circle{width:150%;height:410%;background:#d8d8d8;border:1px solid #cacaca;left:-20%;bottom:-140%;-webkit-transition:all 450ms cubic-bezier(0.4, 0, 0.2, 1);transition:all 450ms cubic-bezier(0.4, 0, 0.2, 1)}.BarakaMaterial-box__content ul, .BarakaMaterial-box__content li{list-style:none;margin-bottom:0;-webkit-padding-start:0}.BarakaMaterial-box__content li{padding:0;-webkit-padding-start:0;height:40px;line-height:40px;width:100%;position:relative;-webkit-transition:all .5s cubic-bezier(0.23, 1, 0.32, 1);transition:all .5s cubic-bezier(0.23, 1, 0.32, 1)}.BarakaMaterial-box__content li:hover{cursor:pointer;background-color:#cacaca}.BarakaMaterial-box__content li:before, .BarakaMaterial-box__content li:after{content:\"\";width:100%;height:0;left:0;border-top:1px solid;position:absolute}.BarakaMaterial-box__content li:first-child:after, .BarakaMaterial-box__content li:last-child:before{display:none}.BarakaMaterial-box__content li:before{border-color:#cacaca;bottom:0}.BarakaMaterial-box__content li:after{border-color:#fff}.BarakaMaterial-fade{position:relative}.BarakaMaterial-fade:before{background-image:-webkit-linear-gradient(bottom, rgba(255, 255, 255, 0) 0, #fff 100%);background-image:linear-gradient(bottom, rgba(255, 255, 255, 0) 0, #fff 100%);left:0}.BarakaMaterial-fade:before{content:\"\";width:100%;height:34px;position:absolute;top:39px;z-index:100}.BarakaMaterial-box__content li.BarakaModal_trigger{transform:initial!important;-webkit-transform:initial!important}.bd-nothing{display:none;visibility:hidden;opacity:0;height:0;width:0}#avail-lyr{-webkit-margin-before:1.2em}#avail-lyr>li span{text-indent:-9999px;display:inline-block;float:left}.BarakaMaterial-box__content li svg{width:100px;height:40px}.BarakaMaterial-box__content li#azlyrics svg{margin-left:-28px;width:130px}.BarakaMaterial-box__content li#genius svg{margin-left:12px;width:130px}.BarakaMaterial-box__content li#metrolyrics svg{margin-left:-26px;width:162px}.BarakaMaterial-box__content li#lyricwiki svg{margin-left:-20px}.BarakaMaterial-box__content li#musixmatch svg{margin-left:-33px;width:160px}.Yosemite{}.Light{}.Black{}.Rdiant{}.DarkCyan{}.Google{}.Google .BarakaModal_content{background:rgba(239, 108, 0, 0.9);border:1px solid #d96300}.Google .bd-close:hover{background:rgba(0, 0, 0, 0.9)}.Google .BarakaMaterial-box .BarakaMaterial-box__inner{color:#fff}.Google .BarakaMaterial-box .BarakaMaterial-box__content{background:rgba(239, 108, 0, 0.9)}.Google .BarakaMaterial-box .BarakaMaterial-box__circle{background:rgba(239, 108, 0, 0.9)}.Google .BarakaMaterial-box .BarakaMaterial-box__header{border-bottom:1px solid #c15700;color:black}.Google .BarakaMaterial-box .BarakaMaterial-box__header{color:black}.Google .BarakaMaterial-box--show{border:1px solid #d96300}.Google .BarakaMaterial-box--show .BarakaMaterial-box__circle{background:#ef6c00;border:1px solid #c15700}.Google .BarakaMaterial-box__content li:hover{background-color:#c15700}.Google .BarakaMaterial-box__content li:before{border-color:#c15700}.Google .BarakaMaterial-box__content li:after{border-color:#ff7300}.Google .BarakaMaterial-fade:before{background-image:-webkit-linear-gradient(bottom, rgba(239, 108, 0, 0) 0, #ef6c00 100%);background-image:linear-gradient(bottom, rgba(239, 108, 0, 0) 0, #ef6c00 100%)}.Google .BarakaModal_dialog:before{background-image:-webkit-linear-gradient(bottom, rgba(239, 108, 0, 0) 0%, rgb(239, 108, 0) 100%);background-image:linear-gradient(bottom, rgba(239, 108, 0, 0) 0%, rgb(239, 108, 0) 100%)}.Google .BarakaModal_dialog:after{background-image:-webkit-linear-gradient(top, rgba(239, 108, 0, 0) 0%, rgb(239, 108, 0) 100%);background-image:linear-gradient(top, rgba(239, 108, 0, 0) 0%, rgb(239, 108, 0) 100%)}.Google .BarakaMaterial-box__content li#azlyrics svg path{//fill:#}.Google .BarakaMaterial-box__content li#genius svg path.genius{fill:rgba(255, 255, 255, 0.1)}.Google .BarakaMaterial-box__content li#metrolyrics path, .Google .BarakaMaterial-box__content li#metrolyrics polygon, .Google .BarakaMaterial-box__content li#metrolyrics rect{fill:#000}.Google .BarakaMaterial-box__content li#lyricwiki path{fill:#000}.Google .BarakaMaterial-box__content li#musixmatch path{//fill:#}.DarkCyan .BarakaModal_content{background:rgba(3, 156, 172, 0.9);border:1px solid #007a87;color:#fff}.DarkCyan .bd-close:hover{background:rgba(0, 0, 0, 0.9)}.DarkCyan .BarakaMaterial-box .BarakaMaterial-box__inner{color:#fff}.DarkCyan .BarakaMaterial-box .BarakaMaterial-box__content{background:rgba(3, 156, 172, 0.9)}.DarkCyan .BarakaMaterial-box .BarakaMaterial-box__circle{background:rgba(3, 156, 172, 0.9)}.DarkCyan .BarakaMaterial-box .BarakaMaterial-box__header{border-bottom:1px solid #007a87;color:black}.DarkCyan .BarakaMaterial-box .BarakaMaterial-box__header{color:white}.DarkCyan .BarakaMaterial-box--show{border:1px solid #007a87}.DarkCyan .BarakaMaterial-box--show .BarakaMaterial-box__circle{background:#039cac;border:1px solid #007a87}.DarkCyan .BarakaMaterial-box__content li:hover{background-color:#007a87}.DarkCyan .BarakaMaterial-box__content li:before{border-color:#007a87}.DarkCyan .BarakaMaterial-box__content li:after{border-color:#0cacbd}.DarkCyan .BarakaMaterial-fade:before{background-image:-webkit-linear-gradient(bottom, rgba(3, 156, 172, 0) 0, #039cac 100%);background-image:linear-gradient(bottom, rgba(3, 156, 172, 0) 0, #039cac 100%)}.DarkCyan .BarakaModal_dialog:before{background-image:-webkit-linear-gradient(bottom, rgba(3, 156, 172, 0) 0%, rgb(3, 156, 172) 100%);background-image:linear-gradient(bottom, rgba(3, 156, 172, 0) 0%, rgb(3, 156, 172) 100%)}.DarkCyan .BarakaModal_dialog:after{background-image:-webkit-linear-gradient(top, rgba(3, 156, 172, 0) 0%, rgb(3, 156, 172) 100%);background-image:linear-gradient(top, rgba(3, 156, 172, 0) 0%, rgb(3, 156, 172) 100%)}.DarkCyan .BarakaMaterial-box__content li#azlyrics svg path{fill:#fff}.DarkCyan .BarakaMaterial-box__content li#genius svg path.genius{fill:rgba(255, 255, 255, 0.1)}.DarkCyan .BarakaMaterial-box__content li#genius svg path.genius-2{fill:#fff}.DarkCyan .BarakaMaterial-box__content li#metrolyrics path, .DarkCyan .BarakaMaterial-box__content li#metrolyrics polygon, .DarkCyan .BarakaMaterial-box__content li#metrolyrics rect{fill:#fff}.DarkCyan .BarakaMaterial-box__content li#lyricwiki path{fill:#fff}.DarkCyan .BarakaMaterial-box__content li#musixmatch g[fill=\"#1d1b19\"] path{fill:#fff}.Black .BarakaModal_content{background:rgba(34, 35, 38, 0.9);border:1px solid #000;color:#fff}.Black .bd-close:hover{background:rgba(0, 0, 0, 0.9)}.Black .BarakaMaterial-box .BarakaMaterial-box__inner{color:#fff}.Black .BarakaMaterial-box .BarakaMaterial-box__content{background:rgba(34, 35, 38, 0.9)}.Black .BarakaMaterial-box .BarakaMaterial-box__circle{background:rgba(34, 35, 38, 0.9)}.Black .BarakaMaterial-box .BarakaMaterial-box__header{border-bottom:1px solid #000;color:white}.Black .BarakaMaterial-box .BarakaMaterial-box__header{color:white}.Black .BarakaMaterial-box--show{border:1px solid #000}.Black .BarakaMaterial-box--show .BarakaMaterial-box__circle{background:#222326;border:1px solid #000}.Black .BarakaMaterial-box__content li:hover{background-color:#000}.Black .BarakaMaterial-box__content li:before{border-color:#000}.Black .BarakaMaterial-box__content li:after{border-color:#3a3a3a}.Black .BarakaMaterial-fade:before{background-image:-webkit-linear-gradient(bottom, rgba(34, 35, 38, 0) 0, #222326 100%);background-image:linear-gradient(bottom, rgba(34, 35, 38, 0) 0, #222326 100%)}.Black .BarakaModal_dialog:before{background-image:-webkit-linear-gradient(bottom, rgba(34, 35, 38, 0) 0%, rgb(34, 35, 38) 100%);background-image:linear-gradient(bottom, rgba(34, 35, 38, 0) 0%, rgb(34, 35, 38) 100%)}.Black .BarakaModal_dialog:after{background-image:-webkit-linear-gradient(top, rgba(34, 35, 38, 0) 0%, rgb(34, 35, 38) 100%);background-image:linear-gradient(top, rgba(34, 35, 38, 0) 0%, rgb(34, 35, 38) 100%)}.Black .BarakaMaterial-box__content li#azlyrics svg path{fill:#fff}.Black .BarakaMaterial-box__content li#genius svg path.genius{//fill:rgba(255,255,255,0.1)}.Black .BarakaMaterial-box__content li#genius svg path.genius-2{//fill:#fff}.Black .BarakaMaterial-box__content li#metrolyrics path, .Black .BarakaMaterial-box__content li#metrolyrics polygon, .Black .BarakaMaterial-box__content li#metrolyrics rect{fill:#fff}.Black .BarakaMaterial-box__content li#lyricwiki path{fill:#fff}.Black .BarakaMaterial-box__content li#musixmatch g[fill=\"#1d1b19\"] path{fill:#fff}.Rdiant .BarakaModal_content{background:rgba(1, 143, 213, 0.9);border:1px solid #00547d;color:#fff}.Rdiant .bd-close:hover{background:rgba(0, 0, 0, 0.9)}.Rdiant .BarakaMaterial-box .BarakaMaterial-box__inner{color:#fff}.Rdiant .BarakaMaterial-box .BarakaMaterial-box__content{background:rgba(1, 143, 213, 0.9)}.Rdiant .BarakaMaterial-box .BarakaMaterial-box__circle{background:rgba(1, 143, 213, 0.9)}.Rdiant .BarakaMaterial-box .BarakaMaterial-box__header{border-bottom:1px solid #00547d;color:white}.Rdiant .BarakaMaterial-box .BarakaMaterial-box__header{color:white}.Rdiant .BarakaMaterial-box--show{border:1px solid #00547d}.Rdiant .BarakaMaterial-box--show .BarakaMaterial-box__circle{background:#018fd5;border:1px solid #00547d}.Rdiant .BarakaMaterial-box__content li:hover{background-color:#0f6189}.Rdiant .BarakaMaterial-box__content li:before{border-color:#00547d}.Rdiant .BarakaMaterial-box__content li:after{border-color:#2ea2da}.Rdiant .BarakaMaterial-fade:before{background-image:-webkit-linear-gradient(bottom, rgba(1, 143, 213, 0) 0, #018fd5 100%);background-image:linear-gradient(bottom, rgba(1, 143, 213, 0) 0, #018fd5 100%)}.Rdiant .BarakaModal_dialog:before{background-image:-webkit-linear-gradient(bottom, rgba(1, 143, 213, 0) 0%, rgb(1, 143, 213) 100%);background-image:linear-gradient(bottom, rgba(1, 143, 213, 0) 0%, rgb(1, 143, 213) 100%)}.Rdiant .BarakaModal_dialog:after{background-image:-webkit-linear-gradient(top, rgba(1, 143, 213, 0) 0%, rgb(1, 143, 213) 100%);background-image:linear-gradient(top, rgba(1, 143, 213, 0) 0%, rgb(1, 143, 213) 100%)}.Rdiant .BarakaMaterial-box__content li#azlyrics svg path{fill:#fff}.Rdiant .BarakaMaterial-box__content li#genius svg path.genius{fill:rgba(255, 255, 255, 0.1)}.Rdiant .BarakaMaterial-box__content li#genius svg path.genius-2{//fill:#fff}.Rdiant .BarakaMaterial-box__content li#metrolyrics path, .Rdiant .BarakaMaterial-box__content li#metrolyrics polygon, .Rdiant .BarakaMaterial-box__content li#metrolyrics rect{fill:#fff}.Rdiant .BarakaMaterial-box__content li#lyricwiki path{fill:#fff}.Rdiant .BarakaMaterial-box__content li#musixmatch g[fill=\"#1d1b19\"] path{fill:#fff}.BarakaHide{opacity: 0!important;}.lyricsbreak,#mid-song-discussion,.desc.compress,.lyricsh,.ringtone,.noprint,.div-share,.fb-like,.div-share,#addsong,#corlyr,.smt,.hidden,.album-panel,.songlist-panel,[action=\"http://search.azlyrics.com/search.php\"]{display:none}</style>');document.body.insertBefore(b,document.body.childNodes[0]);var a=BarakaRadiant.create('<div id=\"BarakaMaterial-box\" class=\"BarakaMaterial-box\"><div class=\"BarakaMaterial-box__inner\"><div id=\"BarakaMaterial-content\"></div><div class=\"BarakaMaterial-box__content\"><div class=\"BarakaMaterial-box__header\">Available Lyrics</div><ul id=\"avail-lyr\"><i id=\"bd-nothing\"></i></ul></div><div class=\"BarakaMaterial-box__circle\"></div></div></div>');document.body.insertBefore(a,document.body.childNodes[0]);document.getElementById(\"BarakaMaterial-box\").addEventListener(\"mousewheel\",BarakaRadiant.BarakaFadeHandler,false);BarakaRadiant.Lyrics();BarakaRadiant.BarakaMaterial();BarakaRadiant.BarakaModal();BarakaRadiant.RadiantStyles()},RadiantStyles:function(){if(typeof RadiantStyle!==\"undefined\"){if(RadiantStyle.appliedStyles.hasOwnProperty(\"Yosemite\")||RadiantStyle.appliedStyles.hasOwnProperty(\"Black\")||RadiantStyle.appliedStyles.hasOwnProperty(\"Light\")||RadiantStyle.appliedStyles.hasOwnProperty(\"Dark Cyan\")||RadiantStyle.appliedStyles.hasOwnProperty(\"Google\")||RadiantStyle.appliedStyles.hasOwnProperty(\"Rdiant\")){var a=(Object.keys(RadiantStyle.appliedStyles)[3]==\"navigation\")?Object.keys(RadiantStyle.appliedStyles)[4]:Object.keys(RadiantStyle.appliedStyles)[3];(a!=\"Dark Cyan\"?BarakaRadiant.AddClass(document.body,a,true):BarakaRadiant.AddClass(document.body,\"DarkCyan\",true))}}},hasClass:function(b,a){if(b!==null){return(\" \"+b.className+\" \").indexOf(\" \"+a+\" \")>-1}else{return false}},removeByClass:function(a){var b=document.getElementsByClassName(a);if(b!==null){while(b.length>0){b[0].parentNode.removeChild(b[0])}}else{return false}},AddClass:function(f,d,g){var e=f.className.split(\" \");if(e.indexOf(d)!==-1){if(!g){delete e[e.indexOf(d)]}}else{if(g){e[e.length]=d}}f.className=e.join(\" \")},insertAfter:function(b,a){b.parentNode.insertBefore(a,b.nextSibling)},create:function(a){var c=document.createDocumentFragment(),b=document.createElement(\"div\");b.innerHTML=a;while(b.firstChild){c.appendChild(b.firstChild)}return c},Lyrics:function(){for(var b in BarakaLyrics){if(b.hasOwnProperty(\"0\")){BarakaRadiant.hasLyrics=true;if(BarakaLyrics[b]!=\"\"){var e,f;switch(b){case\"BarakaLyricAZ\":if(document.querySelector(\"#BarakaLyricAZ\")!==null){document.getElementById(\"BarakaLyricAZ\").remove()}e=\"AZ Lyrics\";f=\"azlyrics\";icon='<svg id=\"azlyrics\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 568.81 139.38\"><defs><style>.azlyrics{fill:#000;}</style></defs><title>AZ</title><g id=\"az\"><path class=\"azlyrics\" d=\"M2.51,101.83C5,95.84,7.71,90,10.39,84.1c3-6.59,5.88-13.23,8.86-19.83s6.25-13.41,9.15-20.21,5.85-13.24,8.86-19.83,5.9-13.22,8.92-20H68.62c3.2,7.22,6.46,14.7,10,22.06,2.58,5.41,4.91,11,7.32,16.46,3.15,7.2,6.55,14.29,9.68,21.49,2.64,6.08,5.52,12,8.17,18.12C107,89.82,114,105.9,114,106.78H92.37L83.91,88.12H30.86L22,107H0C0,106.67,1.94,103.23,2.51,101.83Zm66-49.66C65.22,45,62.33,37.75,59,30.64c-0.52-1.11-.94-2.27-1.49-3.6-3.74,6.6-6.22,13.6-9.18,20.35-3.11,7.09-6.55,14.07-9,21.37H76.21\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M167.26,23H118.18V4.09h79.66v9.16c-2.6,3.76-5.08,7.43-7.64,11-3.38,4.77-6.84,9.49-10.23,14.26q-8.51,12-17,24c-5.11,7.23-10.41,14.32-15.53,21.56-0.85,1.2-1.52,2.37-2.43,3.8h52.81v18.91H117.13V94.9c3.73-5.23,7.48-10.52,11.26-15.79,3.4-4.76,6.86-9.47,10.24-14.25,4.92-7,9.73-14,14.8-20.87\" transform=\"translate(0 -2.43)\"/></g><g id=\"lyrics\"><path class=\"azlyrics\" d=\"M211.86,4.88h18.82V92.24h42.38V108h-61.2V4.88Z\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M293.41,33.49l13.46,39.93C308.41,78,309.94,83.67,311,88h0.46c1.22-4.28,2.6-9.79,4-14.69l11.63-39.78h20.2L328.6,84.29c-10.25,27.85-17.14,40.24-26,47.89a37.84,37.84,0,0,1-19.74,9.64l-4.28-15.91a32.25,32.25,0,0,0,11-5.2,32.82,32.82,0,0,0,10.25-11.78,7.55,7.55,0,0,0,1.22-3.37,8,8,0,0,0-1.07-3.67L272.76,33.49h20.66Z\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M358.13,57.51c0-10.1-.15-17.29-0.61-24h16.37l0.61,14.23h0.61c3.67-10.56,12.39-15.91,20.35-15.91a19.74,19.74,0,0,1,4.44.46V50a26.11,26.11,0,0,0-5.51-.61c-9,0-15.15,5.81-16.83,14.23a32.25,32.25,0,0,0-.61,5.81V108H358.13V57.51Z\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M432.64,12.68c0,5.66-4.13,10.1-10.71,10.1-6.27,0-10.4-4.44-10.4-10.1,0-5.81,4.28-10.25,10.56-10.25C428.51,2.43,432.49,6.87,432.64,12.68ZM412.6,108V33.49h19V108h-19Z\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M506.54,105.71c-4,1.84-11.78,3.83-21.11,3.83-23.26,0-38.4-14.84-38.4-37.94,0-22.34,15.3-39.78,41.46-39.78,6.88,0,13.92,1.53,18.21,3.52L503.33,49.4a33.16,33.16,0,0,0-14.23-2.91c-14.38,0-22.95,10.56-22.8,24.17,0,15.3,9.95,24,22.8,24a36.8,36.8,0,0,0,14.84-2.91Z\" transform=\"translate(0 -2.43)\"/><path class=\"azlyrics\" d=\"M519.54,90.71a42,42,0,0,0,19.13,5.36c8.26,0,11.93-3.37,11.93-8.26,0-5-3.06-7.65-12.24-10.86-14.54-5-20.66-13-20.5-21.73,0-13.16,10.86-23.41,28.15-23.41a43.75,43.75,0,0,1,19.74,4.44l-3.67,13.31a33.46,33.46,0,0,0-15.76-4.29c-6.73,0-10.4,3.21-10.4,7.8,0,4.74,3.52,7,13,10.4,13.46,4.9,19.74,11.78,19.89,22.8,0,13.46-10.56,23.26-30.29,23.26-9,0-17.14-2.14-22.64-5.2Z\" transform=\"translate(0 -2.43)\"/></g></svg>';break;case\"BarakaLyricGenius\":if(document.querySelector(\"#BarakaLyricGenius\")!==null){document.getElementById(\"BarakaLyricGenius\").remove()}e=\"Genius\";f=\"genius\";icon='<svg id=\"genius\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1253 321\"><defs><style>.genius{fill:#f6f06c;}.genius-2{fill:#020201;}</style></defs><title>Genius</title><path class=\"genius\" d=\"M0,321V0H1253V321H0ZM297.89,157.6c0,18-.07,36,0,54,0.06,10.5,6.83,18.38,17,18.52,25.81,0.36,51.63.24,77.44,0.08,6.28,0,11.05-4.21,12.88-10.06,2-6.29,1.19-7.4-5.27-7.4-21,0-42,.07-63,0-11.77-.05-17.86-6.25-17.88-18q0-26.48,0-53c0-17.32-.07-34.64.06-52,0-3.54-1-4.65-4.63-4.18-10.17,1.32-16.59,8.35-16.63,19C297.84,122.29,297.89,139.94,297.89,157.6ZM971,206.37c-8.17,3.31-16.08,5.66-24.42,6.07-18.93.94-36.27-2.72-49.06-18.1-9.95-12-13-26.44-13.16-41.51-0.28-21-.16-42,0-63,0-3.93-1.2-5.27-5.14-5.21-9.18.15-16.09,5.94-16.12,15.46-0.07,26.31-1.83,52.69,1,78.9,2.19,20.47,11.38,37.12,31.16,46.07,12.54,5.67,25.82,6.26,39.19,4.59,13.09-1.64,24.64-6.81,33.59-16.86C969.39,211.27,971.39,210,971,206.37Zm-775.47,2.82c-31.06,9.46-59.21,5.14-82.33-18s-27.27-51.41-17.46-82.37c-14.92,11.57-26.27,39.13-19.85,66.52,6.55,28,29,49.42,59.31,54.18C158.35,233.15,178.77,226.45,195.54,209.18ZM1095.9,88.51c-5,.57-7.81,2.73-10.6,4.59-23.94,16-24.78,49.72-1.64,66.36,7.82,5.62,16.76,8.65,26.11,10.62,8.28,1.75,16.77,2.55,24.88,5.07,4.34,1.35,9.25,3.06,10.21,7.86,1.24,6.24,4.59,5.18,8.59,3.87a25.14,25.14,0,0,0,8-3.95c8.21-6.53,7.48-17.54-1.55-22.87a38.54,38.54,0,0,0-12.18-4.24c-12.18-2.47-24.65-3.75-36.15-9-17.73-8.1-26.27-24.45-22.4-43.14C1090.22,98.63,1092.77,94.19,1095.9,88.51ZM507,157.82c0,17.66,0,35.32,0,53a31.84,31.84,0,0,0,1,8.4c2.11,7.86,9.24,12.08,18.3,11a15.38,15.38,0,0,0,13.26-14.64c0.06-1.42.06-2.84-1.45-3.37-9.07-3.21-9.83-10.6-9.81-18.67,0.09-34.15,0-68.3.12-102.45,0-4.09-1-5.55-5.29-5.41-10,.33-16,6.8-16.08,18.23C506.94,121.84,507,139.83,507,157.82Zm225.89-.33c0,19-.08,37.94,0,56.91,0.06,9,6.11,15.43,14.57,15.87,9.43,0.49,16.34-4.71,17.51-13.32,0.23-1.7,1-4.05-1.3-4.81-8.83-2.87-9.67-9.79-9.64-17.57,0.1-34.45,0-68.9.12-103.34,0-4-.86-5.7-5.2-5.62-9.6.18-16,6.41-16.07,16.46C732.83,120.55,732.89,139,732.89,157.49Zm-101.94,54.7c-14.89,2.93-20.82-6.8-26.79-16.87-14.52-24.48-29.25-48.84-43.93-73.23-1.07-1.78-1.71-4-3.8-5-2.37,1.14-1.5,3.22-1.5,4.88-0.07,12,.1,24-0.11,36a20.53,20.53,0,0,0,3.14,11.71c10,16.28,19.6,32.84,29.73,49C595.34,231,611.81,234.3,623,226.3,627.4,223.16,629.93,218.9,630.95,212.19Zm541.31-4.43c-2.45-2-4-.37-5.57.16q-40.45,13.54-75.22-11.13c-3.25-2.31-5.68-5.28-6.2-9.27-0.37-2.88-2-3.45-4.38-3.63-7-.52-13.19,3.7-16.11,11-2.7,6.75-.54,14,6.15,18.87,23.38,17.13,49.08,20.87,76.58,12.45C1157.73,223.08,1166.24,217.2,1172.26,207.76ZM946.58,187.93c9.24-1,15.24-4.82,19.54-11.4,4.14-6.33,5.72-13.53,5.81-20.88,0.27-22.3.1-44.6,0.23-66.9,0-3.13-1.32-4-4.16-4.09-9.91-.47-17,5.87-17.07,15.91-0.14,14.64.13,29.29-.09,43.93C950.64,158.69,952.61,173.08,946.58,187.93ZM619.43,169.16a1.9,1.9,0,0,0,1.15-2q0-39.2,0-78.4c0-2.5-1.46-2.9-3.53-3.07-10.47-.86-17.52,5.68-17.68,16.83-0.16,10.82,0,21.64-.05,32.46a8.65,8.65,0,0,0,1.16,4.74c5.52,9.09,11,18.21,16.45,27.32C617.56,168,617.94,169.25,619.43,169.16ZM128,114c2.11,2.14,3.77.59,5.4,0.19,15-3.72,28.79-1.22,40.89,8.38a14.92,14.92,0,0,0,10.28,3.59c12.07-.19,11.75-0.08,12.22-12,0.21-5.39-1.82-8.69-5.89-11.61-12.35-8.88-25.84-11.11-40.2-6.52A39.65,39.65,0,0,0,128,114Zm68.64,53.79c0-8.81,0-8.81-8.13-8.81H180c-9.31,0-14.79-3.8-17.29-12.65-1-3.63-2.65-3.92-5.75-2.88-7.8,2.65-12.21,9.8-11.13,18.43,0.93,7.47,7.54,13.38,15.45,13.69,3.16,0.13,6.33.13,9.49,0,3-.12,4.85.58,4.65,4.1-0.19,3.25,1.63,3.35,4.23,2.58a60.23,60.23,0,0,0,11-4.61C195,175.36,198,172.44,196.62,167.8ZM1155.33,125c8.55,0.06,16.23-7,16.76-14.56,0.12-1.67.22-3.41-1.78-4.2-3.62-1.41-6.39-4.17-9.7-6.06-11.39-6.5-23.38-8.38-35.92-4.06-5.26,1.81-9.22,5.26-9.8,11.39-0.28,3,.47,4.79,4,4.54,10.14-.72,18.87,3,26.78,9A18.84,18.84,0,0,0,1155.33,125Zm-779-27h-17c-14.47,0-14.42,0-13.55,14.53,0.15,2.47.84,3.63,3.48,3.61,14-.09,28,0.12,42-0.19,8-.18,13.44-5.23,14.61-12.5,0.57-3.58-.14-5.67-4.54-5.53C393,98.18,384.7,98,376.37,98Zm-30.48,57.38c0,5.45.07,10.09,0,14.73-0.05,2.53,1.25,3,3.43,3,13-.05,26,0.14,38.93-0.09,7.93-.14,13.43-5.69,14.28-13.28,0.38-3.35-.76-4.45-4.06-4.42-13.14.11-26.28,0-39.43,0H345.89Z\"/><path class=\"genius-2\" d=\"M297.89,157.6c0-17.66,0-35.31,0-53,0-10.66,6.46-17.7,16.63-19,3.67-.48,4.66.64,4.63,4.18-0.13,17.32-.06,34.64-0.06,52q0,26.48,0,53c0,11.7,6.11,17.9,17.88,18,21,0.09,42,0,63,0,6.46,0,7.23,1.1,5.27,7.4-1.83,5.84-6.6,10-12.88,10.06-25.81.16-51.63,0.28-77.44-.08-10.15-.14-16.92-8-17-18.52C297.82,193.58,297.89,175.59,297.89,157.6Z\"/><path class=\"genius-2\" d=\"M971,206.37c0.38,3.61-1.63,4.91-3,6.42-8.95,10.05-20.5,15.22-33.59,16.86-13.37,1.67-26.64,1.09-39.19-4.59-19.79-9-29-25.6-31.16-46.07-2.8-26.21-1-52.59-1-78.9,0-9.52,6.94-15.31,16.12-15.46,3.94-.06,5.17,1.28,5.14,5.21-0.16,21-.29,42,0,63,0.2,15.07,3.21,29.55,13.16,41.51,12.79,15.38,30.12,19,49.06,18.1C954.93,212,962.84,209.67,971,206.37Z\"/><path class=\"genius-2\" d=\"M195.54,209.18c-16.77,17.26-37.19,24-60.34,20.33-30.28-4.77-52.76-26.22-59.31-54.18-6.41-27.39,4.94-54.95,19.85-66.52-9.81,31-5.65,59.24,17.46,82.37S164.49,218.64,195.54,209.18Z\"/><path class=\"genius-2\" d=\"M1095.9,88.51c-3.13,5.68-5.68,10.11-6.73,15.17-3.87,18.69,4.68,35,22.4,43.14,11.51,5.26,24,6.55,36.15,9a38.54,38.54,0,0,1,12.18,4.24c9,5.33,9.76,16.34,1.55,22.87a25.14,25.14,0,0,1-8,3.95c-4,1.31-7.35,2.37-8.59-3.87-1-4.81-5.86-6.52-10.21-7.86-8.12-2.52-16.6-3.32-24.88-5.07-9.34-2-18.29-5-26.11-10.62-23.14-16.64-22.31-50.41,1.64-66.36C1088.09,91.24,1090.88,89.08,1095.9,88.51Z\"/><path class=\"genius-2\" d=\"M507,157.82c0-18-.06-36,0-54,0.05-11.43,6.05-17.9,16.08-18.23,4.24-.14,5.3,1.32,5.29,5.41-0.15,34.15,0,68.3-.12,102.45,0,8.07.74,15.46,9.81,18.67,1.5,0.53,1.51,2,1.45,3.37a15.38,15.38,0,0,1-13.26,14.64c-9.07,1.12-16.2-3.09-18.3-11a31.84,31.84,0,0,1-1-8.4C507,193.14,507,175.48,507,157.82Z\"/><path class=\"genius-2\" d=\"M732.89,157.49c0-18.47-.06-36.94,0-55.42,0-10,6.47-16.28,16.07-16.46,4.34-.08,5.21,1.67,5.2,5.62-0.13,34.45,0,68.9-.12,103.34,0,7.78.81,14.7,9.64,17.57,2.34,0.76,1.53,3.11,1.3,4.81-1.16,8.6-8.07,13.81-17.51,13.32-8.46-.44-14.52-6.83-14.57-15.87C732.81,195.44,732.89,176.47,732.89,157.49Z\"/><path class=\"genius-2\" d=\"M630.95,212.19c-1,6.7-3.54,11-7.95,14.11-11.2,8-27.66,4.7-35.33-7.57-10.13-16.21-19.71-32.76-29.73-49A20.53,20.53,0,0,1,554.81,158c0.22-12,0-24,.11-36,0-1.66-.86-3.74,1.5-4.88,2.09,1,2.73,3.21,3.8,5,14.68,24.39,29.41,48.75,43.93,73.23C610.13,205.39,616.06,215.12,630.95,212.19Z\"/><path class=\"genius-2\" d=\"M1172.26,207.76c-6,9.44-14.53,15.32-24.76,18.45-27.49,8.42-53.19,4.68-76.58-12.45-6.69-4.9-8.85-12.12-6.15-18.87,2.92-7.3,9.15-11.51,16.11-11,2.38,0.18,4,.76,4.38,3.63,0.52,4,3,7,6.2,9.27q34.78,24.69,75.22,11.13C1168.28,207.39,1169.8,205.71,1172.26,207.76Z\"/><path class=\"genius-2\" d=\"M946.58,187.93c6-14.85,4.06-29.24,4.26-43.42,0.21-14.64-.06-29.29.09-43.93,0.1-10,7.16-16.37,17.07-15.91,2.84,0.13,4.18,1,4.16,4.09-0.13,22.3,0,44.6-.23,66.9-0.09,7.34-1.66,14.55-5.81,20.88C961.81,183.11,955.82,186.9,946.58,187.93Z\"/><path class=\"genius-2\" d=\"M619.43,169.16c-1.5.09-1.88-1.16-2.46-2.12-5.49-9.1-10.93-18.23-16.45-27.32a8.65,8.65,0,0,1-1.16-4.74c0-10.82-.11-21.64.05-32.46,0.16-11.15,7.21-17.69,17.68-16.83,2.07,0.17,3.53.57,3.53,3.07q0,39.2,0,78.4A1.91,1.91,0,0,1,619.43,169.16Z\"/><path class=\"genius-2\" d=\"M128,114a39.65,39.65,0,0,1,22.69-18c14.36-4.6,27.85-2.36,40.2,6.52,4.07,2.92,6.11,6.22,5.89,11.61-0.47,11.91-.15,11.8-12.22,12a14.92,14.92,0,0,1-10.28-3.59c-12.1-9.61-25.92-12.1-40.89-8.38C131.75,114.61,130.09,116.16,128,114Z\"/><path class=\"genius-2\" d=\"M196.62,167.8c1.39,4.63-1.6,7.56-6,9.85a60.23,60.23,0,0,1-11,4.61c-2.6.77-4.42,0.68-4.23-2.58,0.2-3.51-1.68-4.22-4.65-4.1-3.16.13-6.33,0.13-9.49,0-7.91-.31-14.52-6.22-15.45-13.69-1.07-8.63,3.34-15.78,11.13-18.43,3.09-1,4.72-.76,5.75,2.88,2.49,8.85,8,12.63,17.29,12.65h8.5C196.62,159,196.62,159,196.62,167.8Z\"/><path class=\"genius-2\" d=\"M1155.33,125a18.84,18.84,0,0,1-9.63-4c-7.92-6-16.64-9.71-26.78-9-3.55.25-4.31-1.54-4-4.54,0.58-6.13,4.54-9.58,9.8-11.39,12.53-4.32,24.53-2.43,35.92,4.06,3.31,1.89,6.08,4.65,9.7,6.06,2,0.78,1.9,2.52,1.78,4.2C1171.56,118,1163.88,125.06,1155.33,125Z\"/><path class=\"genius-2\" d=\"M376.37,98c8.33,0,16.66.19,25-.08,4.4-.14,5.11,2,4.54,5.53-1.16,7.27-6.59,12.32-14.61,12.5-14,.31-28,0.09-42,0.19-2.65,0-3.33-1.14-3.48-3.61C345,98,344.91,98,359.39,98h17Z\"/><path class=\"genius-2\" d=\"M345.89,155.38H359c13.14,0,26.29.07,39.43,0,3.3,0,4.44,1.08,4.06,4.42-0.85,7.59-6.34,13.14-14.28,13.28-13,.23-26,0-38.93.09-2.18,0-3.49-.5-3.43-3C346,165.47,345.89,160.83,345.89,155.38Z\"/></svg>';break;case\"BarakaLyricMetro\":if(document.querySelector(\"#BarakaLyricMetro\")!==null){document.getElementById(\"BarakaLyricMetro\").remove()}e=\"Metro Lyrics\";f=\"metrolyrics\";icon='<svg id=\"metrolyrics\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 470.03 50.54\"><defs><style>.metrolyrics{fill:#292929;}.metrolyrics-2{fill:#ed1b5a;}</style></defs><title>metrolyrics</title><path class=\"metrolyrics\" d=\"M60.38,8.1V56.7h-4V32c0-6.39.35-17.08,0.28-17.08H56.63c-0.07,0-2.15,3.75-4.17,7.36L39.55,44.76H37.4L24.49,22.33c-2-3.61-4.1-7.36-4.16-7.36H20.25c-0.07,0,.28,10.69.28,17.08V56.7h-4V8.1h3.75L33.16,30.25c4.38,7.43,5.21,9.58,5.28,9.58h0.07c0.07,0,.9-2.15,5.28-9.58L56.63,8.1h3.75Z\" transform=\"translate(-16.57 -7.13)\"/><polygon class=\"metrolyrics\" points=\"88.44 45.75 88.44 49.57 56.43 49.57 56.43 0.97 88.02 0.97 88.02 4.79 60.39 4.79 60.39 21.73 82.67 21.73 82.67 25.41 60.39 25.41 60.39 45.75 88.44 45.75\"/><polygon class=\"metrolyrics\" points=\"131.34 0.97 131.34 4.79 114.67 4.79 114.67 49.57 110.65 49.57 110.65 4.79 94.06 4.79 94.06 0.97 131.34 0.97\"/><path class=\"metrolyrics\" d=\"M183.7,56.7l-11.59-19a24.6,24.6,0,0,1-3.26.21H159V56.7h-4V8.1h13.82c11.11,0,17.84,5.76,17.84,15,0,7.08-3.89,11.94-10.55,13.88L188.21,56.7H183.7ZM169.05,34.41c8.81,0,13.54-4.65,13.54-11.32,0-7.15-5.21-11.18-13.54-11.18H159V34.41h10.07Z\" transform=\"translate(-16.57 -7.13)\"/><path class=\"metrolyrics\" d=\"M218.44,7.13A24.84,24.84,0,0,1,243.7,32.4a25.23,25.23,0,1,1-50.47,0,24.78,24.78,0,0,1,25.2-25.27m0,46.65c11.8,0,21.17-8.74,21.17-21.38S230.24,11,218.44,11s-21.1,8.61-21.1,21.38,9.23,21.38,21.1,21.38\" transform=\"translate(-16.57 -7.13)\"/><polygon class=\"metrolyrics-2\" points=\"269.73 40.54 269.73 49.57 236.06 49.57 236.06 0.97 245.71 0.97 245.71 40.54 269.73 40.54\"/><path class=\"metrolyrics-2\" d=\"M327.22,8.1L308.47,34.41V56.7h-9.58V34.41L280.22,8.1H291l10,14a40.75,40.75,0,0,0,2.64,3.61h0.07a40.41,40.41,0,0,0,2.64-3.61l9.93-14h10.9Z\" transform=\"translate(-16.57 -7.13)\"/><path class=\"metrolyrics-2\" d=\"M360.06,56.7l-9.64-16.6h-7.91V56.7h-9.65V8.1h17C361.8,8.1,369,14.56,369,24.34c0,6.66-3.26,11.53-9.16,14L370.9,56.7H360.06ZM342.51,31.5h8.61c5.34,0,7.84-3.47,7.84-7.15s-2.57-7.22-7.84-7.22h-8.61V31.5Z\" transform=\"translate(-16.57 -7.13)\"/><rect class=\"metrolyrics-2\" x=\"361.64\" y=\"0.97\" width=\"9.65\" height=\"48.59\"/><path class=\"metrolyrics-2\" d=\"M433.35,22.54a15.34,15.34,0,0,0-12.22-5.9C412,16.64,406,23.16,406,32.4,406,41.91,412.45,48,421.13,48a15.24,15.24,0,0,0,13.12-7.15L444,43.43a25.29,25.29,0,0,1-48-11A25.27,25.27,0,0,1,443.2,20Z\" transform=\"translate(-16.57 -7.13)\"/><path class=\"metrolyrics-2\" d=\"M476.75,22.89a9.55,9.55,0,0,0-9.65-7.36c-4.44,0-7.28,2.15-7.28,5.07,0,3.89,5.48,5.28,11.59,7.36,7.08,2.43,15.2,6.18,15.2,14.85s-7.5,14.86-18.6,14.86c-10.2,0-17.22-5.76-19.86-14.58l9.3-2.49a11,11,0,0,0,11,8.47c5.21,0,7.91-2.57,7.91-5.83,0-4.93-6.59-6.11-13.46-8.54-5.76-2.08-13-5.07-13-13.54,0-7.57,7.5-14,17.77-14,9.09,0,16.31,5.55,18.4,13.19Z\" transform=\"translate(-16.57 -7.13)\"/></svg>';break;case\"BarakaLyricWikia\":if(document.querySelector(\"#BarakaLyricWikia\")!==null){document.getElementById(\"BarakaLyricWikia\").remove()}e=\"Lyric Wiki\";f=\"lyricwiki\";icon='<svg id=\"lyricwiki\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 160.23 39.49\"><defs><style>.lyricwiki{fill:#104577;}</style></defs><title>lyricwiki</title><path class=\"lyricwiki\" d=\"M27.22,20.28l-5-12.77L14.92,8c1.42,3.6,2.54,6.35,3.6,9.13,2.63,6.88,6.66,13.63,2,21.22-0.27.43-.93,1.93,0.2,1.93h6L39.81,7.89H32.14Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M110.43,16.68l-0.93-.15L106.23,1.31h-5.77L97,16.18l-0.93-.11L91.94,1.43H84.16L93.5,31.12h6.81l3-13,3,13h6.88L122.42,1.3h-7.77Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M144.6,7.77l-5,6.13V1.27H133V31.2h6.44l0.08-5.49c1.66,1.94,3.77,4.09,4.86,5.36h8.37l-8.44-11.75,8.56-11.54H144.6Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M73.21,23.67V15.53l9.87-.94v-7c-4.55,0-8.51-.2-12.44.06a4.93,4.93,0,0,0-5,5.23c-0.09,4.49-.45,9,0.11,13.45,0.23,1.79,2.39,4.48,4,4.73,4.31,0.66,8.78.23,13.73,0.23l-0.42-6.83Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M8.54,22.78V0.8H1.83V31h18l-0.51-7.28Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M47.23,7.62c-2.27.83-5.86,2.38-6,3.92-0.68,6.46-.29,13-0.29,19.55h7V15.84l5.68-1.56V7.5C51.09,7.5,48.95,7,47.23,7.62Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M56.23,31.08h6.86V8H56.23v23.1Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M155.3,7.85V31h6.76V7.85H155.3Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M123.74,31h6.51V7.91h-6.51V31Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M127.84,0.85h-1.68a2.42,2.42,0,1,0,0,4.85h1.68A2.42,2.42,0,1,0,127.84.85Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M157.66,5.7h1.68a2.42,2.42,0,1,0,0-4.85h-1.68A2.42,2.42,0,1,0,157.66,5.7Z\" transform=\"translate(-1.83 -0.8)\"/><path class=\"lyricwiki\" d=\"M58.76,6.14h1.68a2.42,2.42,0,1,0,0-4.85H58.76A2.42,2.42,0,1,0,58.76,6.14Z\" transform=\"translate(-1.83 -0.8)\"/></svg>';break;case\"BarakaLyricMusix\":if(document.querySelector(\"#BarakaLyricMusix\")!==null){document.getElementById(\"BarakaLyricMusix\").remove()}e=\"Musix Match\";f=\"musixmatch\";icon='<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 733.29999 149.3875\"><defs><linearGradient x1=\"0\" y1=\"0\" x2=\"1\" y2=\"0\" id=\"c\" gradientUnits=\"userSpaceOnUse\" gradientTransform=\"matrix(-.000130604 2987.76 2987.76 .000130604 1524.76 -.000118095)\"> <stop stop-color=\"#ed1a3e\" offset=\"0\"/> <stop stop-color=\"#f25126\" offset=\"1\"/> </linearGradient> <linearGradient x1=\"0\" y1=\"0\" x2=\"1\" y2=\"0\" id=\"a\" gradientUnits=\"userSpaceOnUse\" gradientTransform=\"matrix(-.000130604 2987.76 2987.76 .000130604 1524.76 -.000118095)\"> <stop stop-color=\"#f9aac7\" offset=\"0\"/> <stop stop-color=\"#fbc8bb\" offset=\"1\"/> </linearGradient> <linearGradient x1=\"0\" y1=\"0\" x2=\"1\" y2=\"0\" id=\"b\" gradientUnits=\"userSpaceOnUse\" gradientTransform=\"matrix(-.000130604 2987.76 2987.76 .000130604 1524.76 -.000118095)\"> <stop stop-color=\"#fcd6e5\" offset=\"0\"/> <stop stop-color=\"#fde5e1\" offset=\"1\"/> </linearGradient> </defs> <g transform=\"matrix(.05 0 0 -.05 0 149.388)\"> <path d=\"m2858.62 0h-2667.72c-105.435 0-190.9 85.4688-190.9 190.898v2605.95c0 105.44 85.4648 190.9 190.895 190.9h2667.72c105.42 0 190.89-85.46 190.89-190.9v-2605.95c0-105.431-85.47-190.9-190.89-190.9m-1338.37 1109.79 672.06-522.052c37.21-28.906 80.53-41.894 122.88-41.898 98.4-0.012 191.67 70.066 191.67 173.371v1156.99l-493.31-383.2-493.16 383.09-493.31-383.2-493.439 383.31v-1156.99c0-103.297 93.277-173.367 191.668-173.371 42.359-0.004 85.66 12.98 122.886 41.898l672.055 522.052\" fill=\"url(#c)\"/> <path d=\"m2315.19 545.84c-42.35 0.004-85.67 12.992-122.88 41.898l-672.06 522.052 493.3 383.21 493.31-383.21v-390.579c0-103.305-93.27-173.383-191.67-173.371\" fill=\"url(#a)\"/> <path d=\"m725.309 545.84c-98.391 0.004-191.668 70.074-191.668 173.371v390.369l493.439 383.31 493.17-383.1-672.055-522.052c-37.226-28.918-80.527-41.902-122.886-41.898\" fill=\"url(#a)\"/> <g fill=\"url(#b)\"> <path d=\"m1520.25 1109.79-493.17 383.1 493.31 383.2 493.16-383.09-493.3-383.21\"/> <path d=\"m533.641 1109.58v766.62l493.439-383.31-493.439-383.31\"/> <path d=\"m2506.86 1109.79-493.31 383.21 493.31 383.2v-766.41\"/> </g> <path d=\"m2507 2266.89c0 147.77-190.87 227.55-314.55 131.48l-672.2-522.17 0.14-0.11h-0.28 0.28l493.16-383.09 493.17 383.09h0.28v390.8\" fill=\"#fff\"/> <path d=\"m1520.54 1876.2h-0.29l-671.918 521.95c-123.676 96.07-314.555 16.3-314.555-131.48v-390.47h-0.14l0.14-0.11 493.303-383.2 493.31 383.2-0.14 0.11h0.29\" fill=\"#fff\"/> <g fill=\"#1d1b19\"> <path d=\"m4916.29 976.27v650.81c0 96.02-42.66 164.3-153.62 164.3-95.98 0-174.96-64.02-213.35-119.5v-695.61h-273.12v650.81c0 96.02-42.7 164.3-153.65 164.3-93.89 0-172.84-64.02-213.36-119.5v-695.61h-271.01v1030.61h271.01v-132.28c44.79 59.74 179.23 157.89 337.11 157.89 151.5 0 249.65-70.41 285.95-185.63 59.73 91.74 196.3 185.63 354.19 185.63 189.91 0 303.01-100.29 303.01-311.54v-744.68h-273.16\"/> <path d=\"m6068.2 976.27v130.16c-70.41-76.81-194.14-155.77-362.74-155.77-226.2 0-332.89 123.77-332.89 324.34v731.88h271.02v-625.18c0-142.97 74.68-189.91 189.91-189.91 104.52 0 187.77 57.6 234.7 117.35v697.74h271.03v-1030.61h-271.03\"/> <path d=\"m6475.51 1110.7 117.32 196.31c76.81-72.55 228.33-142.96 356.33-142.96 117.42 0 172.88 44.8 172.88 108.82 0 168.56-610.29 29.87-610.29 435.28 0 172.85 149.39 324.34 422.52 324.34 172.82 0 311.5-59.75 413.92-140.83l-108.78-192.04c-61.91 64.02-179.24 119.5-305.14 119.5-98.16 0-162.2-42.69-162.2-100.29 0-151.5 612.41-23.47 612.41-439.56 0-189.91-162.19-328.61-448.08-328.61-179.27 0-352.11 59.75-460.89 160.04\"/> <path d=\"m7497.33 976.27v1030.61h271.03v-1030.61h-271.03zm-25.58 1303.74c0 89.62 72.54 160.04 160.07 160.04 89.57 0 162.15-70.42 162.15-160.04s-72.58-162.18-162.15-162.18c-87.53 0-160.07 72.56-160.07 162.18\"/> <path d=\"m8675.07 976.27-234.74 347.8-236.83-347.8h-300.87l367.01 529.18-345.66 501.43h303l213.35-315.79 211.26 315.79h303l-343.56-501.43 367-529.18h-302.96\"/> <path d=\"m10390.4 976.27v650.81c0 96.02-42.7 164.3-153.6 164.3-96.1 0-175-64.02-213.4-119.5v-695.61h-273.1v650.81c0 96.02-42.74 164.3-153.66 164.3-93.89 0-172.83-64.02-213.39-119.5v-695.61h-270.98v1030.61h270.98v-132.28c44.79 59.74 179.23 157.89 337.12 157.89 151.52 0 249.68-70.41 285.93-185.63 59.8 91.74 196.4 185.63 354.2 185.63 189.9 0 303-100.29 303-311.54v-744.68h-273.1\"/> <path d=\"m11244 1148.23c-55.9 0-103.1 13.35-140.1 39.73-35.9 25.51-53.3 60.53-53.3 106.97v4.07c0 51.89 19.4 90.86 59.3 119.1 41.1 29.07 100.5 43.81 176.7 43.81 47.6 0 92-4.02 132-11.89 35.7-7.02 67.9-15.71 95.9-25.91v-62.19c0-31.12-7-60.1-20.6-86.08-13.8-26.4-32.6-49.35-55.8-68.19-23.4-18.93-52-33.7-85.1-43.89-33.5-10.3-70.2-15.53-109-15.53zm506 657.1c-19.7 57.53-50.3 107.37-91.1 148.12-79.6 82.46-202.9 124.36-366.2 124.36-191.8 0-348.8-68.37-408.9-95.72l-12.9-5.86 4.5-13.41 63.5-185.79 5.3-15.96 15.6 6.47c47.8 19.96 95.6 36.1 142 47.99 45.8 11.83 99.1 17.8 158.4 17.8 82.3 0 145.4-18.5 187.7-55.01 41.5-35.97 62.5-90.71 62.5-162.69v-5.12c-36.2 10.81-73.6 19.76-111.4 26.62-45.4 8.24-99.6 12.43-161.1 12.43-66 0-127.7-7.35-183.6-21.81-56.5-14.67-105.3-37.03-145.4-66.5-40.4-29.71-72.3-67.79-95-113.16-22.7-45.34-34.1-98.91-34.1-159.26v-4.04c0-56.43 11.1-106.98 33.1-150.23 21.9-43.07 51.3-79.61 87.4-108.59 35.8-28.825 78.2-50.939 125.9-65.677 47.3-14.613 97.3-22.027 148.7-22.027 84.9 0 157.7 15.992 216.6 47.515 44.9 24.039 84.1 52.409 116.9 84.579v-109.79h270.9v650.98c0 71.68-9.9 136.9-29.3 193.78\"/> <path d=\"m12052.9 1234.46v535.57h-170.7v236.85h170.7v281.66h271v-281.66h209.1v-236.85h-209.1v-463.02c0-66.15 34.1-115.22 93.9-115.22 40.5 0 78.9 14.93 93.8 31.99l57.7-206.97c-40.5-36.267-113.1-66.15-226.2-66.15-189.9 0-290.2 98.16-290.2 283.8\"/> <path d=\"m12609.7 1492.65c0 315.79 230.4 539.84 546.2 539.84 211.3 0 339.3-91.76 407.6-185.63l-177.1-166.45c-49.1 72.55-123.8 110.97-217.7 110.97-164.3 0-279.5-119.5-279.5-298.73 0-179.24 115.2-300.86 279.5-300.86 93.9 0 168.6 42.67 217.7 113.08l177.1-166.43c-68.3-93.89-196.3-187.78-407.6-187.78-315.8 0-546.2 224.05-546.2 541.99\"/> <path d=\"m14395.4 976.27v627.33c0 142.97-74.6 187.78-189.9 187.78-106.7 0-189.9-59.75-234.7-119.5v-695.61h-273.1v1423.23h273.1v-524.9c66.2 76.81 192 157.89 360.6 157.89 226.2 0 335-123.76 335-324.34v-731.88h-271\"/></g></g></svg>';break}if(b==\"BarakaLyricAZ\"){BarakaLyrics.BarakaLyricAZ[0]=BarakaLyrics.BarakaLyricAZ[0].trim().slice(0,-18)}var a=BarakaRadiant.create('<li id=\"'+f+'\" data-modal=\"#'+b+'\" class=\"BarakaModal_trigger\"><span>'+e+\"</span>\"+icon+\"</li>\");BarakaRadiant.insertAfter(document.getElementById(\"bd-nothing\"),a);var c=BarakaRadiant.create('<div id=\"'+b+'\" class=\"BarakaModal BarakaModal_bg\" role=\"dialog\" aria-hidden=\"true\"><div class=\"BarakaModal_dialog\"><a id=\"BarakaModal_close\" class=\"BarakaModal_close bd-close\"> <svg class=\"\" viewBox=\"0 0 24 24\"><path d=\"M19 6.41l-1.41-1.41-5.59 5.59-5.59-5.59-1.41 1.41 5.59 5.59-5.59 5.59 1.41 1.41 5.59-5.59 5.59 5.59 1.41-1.41-5.59-5.59z\"/><path d=\"M0 0h24v24h-24z\" fill=\"none\"/></svg></a><div class=\"BarakaModal_content\">'+BarakaLyrics[b][0].trim()+\"</div></div></div>\");document.body.insertBefore(c,document.body.childNodes[0])}}else{BarakaRadiant.hasLyrics=false}}if(BarakaRadiant.hasLyrics){var d=BarakaRadiant.create('<paper-button style=\"margin-left: -20px;margin-right: 20px;\" id=\"BarakaMaterial\" aria-label=\"Show Lyrics\" class=\"material-primary more x-scope paper-button-1 BarakaMaterial\" role=\"button\" tabindex=\"0\" animated=\"\" aria-disabled=\"false\" elevation=\"0\">Show Lyrics</paper-button>');BarakaRadiant.insertAfter(document.getElementById(\"queue\"),d)}else{var d=BarakaRadiant.create('<paper-button style=\"margin-left: -20px;margin-right: 20px;color:white\" id=\"BarakaMaterial\" aria-label=\"Lyrics not available\" class=\"material-primary more x-scope paper-button-1 BarakaMaterial\" role=\"button\" tabindex=\"0\" animated=\"\" aria-disabled=\"false\" elevation=\"0\" disabled>Lyrics not available</paper-button>');BarakaRadiant.insertAfter(document.getElementById(\"queue\"),d)}},BarakaFadeHandler:function(b){var a=document.getElementById(\"BarakaMaterial-box\"),c=document.getElementById(\"BarakaMaterial-content\"),d=a.scrollTop;if(d>37||d>28){BarakaRadiant.AddClass(c,\"BarakaMaterial-fade\",true);c.style.top=d-40+1+\"px\"}else{BarakaRadiant.AddClass(c,\"BarakaMaterial-fade\",false)}return false},BarakaMaterial:function(){document.getElementById(\"BarakaMaterial\").addEventListener(\"click\",function(f){var d=document.getElementById(\"BarakaMaterial\"),c=d.offsetWidth,b=d.offset,h=document.getElementById(\"BarakaMaterial-box\"),g=d.getBoundingClientRect(),a=h.offsetHeight+15,e=(h.offsetWidth*0.5)-(c*0.5);h.style.left=g.left-100-e+\"px\";h.style.top=g.top-30-a+\"px\";h.classList.toggle(\"BarakaMaterial-box--show\")},false)},BarakaModal:function(){var d=o(\".BarakaModal_trigger\");var p=o(\".BarakaModal\");var m=o(\".BarakaModal_bg\");var j=o(\".BarakaModal_content\");var h=o(\".BarakaModal_close\");var l=window;var a=false;var e=200;var i=d.length;function o(q){return document.querySelectorAll(q)}var b=function(u){u.preventDefault();var s=this;var r=s.dataset.modal;var q=r.length;var v=r.substring(1,q);var t=document.getElementById(v);f(s,t)};var f=function(q,s){var r=document.getElementById(\"BarakaModal_temp\");if(r===null){var t=document.createElement(\"div\");t.id=\"BarakaModal_temp\";q.appendChild(t);k(q,s,t)}};var k=function(u,z,q){var w=u.getBoundingClientRect();var r=z;var A=r.querySelector(\".BarakaModal_content\").getBoundingClientRect();var t,s,y,x;var B=l.innerWidth/2;var v=l.innerHeight/2;u.classList.add(\"BarakaModal_trigger-active\");y=A.width/w.width;x=A.height/w.height;y=y.toFixed(3);x=x.toFixed(3);t=Math.round(B-w.left-w.width/2);s=Math.round(v-w.top-w.height/2);if(r.classList.contains(\"BarakaModal-align-top\")){s=Math.round(A.height/2+A.top-w.top-w.height/2)}u.style.transform=\"translate(\"+t+\"px, \"+s+\"px)\";u.style.webkitTransform=\"translate(\"+t+\"px, \"+s+\"px)\";q.style.transform=\"scale(\"+y+\",\"+x+\")\";q.style.webkitTransform=\"scale(\"+y+\",\"+x+\")\";window.setTimeout(function(){window.requestAnimationFrame(function(){g(r,q)})},e)};var g=function(q,t){if(document.getElementsByClassName(\"BarakaMaterial-box--show\").length){document.getElementById(\"BarakaMaterial\").click()}if(!a){var r=q.querySelector(\".BarakaModal_content\");q.classList.add(\"BarakaModal-active\");r.classList.add(\"BarakaModal_content-active\");r.addEventListener(\"transitionend\",s,false);a=true}function s(){t.style.opacity=\"0\";r.removeEventListener(\"transitionend\",s,false)}};var n=function(r){r.preventDefault();r.stopImmediatePropagation();var s=r.target;var u=document.getElementById(\"BarakaModal_temp\");if(a&&s.classList.contains(\"BarakaModal_bg\")||s.classList.contains(\"BarakaModal_close\")){u.style.opacity=\"1\";u.removeAttribute(\"style\");for(var q=0;q<i;q++){p[q].classList.remove(\"BarakaModal-active\");j[q].classList.remove(\"BarakaModal_content-active\");d[q].style.transform=\"none\";d[q].style.webkitTransform=\"none\";d[q].classList.remove(\"BarakaModal_trigger-active\")}u.addEventListener(\"transitionend\",t,false);a=false}function t(){setTimeout(function(){window.requestAnimationFrame(function(){u.remove()})},e-50)}};var c=function(){for(var q=0;q<i;q++){d[q].addEventListener(\"click\",b,false);h[q].addEventListener(\"click\",n,false);m[q].addEventListener(\"click\",n,false)}};return c()}};";
    NSString *insert = [NSString stringWithFormat:format,var];
    [webView stringByEvaluatingJavaScriptFromString:insert];
    
    @try {
        NSString *lyrics = nil;
        NSString *Title = title;
        NSString *Artist = artist;
        NSString *Album = album;
        NSString *className = nil;
        NSError *writeError = nil;
        
        for (BarakaLyrics *obtain in self.BarakaGetLyrics) {
            //[self BarakaInject:className]; // not needed as this was a test for <className: hexvaule>
            lyrics = [obtain findBarakaLyrics:Artist
                                        album:Album
                                        title:Title];
            
            NSArray* Json = [NSArray arrayWithObjects:lyrics, nil];
            //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Json options:NSJSONWritingPrettyPrinted error:&writeError];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Json options:0 error:&writeError];
            NSString *Final = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            Final = [Final stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            Final = [Final stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            className = [obtain whatClass]; // get our classes we are using
            
            //NSLog(@"className: %@ Lyrics: %@",className,lyrics); // debug?
            if (lyrics) {
                [self BarakaInjectLyrics:className content:Final];
                
                //For some dumb reason some items with LyricsWikia have lyrics but only shows up as <div class=\"lyricbox\"><script><![CDATA[(function() {var opts = {artist: *...... therefore it doesn't obtain the actual lyrics even if its there, i'll remove it as nothing found =\
                
                if ([className rangeOfString:@"BarakaLyricWikia"].location != NSNotFound) {
                    if ([Final containsString:@"<script><![CDATA[(function() {var opts = {artist:"]) {
                        [self BarakaInjectLyrics:@"BarakaLyricWikia" content:@"[]"];
                    } else {
                        [self BarakaInjectLyrics:@"BarakaLyricWikia" content:Final];
                    }
                }
            }
            
        }
        
        /* This is only for testing/debuging? in the Browser
         NSString *Baraka =@"console.log(BarakaLyrics);";
         NSString *insert = [NSString stringWithFormat:Baraka];
         [webView stringByEvaluatingJavaScriptFromString:insert];*/
        
    } @catch (NSException * e) {
        NSRunAlertPanel(@"Error", @"Sorry looks like BarakaLyrics couldn't get any lyrics :S Reach @BarakaAka1Only.", @"OK", nil, nil);
    } @finally {
        NSLog(@"BarakaLyrics");
    }
}

- (void) BarakaInject:(NSString *)name
{
    /*ONLY FOR <className: hexvaule> when whatClass is removed / not in use*/
    /*NSString *template =
     @"var BarakaLyrics = {};"
     "var what = '%1$@';"
     "var bd, re, final;"
     "bd = what.replace(/[^A-Za-z;]/g, '_');"
     "re = bd.substring(1);"
     "final = re.substring(0, re.indexOf('_'));"
     "BarakaLyrics[final] = final;";*/
    
    NSString *template =
    @"var BarakaLyrics = {};"
    "BarakaLyrics['%1$@'] = ''";
    
    NSString *insert = [NSString stringWithFormat:template, name];
    [webView stringByEvaluatingJavaScriptFromString:insert];
}

- (void) BarakaInjectLyrics:(NSString *)name content:(NSString *)content {
    NSString *template = [NSString stringWithFormat:@"BarakaLyrics['%@'] = %@", name, content];
    NSString *insert = [NSString stringWithFormat:template, name];
    [webView stringByEvaluatingJavaScriptFromString:insert];
}

@end
