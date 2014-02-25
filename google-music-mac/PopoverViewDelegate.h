/*
 * PopoverViewDelegate.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>

#import "AppDelegate.h"

@class AppDelegate;

@interface PopoverViewDelegate : NSObject

@property (assign) IBOutlet AppDelegate *appDelegate;

@property (assign) IBOutlet NSImageView *artView;
@property (assign) IBOutlet NSTextField *titleLabel;
@property (assign) IBOutlet NSTextField *artistLabel;
@property (assign) IBOutlet NSTextField *albumLabel;

@property (assign) IBOutlet NSButton *repeatButton;
@property (assign) IBOutlet NSButton *backButton;
@property (assign) IBOutlet NSButton *playPauseButton;
@property (assign) IBOutlet NSButton *forwardButton;
@property (assign) IBOutlet NSButton *shuffleButton;

- (NSImage *) imageFromName:(NSString *)name;

- (void) updateSong:(NSString *)title artist:(NSString *)artist album:(NSString *)album art:(NSString *)art;

- (IBAction) repeatAction:(NSObject *)sender;
- (IBAction) backAction:(NSObject *)sender;
- (IBAction) playPauseAction:(NSObject *)sender;
- (IBAction) forwardAction:(NSObject *)sender;
- (IBAction) shuffleAction:(NSObject *)sender;

@end
