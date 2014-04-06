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
    swipeView = [[SwipeIndicatorView alloc] initWithFrame:self.frame];
    [swipeView setWebView:self];
    [swipeView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [self setWantsLayer:YES];
    [self setAutoresizesSubviews:YES];
    [self setAcceptsTouchEvents:YES];
    [self addSubview:swipeView];
    
    [self setResourceLoadDelegate:self];
    [self setUIDelegate:self];
    [self setFrameLoadDelegate:self];
    [self setPolicyDelegate:self];
}

#pragma mark - Web delegate methods

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    // Proceed as normal.
    [listener use];
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [appDelegate webView:webView didClearWindowObject:windowObject forFrame:frame];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [appDelegate webView:sender didFinishLoadForFrame:frame];
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
    
    // Interested if the URL is the original spritesheet we'll download or the inverted one we will provide.
    if ([[[url pathExtension] lowercaseString] isEqualToString:@"png"])
    {
        if ([[url lastPathComponent] rangeOfString:@"sprites"].location == 0)
        {
            // Inverted sprites.
            if ([[url lastPathComponent] rangeOfString:@"inverted"].location != NSNotFound)
            {
                NSMutableURLRequest *newRequest = [request mutableCopy];
                [NSURLProtocol setProperty:self forKey:@"InvertedCustomWebView" inRequest:newRequest];
                
                return newRequest;
            }
            // Original sprites.
            else
            {
                NSMutableURLRequest *newRequest = [request mutableCopy];
                [NSURLProtocol setProperty:self forKey:@"OriginalCustomWebView" inRequest:newRequest];
                
                return newRequest;
            }
        }
    }
    
    return request;
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"navigation.swipe.enabled"] == NO)
        return;
    
    if (![self recognizeTwoFingerGestures])
        return;
    
    [swipeView setSwipeAmount:0];
    [swipeView stopAnimation];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    _touches = [[NSMutableDictionary alloc] init];
    
    for (NSTouch *touch in touches) {
        [_touches setObject:touch forKey:touch.identity];
    }
}

- (void)endGestureWithEvent:(NSEvent *)event
{
    if (!_touches)
        return;
    
    [swipeView startAnimation];
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    
    // release twoFingersTouches early
    NSMutableDictionary *beginTouches = [_touches copy];
    _touches = nil;
    
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
    
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
        
        if (!beginTouch) continue;
        
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
    
    // Need at least two points
    if ([magnitudes count] < 2) return;
    
    CGFloat sum = 0;
    
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        sum *= -1;
    
    // See if absolute sum is long enough to be considered a complete gesture
    CGFloat absoluteSum = fabsf(sum);
    
    if (absoluteSum < SWIPE_MINIMUM_LENGTH)
        return;
    
    // Handle the actual swipe
    if (sum > 0)
    {
        [self goForward];
    } else
    {
        [self goBack];
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    if (!_touches)
        return;
    
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
    
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [_touches objectForKey:touch.identity];
        
        if (!beginTouch)
            continue;
        
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
    
    // Need at least two points
    if ([magnitudes count] < 2) {
        return;
    }
    
    CGFloat sum = 0;
    
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
    
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
    
    if (naturalDirectionEnabled)
        sum *= -1;
    
    [swipeView setSwipeAmount:sum];
    [swipeView setNeedsDisplay:YES];
}

@end