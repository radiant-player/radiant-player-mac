/*
 * PopupViewDelegate.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "PlaybackConstants.h"

@class AppDelegate;

@interface PopupViewDelegate : NSObject

@property (assign) IBOutlet AppDelegate *appDelegate;

@property (assign) IBOutlet NSTextField *noSongLabel;

@property (assign) IBOutlet NSImageView *artView;
@property (assign) IBOutlet NSTextField *titleLabel;
@property (assign) IBOutlet NSTextField *artistLabel;
@property (assign) IBOutlet NSTextField *albumLabel;

@property (assign) IBOutlet NSButton *repeatButton;
@property (assign) IBOutlet NSButton *backButton;
@property (assign) IBOutlet NSButton *playPauseButton;
@property (assign) IBOutlet NSButton *forwardButton;
@property (assign) IBOutlet NSButton *shuffleButton;
    
@property (assign) IBOutlet NSButton *thumbsupButton;
@property (assign) IBOutlet NSButton *thumbsdownButton;

@property (assign) IBOutlet NSSlider *playbackSlider;

- (void) updateSong:(NSString *)title artist:(NSString *)artist album:(NSString *)album art:(NSString *)art;
    
- (void) shuffleChanged:(NSString *)mode;
- (void) repeatChanged:(NSString *)mode;
- (void) playbackChanged:(NSInteger)mode;
- (void) playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void) ratingChanged:(NSInteger)rating;

- (IBAction) setPlaybackTime:(id)sender;

@end
