/*
 * PrivacyPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <MASPreferences/MASPreferencesViewController.h>
#import "Utilities.h"

@interface PrivacyPreferencesViewController : NSViewController<MASPreferencesViewController>

@property (assign) IBOutlet NSButton *useSafariCheckBox;
@property (assign) IBOutlet NSButton *saveCookiesCheckBox;
@property (assign) IBOutlet NSButton *removeCookiesButton;

- (IBAction)removeCookies:(id)sender;
- (IBAction)preferenceSaveCookiesChanged:(id)sender;

@end
