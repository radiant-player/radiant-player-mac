/*
 * ApplicationStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "ApplicationStyle.h"
#import "CocoaStyle.h"
#import "DarkStyle.h"
#import "DarkFlatStyle.h"
#import "SpotifyBlackStyle.h"
#import "SpotifyBlackVibrantStyle.h"
#import "YosemiteStyle.h"
#import "LightStyle.h"
#import "../AppDelegate.h"

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
    [window setBackgroundColor:[self windowColor]];
    [[(AppDelegate *)[window delegate] titleView] setColor:[self titleColor]];
    
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
    DarkStyle *dark = [[DarkStyle alloc] init];
    DarkFlatStyle *darkFlat = [[DarkFlatStyle alloc] init];
    SpotifyBlackStyle *spotifyBlack = [[SpotifyBlackStyle alloc] init];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:dark forKey:[dark name]];
    [dictionary setObject:darkFlat forKey:[darkFlat name]];
    [dictionary setObject:spotifyBlack forKey:[spotifyBlack name]];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
    {
        YosemiteStyle *yosemite = [[YosemiteStyle alloc] init];
        [dictionary setObject:yosemite forKey:[yosemite name]];
        
        LightStyle *barelyYosemite = [[LightStyle alloc] init];
        [dictionary setObject:barelyYosemite forKey:[barelyYosemite name]];
        
        SpotifyBlackVibrantStyle *spotifyBlackVibrant = [[SpotifyBlackVibrantStyle alloc] init];
        [dictionary setObject:spotifyBlackVibrant forKey:[spotifyBlackVibrant name]];
    }
    else
    {
        CocoaStyle *cocoa = [[CocoaStyle alloc] init];
        [dictionary setObject:cocoa forKey:[cocoa name]];
    }
    
    return dictionary;
}

+ (void)applyYosemiteVisualEffects:(WebView *)webView window:(NSWindow *)window appearance:(NSString *)appearanceName
{
    [window setBackgroundColor:[NSColor colorWithSRGBRed:0.945 green:0.945 blue:0.945 alpha:1]];
    [(AppDelegate *)[NSApp delegate] useTallTitleBar];
    
    [webView setDrawsBackground:NO];
    
    NSRect frame = window.frame;
    frame.origin = CGPointMake(0, 0);
    
    NSArray *subviews = [[window contentView] subviews];
    
    if ([[subviews firstObject] isKindOfClass:[VisualEffectView class]]) {
        VisualEffectView *bgView = [subviews firstObject];
        [bgView setAppearance:[NSAppearance appearanceNamed:appearanceName]];
    }
    else {
        VisualEffectView *bgView = [[VisualEffectView alloc] initWithFrame:frame];
        [bgView setAppearance:[NSAppearance appearanceNamed:appearanceName]];
        [bgView setBlendingMode:VisualEffectBlendingModeBehindWindow];
        [bgView setMaterial:VisualEffectMaterialAppearanceBased];
        [bgView setState:VisualEffectStateFollowsWindowActiveState];
        [bgView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [[window contentView] addSubview:bgView positioned:NSWindowBelow relativeTo:nil];
    }
}

@end
