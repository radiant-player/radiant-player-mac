/*
 * AdvancedPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "AdvancedPreferencesViewController.h"

@implementation AdvancedPreferencesViewController

- (NSString *)identifier
{
    return @"AdvancedPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return @"Advanced";
}

@end
