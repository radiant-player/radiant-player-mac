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

- (void)awakeFromNib
{
    isNotificationImageSupportAvailable = [NSUserNotification instancesRespondToSelector:@selector(setContentImage:)];
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
