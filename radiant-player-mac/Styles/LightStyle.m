/*
 * LightStyle.m
 *
 * Created by Steven La.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "LightStyle.h"

@implementation LightStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Light"];
        [self setAuthor:@"Steven La"];
        [self setDescription:@"A lightweight theme that integrates the header."];
        [self setCss:[ApplicationStyle cssNamed:@"light"]];
        [self setJs:[ApplicationStyle jsNamed:@"light"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [super applyToWebView:webView window:window];
    [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantLight];
}

@end
