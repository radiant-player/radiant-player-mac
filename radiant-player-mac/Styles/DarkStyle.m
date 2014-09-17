/*
 * DarkStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "DarkStyle.h"

@implementation DarkStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Dark Flat"];
        [self setAuthor:@"Stefan Hoffmann"];
        [self setDescription:@"A flat version of the dark style."];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.768f green:0.768f blue:0.768f alpha:1.0f]];
        [self setTitleColor:nil];
        [self setCss:[ApplicationStyle cssNamed:@"dark-flat"]];
        [self setJs:[ApplicationStyle jsNamed:@"dark-flat"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [ApplicationStyle applyYosemiteVisualEffects:webView window:window];
        [self setCss:[NSString stringWithFormat:@"%@%@", [self css], [ApplicationStyle cssNamed:@"dark-yosemite"]]];
    }
    
    [super applyToWebView:webView window:window];
}

@end
