/*
 * PopupViewDelegate.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <EDStarRating/EDStarRating.h>

#import "AppDelegate.h"
#import "PopupPanel.h"
#import "Utilities.h"
#import "PlaybackConstants.h"

@class AppDelegate;
@class PopupPanel;

@interface PopupViewDelegate : NSObject<EDStarRatingProtocol>

@property (assign) IBOutlet AppDelegate *appDelegate;
@property (assign) IBOutlet PopupPanel *popup;

@property (assign) NSInteger playbackMode;
@property (retain) NSString *repeatMode;
@property (retain) NSString *shuffleMode;
@property (assign) NSInteger songRating;

@property (assign) IBOutlet NSTextField *noSongLabel;

@property (assign) IBOutlet NSMenu *actionButtonMenu;
@property (assign) IBOutlet NSLayoutConstraint *actionButtonTopConstraint;
@property (assign) IBOutlet NSButton *actionButton;
@property (assign) IBOutlet NSImageView *artExpandView;
@property (assign) IBOutlet NSButton *artView;
@property (assign) IBOutlet NSProgressIndicator *artProgress;
@property (assign) IBOutlet NSTextField *titleLabel;
@property (assign) IBOutlet NSTextField *artistLabel;
@property (assign) IBOutlet NSTextField *albumLabel;
@property (assign) IBOutlet NSView *infoView;

@property (assign) IBOutlet NSButton *repeatButton;
@property (assign) IBOutlet NSButton *backButton;
@property (assign) IBOutlet NSButton *playPauseButton;
@property (assign) IBOutlet NSButton *forwardButton;
@property (assign) IBOutlet NSButton *shuffleButton;
    
@property (assign) IBOutlet NSButton *thumbsupButton;
@property (assign) IBOutlet NSButton *thumbsdownButton;

@property (assign) IBOutlet NSButton *starBadgeButton;
@property (assign) IBOutlet EDStarRating *starRatingView;

@property (assign) IBOutlet NSSlider *playbackSlider;

- (void) updateSong:(NSString *)title artist:(NSString *)artist album:(NSString *)album art:(NSString *)art;
- (void) downloadAlbumArt:(NSString *)art;
    
- (void) shuffleChanged:(NSString *)mode;
- (void) repeatChanged:(NSString *)mode;
- (void) playbackChanged:(NSInteger)mode;
- (void) playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void) ratingChanged:(NSInteger)rating;

- (void) setupStarRatingView;
- (void) starsSelectionChanged:(id)sender rating:(float)rating;

- (IBAction) setPlaybackTime:(id)sender;
- (IBAction) togglePlayerSize:(id)sender;
- (IBAction) actionButtonSelector:(id)sender;
- (IBAction) showMainWindow:(id)sender;

- (void) popupDidDock;
- (void) popupDidUndock;

- (NSImage *) repeatNoneImage;
- (NSImage *) repeatOneImage;
- (NSImage *) repeatAllImage;
- (NSImage *) backImage;
- (NSImage *) playImage;
- (NSImage *) pauseImage;
- (NSImage *) forwardImage;
- (NSImage *) shuffleOffImage;
- (NSImage *) shuffleOnImage;
- (NSImage *) thumbsUpOffImage;
- (NSImage *) thumbsUpOnImage;
- (NSImage *) thumbsDownOffImage;
- (NSImage *) thumbsDownOnImage;
- (NSImage *) expandContractImage;
- (NSImage *) actionButtonImage;
- (NSImage *) starBadgeImage:(NSInteger)rating;
- (NSImage *) starRatingImage;
- (NSImage *) starRatingHighlightedImage;

@end
