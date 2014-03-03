/*
 * CustomWebView.h
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>
#import "SwipeView.h"

@protocol CustomWebViewDelegate

@end

@interface CustomWebView : WebView {
    CGFloat _swipeAmount;
    NSMutableDictionary *_touches;
}

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;
@property (retain) SwipeView *swipeView;

@end
