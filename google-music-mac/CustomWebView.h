/*
 * CustomWebView.h
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>

#define SWIPE_MINIMUM_LENGTH 0.3

@protocol CustomWebViewDelegate

@end

@interface CustomWebView : WebView {
    CGFloat _swipeAmount;
    NSMutableDictionary *_touches;
}

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;

@end
