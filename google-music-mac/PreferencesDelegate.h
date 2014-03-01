/*
 * PreferencesDelegate.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface PreferencesDelegate : NSObject

@property (strong) IBOutlet NSTextField *lastFMUsernameField;
@property (strong) IBOutlet NSSecureTextField *lastFMPasswordField;
@property (strong) IBOutlet NSButton *lastFMAuthorizeButton;

@property (assign) NSUserDefaults *defaults;

- (IBAction) lastFMAuthorizeScrobble:(NSButton *)sender;
- (void) lastFMSync;

@end
