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
        [self setJs:[ApplicationStyle jsNamed:@"yosemite"]];
    }
    
    return self;
}

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window
{
    [super applyToWebView:webView window:window];
    
    [window setBackgroundColor:[NSColor colorWithSRGBRed:0.945 green:0.945 blue:0.945 alpha:1]];
    [window setStyleMask:(window.styleMask | NSFullSizeContentViewWindowMask)];
    [window setTitlebarAppearsTransparent:YES];
    [window setTitleVisibility:NSWindowTitleHidden];
    
    [webView setDrawsBackground:NO];
    
    NSRect frame = window.frame;
    frame.origin = CGPointMake(0, 0);
    
    NSVisualEffectView *bgView = [[NSVisualEffectView alloc] initWithFrame:frame];
    [bgView setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    [bgView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [bgView setMaterial:NSVisualEffectMaterialLight];
    [bgView setState:NSVisualEffectStateFollowsWindowActiveState];
    [bgView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    [[window contentView] addSubview:bgView positioned:NSWindowBelow relativeTo:nil];
}

@end
