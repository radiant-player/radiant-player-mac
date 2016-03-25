/*
 * YosemiteStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "YosemiteStyle.h"

@implementation YosemiteStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Yosemite"];
        [self setAuthor:@"Sajid Anwar"];
        [self setDescription:@"A style that integrates Radiant Player with the Mac OS X Yosemite appearance."];
        [self setCss:[ApplicationStyle cssNamed:@"yosemite"]];
    }

    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [super applyToWebView:webView window:window];
    [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantLight];
}

@end
