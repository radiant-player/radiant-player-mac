/*
 * BarelyYosemiteStyle.m
 *
 * Created by Steven La.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "BarelyYosemiteStyle.h"

@implementation BarelyYosemiteStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Barely Yosemite"];
        [self setAuthor:@"Steven La"];
        [self setDescription:@"A lightweight theme that integrates the header."];
        [self setCss:[ApplicationStyle cssNamed:@"barely-yosemite"]];
//        [self setJs:[ApplicationStyle jsNamed:@"yosemite"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [super applyToWebView:webView window:window];
    [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantLight];
}

@end
