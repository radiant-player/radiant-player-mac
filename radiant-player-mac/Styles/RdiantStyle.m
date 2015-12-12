/*
 * RdiantStyle.m
 *
 * Created by Andrew Norell.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "RdiantStyle.h"

@implementation RdiantStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Rdiant"];
        [self setAuthor:@"Andrew Norell & Carl Schultze"];
        [self setDescription:@"An homage to the late, great streaming service."];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.133f green:0.137f blue:0.149f alpha:1.0f]];
        [self setTitleColor:[NSColor colorWithDeviceWhite:0.7f alpha:1.0f]];
        [self setCss:[ApplicationStyle cssNamed:@"rdiant"]];
        [self setJs:[ApplicationStyle jsNamed:@"rdiant"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [self setCss:[NSString stringWithFormat:@"%@%@", [self css], [ApplicationStyle cssNamed:@"rdiant"]]];
    [super applyToWebView:webView window:window];
}

@end
