/*
 * DummyWebViewPolicyDelegate.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "DummyWebViewPolicyDelegate.h"

@implementation DummyWebViewPolicyDelegate

// Open anything in the default browser.
- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [[NSWorkspace sharedWorkspace] openURL:request.URL];
}

@end
