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

- (IBAction)showAboutWindow:(id)sender;

@end
