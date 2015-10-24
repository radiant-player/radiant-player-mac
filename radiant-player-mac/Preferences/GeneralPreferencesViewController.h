/*
 * GeneralPreferencesViewController.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferencesViewController.h>
#import <Growl/Growl.h>

@interface GeneralPreferencesViewController : NSViewController<MASPreferencesViewController>

@property (assign) BOOL isNotificationImageSupportAvailable;
@property (assign) BOOL isGrowlSupportAvailable;

- (IBAction)toggleDockArt:(NSButton *)sender;

@end
