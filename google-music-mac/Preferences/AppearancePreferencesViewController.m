/*
 * AppearancePreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "AppearancePreferencesViewController.h"

@implementation AppearancePreferencesViewController

- (NSString *)identifier
{
    return @"AppearancePreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameColorPanel];
}

- (NSString *)toolbarItemLabel
{
    return @"Appearance";
}

@end
