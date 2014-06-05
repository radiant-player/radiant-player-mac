/*
 * CustomWebView.h
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "SwipeIndicatorView.h"

@protocol CustomWebViewDelegate

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;
- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request;
- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener;
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;

@end

@interface CustomWebView : WebView {
    NSMutableDictionary *_touches;
}

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;
@property (retain) SwipeIndicatorView *swipeView;

@property (retain) NSData *invertedSpriteSheet;

- (IBAction)selectAll:(id)sender;

@end
