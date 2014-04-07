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

@interface GeneralPreferencesViewController : NSViewController<MASPreferencesViewController>

@property (assign) BOOL isNotificationImageSupportAvailable;

@end
