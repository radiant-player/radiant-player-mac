/*
 * AboutWindow.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import "Utilities.h"

@interface AboutWindow : NSWindow

@property (assign) IBOutlet NSTextField *versionLabel;
@property (assign) IBOutlet NSTextField *creditsField;
@property (assign) IBOutlet NSTextField *checkLabel;
@property (assign) IBOutlet NSProgressIndicator *checkProgress;

- (IBAction)showAboutWindow:(id)sender;
- (void)checkVersion;

@end
