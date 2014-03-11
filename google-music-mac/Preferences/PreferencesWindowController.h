/*
 * PreferencesWindowController.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <MASPreferences/MASPreferencesWindowController.h>
#import "GeneralPreferencesViewController.h"
#import "AppearancePreferencesViewController.h"
#import "NavigationPreferencesViewController.h"
#import "LastFmPreferencesViewController.h"

@interface PreferencesWindowController : MASPreferencesWindowController

@property (assign) IBOutlet GeneralPreferencesViewController *generalController;
@property (assign) IBOutlet AppearancePreferencesViewController *appearanceController;
@property (assign) IBOutlet NavigationPreferencesViewController *navigationController;
@property (assign) IBOutlet LastFmPreferencesViewController *lastFmController;

- (void)loadControllers;

@end
