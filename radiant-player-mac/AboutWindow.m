/*
 * AboutWindow.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "AboutWindow.h"

@implementation AboutWindow

@synthesize versionLabel;
@synthesize creditsField;

- (void)awakeFromNib
{
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"Version %@", shortVersion];
    [versionLabel setStringValue:versionString];
    
    NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"];
    NSData *creditsData = [NSData dataWithContentsOfFile:creditsPath];
    NSAttributedString *creditsString = [[NSAttributedString alloc] initWithRTF:creditsData documentAttributes:nil];
    [creditsField setAttributedStringValue:creditsString];
}

- (void)showAboutWindow:(id)sender
{
    // Activate the app in case it is hidden.
    [NSApp activateIgnoringOtherApps:YES];
    [self makeKeyAndOrderFront:nil];
}

@end
