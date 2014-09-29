/*
 * DarkFlatStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "DarkFlatStyle.h"

@implementation DarkFlatStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Dark"];
        [self setAuthor:@"Sajid Anwar"];
        [self setDescription:@"A dark style similar to Spotify."];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.768f green:0.768f blue:0.768f alpha:1.0f]];
        [self setTitleColor:nil];
        [self setCss:[ApplicationStyle cssNamed:@"dark"]];
        [self setJs:[ApplicationStyle jsNamed:@"dark"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [ApplicationStyle applyYosemiteVisualEffects:webView window:window appearance:NSAppearanceNameVibrantDark];
        [self setCss:[NSString stringWithFormat:@"%@%@", [self css], [ApplicationStyle cssNamed:@"dark-yosemite"]]];
    }
    
    [super applyToWebView:webView window:window];
}

@end
