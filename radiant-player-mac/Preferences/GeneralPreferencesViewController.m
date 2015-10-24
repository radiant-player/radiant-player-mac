/*
 * GeneralPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "GeneralPreferencesViewController.h"
#import "AppDelegate.h"

@implementation GeneralPreferencesViewController

@synthesize isNotificationImageSupportAvailable;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        self.isNotificationImageSupportAvailable = [NSUserNotification instancesRespondToSelector:@selector(setContentImage:)];
        self.isGrowlSupportAvailable = [GrowlApplicationBridge isGrowlRunning];
    }
    return self;
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return @"General";
}

- (IBAction) toggleDockArt:(NSButton *)sender
{
    BOOL showArt = [sender state] == NSOnState;
    [(AppDelegate *)[NSApp delegate] toggleDockArt:showArt];
}

@end
