/*
 * NavigationPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NavigationPreferencesViewController.h"

@implementation NavigationPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (NSString *)identifier
{
    return @"NavigationPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [Utilities imageFromName:@"key"];
}

- (NSString *)toolbarItemLabel
{
    return @"Navigation";
}

@end
