/*
 * GeneralPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "GeneralPreferencesViewController.h"

@implementation GeneralPreferencesViewController

@synthesize isNotificationImageSupportAvailable;
@synthesize buttonReleaseChannels;

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

@end
