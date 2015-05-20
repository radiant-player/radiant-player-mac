/*
 * CustomWebView.m
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Swipe tracking code per Oscar Del Ben:
 * https://github.com/oscardelben/CocoaNavigationGestures
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "CustomWebView.h"

@implementation CustomWebView

@synthesize appDelegate;
@synthesize swipeView;

- (void)awakeFromNib
{
    _warnedAboutPlugin = NO;
    _inGesture = NO;
    _receivingTouches = NO;
    
    swipeView = [[SwipeIndicatorView alloc] initWithFrame:self.frame];
    [swipeView setWebView:self];
    [swipeView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [self setAutoresizesSubviews:YES];
    [self setAcceptsTouchEvents:YES];
    [self addSubview:swipeView];
    
    [self setResourceLoadDelegate:self];
    [self setUIDelegate:self];
    [self setFrameLoadDelegate:self];
    [self setPolicyDelegate:self];
}

#pragma mark - Web delegate methods

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [appDelegate webView:webView didClearWindowObject:windowObject forFrame:frame];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [appDelegate webView:sender didFinishLoadForFrame:frame];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    [appDelegate webView:sender didFailLoadWithError:error forFrame:frame];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    [appDelegate webView:sender didFailProvisionalLoadWithError:error forFrame:frame];
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
    [appDelegate webView:sender didCommitLoadForFrame:frame];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    return [appDelegate webView:sender createWebViewWithRequest:request];
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener
{
    [appDelegate webView:sender runOpenPanelForFileButtonWithResultListener:resultListener];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    [appDelegate webView:sender runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    NSURL *url = [request URL];
    NSMutableURLRequest *req = [request mutableCopy];

    // Handle special URLs.
    if ([[url host] isEqualToString:@"radiant-player-mac"])
    {
        NSArray *components = [url pathComponents];
        
        // Handle script resources.
        if ([[components objectAtIndex:1] isEqualToString:@"js"])
        {
            // JS resources.
            [NSURLProtocol setProperty:self forKey:@"JSCustomWebView" inRequest:req];
            return req;
        }
        
        // Handle image resources.
        else if ([[components objectAtIndex:1] isEqualToString:@"images"])
        {
            // Image resources.
            [NSURLProtocol setProperty:self forKey:@"ImagesCustomWebView" inRequest:req];
            return req;
        }
        
        // Interested if the URL is the original spritesheet we'll download or the inverted one we will provide.
        else if ([[url lastPathComponent] rangeOfString:@"sprites"].location == 0 &&
                 [[url lastPathComponent] rangeOfString:@"inverted"].location != NSNotFound)
        {
            // Inverted sprites.
            [NSURLProtocol setProperty:self forKey:@"InvertedCustomWebView" inRequest:req];
            return req;
        }
    }
    else
    {
        [self handleCookiesForRequest:req redirectResponse:redirectResponse];
        
        // The WebComponents library that was buggy!
        if ([[url lastPathComponent] isEqualToString:@"webcomponents.js"])
        {
            [NSURLProtocol setProperty:self forKey:@"WebComponentsCustomWebView" inRequest:req];
        }
        // Original sprites.
        else if ([[url pathExtension] isEqualToString:@"png"] &&
            [[url lastPathComponent] rangeOfString:@"sprites"].location == 0)
        {
            [NSURLProtocol setProperty:self forKey:@"OriginalCustomWebView" inRequest:req];
            return req;
        }
    }
    
    return req;
}

- (void)webView:(WebView *)sender plugInFailedWithError:(NSError *)error dataSource:(WebDataSource *)dataSource
{
    if (!_warnedAboutPlugin) {
        _warnedAboutPlugin = YES;
        
        NSString *pluginName = [[error userInfo] objectForKey:WebKitErrorPlugInNameKey];
        NSURL *pluginUrl = [NSURL URLWithString:[[error userInfo] objectForKey:WebKitErrorPlugInPageURLStringKey]];
        NSString *reason = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
        
        NSAlert *alert = [NSAlert alertWithMessageText:reason
                                         defaultButton:@"Download plug-in update..."
                                       alternateButton:@"OK"
                                           otherButton:nil
                             informativeTextWithFormat:@"%@ plug-in could not be loaded and may be out-of-date. You will need to download the latest plug-in update from within Safari, and restart Radiant Player once it is installed.", pluginName];
        
        NSModalResponse response = [alert runModal];
        
        if (response == NSAlertDefaultReturn) {
            [[NSWorkspace sharedWorkspace] openURLs:@[pluginUrl] withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:NULL];
        }
    }
}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    return false;
}

#pragma mark - Cookie code

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cookies.use-safari"] == YES)
        return;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        [[CookieStorage instance] handleCookiesInResponse:(NSHTTPURLResponse *)response];
    }
}


- (void)handleCookiesForRequest:(NSMutableURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cookies.use-safari"] == YES)
        return;
    
    if ([redirectResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        [[CookieStorage instance] handleCookiesInResponse:(NSHTTPURLResponse *)redirectResponse];
    }
    
    [request setHTTPShouldHandleCookies:NO];
    [[CookieStorage instance] handleCookiesInRequest:request];
}

#pragma mark - Swipe code

// Three fingers gesture, Lion (if enabled) and Leopard
- (void)swipeWithEvent:(NSEvent *)event {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"navigation.swipe.enabled"] == NO)
        return;
    
    CGFloat x = [event deltaX];
    
    if (x != 0) {
		if (x > 0)
            [self goBack];
        else
            [self goForward];
	}
}


-(BOOL) recognizeTwoFingerGestures
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"AppleEnableSwipeNavigateWithScrolls"];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
    _inGesture = YES;
}

- (void)endGestureWithEvent:(NSEvent *)event
{
    _inGesture = NO;
}

- (void)touchesBeganWithEvent:(NSEvent *)event
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"navigation.swipe.enabled"] == NO)
        return;
    
    if (![self recognizeTwoFingerGestures])
        return;
    
    [swipeView setSwipeAmount:0];
    [swipeView stopAnimation];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    if ([touches count] != 2)
        return;
    
    _receivingTouches = YES;
    _gestureStartPoint = [self touchPositionForTouches:touches];
    _gestureCurrentPoint = NSMakePoint(0, 0);
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    if (!_receivingTouches)
        return;
    
    if ([touches count] != 2)
        return;
    
    _gestureCurrentPoint = [self touchPositionForTouches:touches];
    CGFloat delta = _gestureCurrentPoint.x - _gestureStartPoint.x;
    delta *= SWIPE_AMOUNT_MULTIPLIER;
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        delta *= -1;
    
    [swipeView setSwipeAmount:delta];
    [swipeView setNeedsDisplay:YES];
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
    [swipeView startAnimation];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    if (!_receivingTouches)
        return;
    
    if ([touches count] != 2)
        return;
    
    _gestureCurrentPoint = [self touchPositionForTouches:touches];
    CGFloat delta = _gestureCurrentPoint.x - _gestureStartPoint.x;
    delta *= SWIPE_AMOUNT_MULTIPLIER;
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        delta *= -1;
    
    // See if absolute delta is long enough to be considered a complete gesture
    CGFloat absoluteDelta = fabsf(delta);
    
    if (absoluteDelta < SWIPE_MINIMUM_LENGTH)
        return;
    
    // Handle the actual swipe
    if (delta > 0)
    {
        [self goForward];
    } else
    {
        [self goBack];
    }
}

- (NSPoint)touchPositionForTouches:(NSSet *)touches
{
    NSPoint position = NSMakePoint(0, 0);
    
    for (NSTouch *touch in touches)
    {
        position.x += touch.normalizedPosition.x;
        position.y += touch.normalizedPosition.y;
    }
    
    if ([touches count] > 0) {
        position.x /= [touches count];
        position.y /= [touches count];
    }
    
    return position;
}

@end