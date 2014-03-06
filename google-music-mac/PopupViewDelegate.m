/*
 * PopupViewDelegate.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopupViewDelegate.h"

@implementation PopupViewDelegate

@synthesize appDelegate;
@synthesize popup;

@synthesize noSongLabel;

@synthesize artView;
@synthesize artProgress;
@synthesize titleLabel;
@synthesize artistLabel;
@synthesize albumLabel;

@synthesize repeatButton;
@synthesize backButton;
@synthesize playPauseButton;
@synthesize forwardButton;
@synthesize shuffleButton;
    
@synthesize thumbsdownButton;
@synthesize thumbsupButton;

@synthesize playbackSlider;

- (void)awakeFromNib
{
    [repeatButton    setImage:[Utilities imageFromName:@"repeat_none"]];
    [backButton      setImage:[Utilities imageFromName:@"previous"]];
    [playPauseButton setImage:[Utilities imageFromName:@"play"]];
    [forwardButton   setImage:[Utilities imageFromName:@"next"]];
    [shuffleButton   setImage:[Utilities imageFromName:@"shuffle_off"]];
    
    [thumbsupButton   setImage:[Utilities imageFromName:@"thumbsup_outline"]];
    [thumbsdownButton   setImage:[Utilities imageFromName:@"thumbsdown_outline"]];
}

- (void)updateSong:(NSString *)title artist:(NSString *)artist album:(NSString *)album art:(NSString *)art
{
    if (![noSongLabel isHidden])
    {
        [noSongLabel setHidden:YES];
        [thumbsupButton setHidden:NO];
        [thumbsdownButton setHidden:NO];
    }
    
    [titleLabel setStringValue:title];
    [artistLabel setStringValue:artist];
    [albumLabel setStringValue:album];
    
    if (art != nil) {
        [artView setImage:nil];
        [artProgress startAnimation:self];
        [self performSelectorInBackground:@selector(downloadAlbumArt:) withObject:art];
    }
}

- (void)downloadAlbumArt:(NSString *)art
{
    NSURL *url = [NSURL URLWithString:art];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    [artView setImage:image];
    [artProgress stopAnimation:self];
}

- (void)playbackChanged:(NSInteger)mode
{
    if (mode == MUSIC_PLAYING)
        [playPauseButton setImage:[Utilities imageFromName:@"pause"]];
    else
        [playPauseButton setImage:[Utilities imageFromName:@"play"]];
}

- (void)playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime
{
    [playbackSlider setMaxValue:totalTime];
    [playbackSlider setIntegerValue:currentTime];
}

- (void)repeatChanged:(NSString *)mode
{
    if ([MUSIC_NO_REPEAT isEqualToString:mode])
        [repeatButton setImage:[Utilities imageFromName:@"repeat_none"]];
    else if ([MUSIC_LIST_REPEAT isEqualToString:mode])
        [repeatButton setImage:[Utilities imageFromName:@"repeat_list"]];
    else if ([MUSIC_SINGLE_REPEAT isEqualToString:mode])
        [repeatButton setImage:[Utilities imageFromName:@"repeat_single"]];
}

- (void)shuffleChanged:(NSString *)mode
{
    if ([MUSIC_ALL_SHUFFLE isEqualToString:mode])
        [shuffleButton setImage:[Utilities imageFromName:@"shuffle_on"]];
    else
        [shuffleButton setImage:[Utilities imageFromName:@"shuffle_off"]];
}
    
- (void)ratingChanged:(NSInteger)rating
{
    if (rating == MUSIC_RATING_THUMBSUP)
    {
        [thumbsupButton setImage:[Utilities imageFromName:@"thumbsup_on"]];
        [thumbsdownButton setImage:[Utilities imageFromName:@"thumbsdown_outline"]];
    }
    else if (rating == MUSIC_RATING_THUMBSDOWN)
    {
        [thumbsupButton setImage:[Utilities imageFromName:@"thumbsup_outline"]];
        [thumbsdownButton setImage:[Utilities imageFromName:@"thumbsdown_on"]];
    }
    else
    {
        [thumbsupButton setImage:[Utilities imageFromName:@"thumbsup_outline"]];
        [thumbsdownButton setImage:[Utilities imageFromName:@"thumbsdown_outline"]];
    }
}

- (void)setPlaybackTime:(id)sender
{
    NSInteger value = [playbackSlider integerValue];
    NSLog(@"value: %ld", (long)value);
    [appDelegate setPlaybackTime:value];
}

- (void)hidePopupAndShowWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[appDelegate window] makeKeyAndOrderFront:self];
    [popup close];
}

@end
