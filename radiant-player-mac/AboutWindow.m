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
@synthesize checkLabel;
@synthesize checkProgress;

- (void)awakeFromNib
{
    NSString *versionString = [NSString stringWithFormat:@"Version %@", [UpdateChecker applicationVersion]];
    [versionLabel setStringValue:versionString];
    
    NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"];
    NSData *creditsData = [NSData dataWithContentsOfFile:creditsPath];
    NSAttributedString *creditsString = [[NSAttributedString alloc] initWithRTF:creditsData documentAttributes:nil];
    [creditsField setAttributedStringValue:creditsString];
    
    [self performSelectorInBackground:@selector(checkVersion) withObject:nil];
}

- (void)showAboutWindow:(id)sender
{
    // Activate the app in case it is hidden.
    [NSApp activateIgnoringOtherApps:YES];
    [self makeKeyAndOrderFront:nil];
    [self performSelectorInBackground:@selector(checkVersion) withObject:nil];
}

- (void)checkVersion
{
    [checkProgress startAnimation:self];
    [checkLabel setStringValue:@"Checking for updates..."];
    
    NSDate *start = [NSDate date];
    
    NSString *appVersion = [UpdateChecker applicationVersion];
    NSString *releaseChannel = [UpdateChecker releaseChannel];
    NSString *latestVersion = [UpdateChecker latestVersionFromGithub:releaseChannel];
    
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:start];
    
    // We want to make a delay to show that progress is being made, so that
    // the user is aware that the version is being checked.
    if (elapsed < 0.75) {
        [NSThread sleepForTimeInterval:(1 - elapsed)];
    }
    
    if (latestVersion != nil) {
        if ([UpdateChecker isVersionUpToDateWithApplication:appVersion latest:latestVersion] == NO) {
            // Application is out of date.
            NSString *messageFormat = @"<p style='text-align: center'>The latest version is %@. <a href='%@'>Download it now.</a></p>";
            NSString *messageHTML = [NSString stringWithFormat:messageFormat, latestVersion, [Utilities applicationHomepage]];
            NSData *messageData = [messageHTML dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithHTML:messageData documentAttributes:nil];
            [message addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12] range:NSMakeRange(0, [message length])];
            
            [checkLabel setAttributedStringValue:message];
            [checkLabel setAlignment:NSCenterTextAlignment];
        }
        else {
            // Application is up to date.
            [checkLabel setStringValue:@"You are running the latest version."];
            [checkLabel setAlignment:NSCenterTextAlignment];
        }
    }
    else {
        // Couldn't get the latest version.
        NSString *messageFormat = @"<p style='text-align: center'>Couldn't get the latest version. <a href='%@'>Check the homepage.</a></p>";
        NSString *messageHTML = [NSString stringWithFormat:messageFormat, [Utilities applicationHomepage]];
        NSData *messageData = [messageHTML dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithHTML:messageData documentAttributes:nil];
        [message addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12] range:NSMakeRange(0, [message length])];
        
        [checkLabel setAttributedStringValue:message];
        [checkLabel setAlignment:NSCenterTextAlignment];
    }
    
    [checkProgress stopAnimation:nil];
}

@end
