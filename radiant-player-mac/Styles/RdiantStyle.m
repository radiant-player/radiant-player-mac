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
        //[self setWindowColor:[NSColor colorWithDeviceRed:(1/255.0f) green:(143/255.0f) blue:(213/255.0f) alpha:1.0]];
        [self setWindowColor:[NSColor colorWithDeviceRed:(245/255.0f) green:(245/255.0f) blue:(245/255.0f) alpha:1.0]];
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
