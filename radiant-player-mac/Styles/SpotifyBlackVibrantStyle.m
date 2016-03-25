/*
 * SpotifyBlackVibrantStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "SpotifyBlackVibrantStyle.h"

@implementation SpotifyBlackVibrantStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Spotify Black - Vibrant"];
        [self setAuthor:@"Sajid Anwar"];
        [self setDescription:@"Vibrancy additions to the Spotify Black style."];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.133f green:0.137f blue:0.149f alpha:1.0f]];
        [self setTitleColor:[NSColor colorWithDeviceWhite:0.7f alpha:1.0f]];
    }

    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantDark];
    [self setCss:[NSString stringWithFormat:@"%@%@", [self css], [ApplicationStyle cssNamed:@"spotify-black-yosemite"]]];
    [self setCss:[NSString stringWithFormat:@"%@%@", [self css], [ApplicationStyle cssNamed:@"spotify-black-vibrant-yosemite"]]];
    [super applyToWebView:webView window:window];
}

@end
