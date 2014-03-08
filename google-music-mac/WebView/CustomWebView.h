/*
 * CustomWebView.h
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>
#import "SwipeIndicatorView.h"

@protocol CustomWebViewDelegate

@end

@interface CustomWebView : WebView {
    NSMutableDictionary *_touches;
}

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;
@property (retain) SwipeIndicatorView *swipeView;

- (IBAction)selectAll:(id)sender;

@end
