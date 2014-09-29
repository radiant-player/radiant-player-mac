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

@synthesize sortDescriptors;

- (void)awakeFromNib
{
    self.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
}

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
