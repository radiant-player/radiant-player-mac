/*
 * LastFmPreferencesViewController.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferencesViewController.h>
#import <LastFm/LastFm.h>
#import "Utilities.h"

@interface LastFmPreferencesViewController : NSViewController<MASPreferencesViewController>

@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *authorizeButton;
@property (strong) IBOutlet NSImageCell *logo;

@property (assign) NSUserDefaults *defaults;

- (IBAction) authorizeScrobble:(id)sender;
- (void) sync;

@end
