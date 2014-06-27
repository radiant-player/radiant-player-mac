/*
 * ApplicationStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "ApplicationStyle.h"
#import "YosemiteStyle.h"

@implementation ApplicationStyle

@synthesize name;
@synthesize author;
@synthesize description;
@synthesize version;

@synthesize windowColor;
@synthesize titleColor;

@synthesize css;
@synthesize js;

- (void)applyToWebView:(id)webView window:(NSWindow *)window
{
    // Setup the CSS.
    NSString *cssBootstrap = @"Styles.applyStyle(\"%@\", \"%@\");";
    NSString *cssFinal = [NSString stringWithFormat:cssBootstrap, [self name], [self css]];
    
    [webView stringByEvaluatingJavaScriptFromString:cssFinal];
    [webView stringByEvaluatingJavaScriptFromString:[self js]];
}

+ (NSString *)cssNamed:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"css/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"css"];
    NSString *css = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    css = [css stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    css = [css stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return css;
}

+ (NSString *)jsNamed:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"js/styles/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    return js;
}

+ (NSMutableDictionary *)styles
{
    // Create the Cocoa style.
    ApplicationStyle *cocoa = [[ApplicationStyle alloc] init];
    [cocoa setName:@"Cocoa"];
    [cocoa setAuthor:@"Sajid Anwar"];
    [cocoa setDescription:@"An application style to match Mac OS X."];
    [cocoa setWindowColor:[NSColor colorWithSRGBRed:0.898f green:0.898f blue:0.898f alpha:1.0f]];
    [cocoa setTitleColor:nil];
    [cocoa setCss:[ApplicationStyle cssNamed:@"cocoa"]];
    [cocoa setJs:[ApplicationStyle jsNamed:@"cocoa"]];
    
    // Create the Dark style.
    ApplicationStyle *dark = [[ApplicationStyle alloc] init];
    [dark setName:@"Dark"];
    [dark setAuthor:@"Sajid Anwar"];
    [dark setDescription:@"A dark style similar to Spotify."];
    [dark setWindowColor:[NSColor colorWithSRGBRed:0.768f green:0.768f blue:0.768f alpha:1.0f]];
    [dark setTitleColor:nil];
    [dark setCss:[ApplicationStyle cssNamed:@"dark"]];
    [dark setJs:[ApplicationStyle jsNamed:@"dark"]];
    
    // Create the Dark Flat style.
    ApplicationStyle *darkFlat = [[ApplicationStyle alloc] init];
    [darkFlat setName:@"Dark Flat"];
    [darkFlat setAuthor:@"Stefan Hoffmann"];
    [darkFlat setDescription:@"A flat version of the dark style."];
    [darkFlat setWindowColor:[NSColor colorWithSRGBRed:0.768f green:0.768f blue:0.768f alpha:1.0f]];
    [darkFlat setTitleColor:nil];
    [darkFlat setCss:[ApplicationStyle cssNamed:@"dark-flat"]];
    [darkFlat setJs:[ApplicationStyle jsNamed:@"dark-flat"]];
    
    // Create the Spotify Black style.
    ApplicationStyle *spotifyBlack = [[ApplicationStyle alloc] init];
    [spotifyBlack setName:@"Spotify Black"];
    [spotifyBlack setAuthor:@"Anthony Barone"];
    [spotifyBlack setDescription:@"A black style similar to the new Spotify."];
    [spotifyBlack setWindowColor:[NSColor colorWithSRGBRed:0.133f green:0.137f blue:0.149f alpha:1.0f]];
    [spotifyBlack setTitleColor:[NSColor colorWithDeviceWhite:0.7f alpha:1.0f]];
    [spotifyBlack setCss:[ApplicationStyle cssNamed:@"spotify-black"]];
    [spotifyBlack setJs:[ApplicationStyle jsNamed:@"spotify-black"]];
    
    // Create the Yosemite style.
    YosemiteStyle *yosemite = [[YosemiteStyle alloc] init];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:cocoa forKey:[cocoa name]];
    [dictionary setObject:dark forKey:[dark name]];
    [dictionary setObject:darkFlat forKey:[darkFlat name]];
    [dictionary setObject:spotifyBlack forKey:[spotifyBlack name]];
    [dictionary setObject:yosemite forKey:[yosemite name]];
    
    return dictionary;
}

@end
