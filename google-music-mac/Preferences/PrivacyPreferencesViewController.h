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

@property (assign) IBOutlet NSButton *saveCookiesCheckBox;

- (IBAction)removeCookies:(id)sender;
- (IBAction)preferenceSaveCookiesChanged:(id)sender;

@end
