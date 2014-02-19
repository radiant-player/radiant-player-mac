/*
* CustomWebView.h
*
* Originally created by James Fator. Modified by Sajid Anwar.
*
* Subject to terms and conditions in LICENSE.md.
*
*/

#import <WebKit/WebKit.h>

@protocol CustomWebViewDelegate

@end

@interface CustomWebView : WebView

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;

@end
