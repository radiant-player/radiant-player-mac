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
#import "../Updates/ReleaseChannel.h"

@interface GeneralPreferencesViewController : NSViewController<MASPreferencesViewController>

@property (assign) IBOutlet NSPopUpButton *buttonReleaseChannels;

@property (assign) BOOL isNotificationImageSupportAvailable;
@property (assign) BOOL isGrowlSupportAvailable;

- (IBAction)toggleDockArt:(NSButton *)sender;

@end
