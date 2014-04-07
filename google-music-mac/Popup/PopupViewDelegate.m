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

@synthesize playbackMode;
@synthesize repeatMode;
@synthesize shuffleMode;
@synthesize songRating;

@synthesize noSongLabel;

@synthesize artExpandView;
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
    [repeatButton    setImage:[self repeatNoneImage]];
    [backButton      setImage:[self backImage]];
    [playPauseButton setImage:[self playImage]];
    [forwardButton   setImage:[self forwardImage]];
    [shuffleButton   setImage:[self shuffleOffImage]];
    
    [thumbsupButton   setImage:[self thumbsUpOffImage]];
    [thumbsdownButton setImage:[self thumbsUpOnImage]];
    
    [artExpandView setImage:[self expandContractImage]];
    [popup.popupView setIsLargePlayer:NO];
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
    
    // Update the large mini player if necessary.
    if (popup.popupView.isLargePlayer)
    {
        [popup.popupView setBackgroundImage:image];
        [popup.popupView setNeedsDisplay:YES];
    }
}

- (void)playbackChanged:(NSInteger)mode
{
    playbackMode = mode;
    
    if (mode == MUSIC_PLAYING)
        [playPauseButton setImage:[self pauseImage]];
    else
        [playPauseButton setImage:[self playImage]];
}

- (void)playbackTimeChanged:(NSInteger)currentTime totalTime:(NSInteger)totalTime
{
    [playbackSlider setMaxValue:totalTime];
    [playbackSlider setIntegerValue:currentTime];
}

- (void)repeatChanged:(NSString *)mode
{
    repeatMode = mode;
    
    if ([MUSIC_NO_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self repeatNoneImage]];
    else if ([MUSIC_LIST_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self repeatAllImage]];
    else if ([MUSIC_SINGLE_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self repeatOneImage]];
}

- (void)shuffleChanged:(NSString *)mode
{
    shuffleMode = mode;
    
    if ([MUSIC_ALL_SHUFFLE isEqualToString:mode])
        [shuffleButton setImage:[self shuffleOnImage]];
    else
        [shuffleButton setImage:[self shuffleOffImage]];
}
    
- (void)ratingChanged:(NSInteger)rating
{
    songRating = rating;
    
    if (rating == MUSIC_RATING_THUMBSUP)
    {
        [thumbsupButton setImage:[self thumbsUpOnImage]];
        [thumbsdownButton setImage:[self thumbsDownOffImage]];
    }
    else if (rating == MUSIC_RATING_THUMBSDOWN)
    {
        [thumbsupButton setImage:[self thumbsUpOffImage]];
        [thumbsdownButton setImage:[self thumbsDownOnImage]];
    }
    else
    {
        [thumbsupButton setImage:[self thumbsUpOffImage]];
        [thumbsdownButton setImage:[self thumbsDownOffImage]];
    }
}

- (void)setPlaybackTime:(id)sender
{
    NSInteger value = [playbackSlider integerValue];
    [appDelegate setPlaybackTime:value];
}

- (void)togglePlayerSize:(id)sender
{
    if ([popup.popupView isLargePlayer])
        [[appDelegate defaults] setBool:NO forKey:@"miniplayer.large"];
    else
        [[appDelegate defaults] setBool:YES forKey:@"miniplayer.large"];
    
    [popup.popupView togglePlayerSize];
}

- (void)hidePopupAndShowWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[appDelegate window] makeKeyAndOrderFront:self];
    [popup close];
}

#pragma mark - Image code

- (NSImage *)repeatNoneImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"repeat_none_white"];
    else
        return [Utilities imageFromName:@"repeat_none"];
}

- (NSImage *)repeatOneImage
{
    return [Utilities imageFromName:@"repeat_single"];
}

- (NSImage *)repeatAllImage
{
    return [Utilities imageFromName:@"repeat_list"];
}

- (NSImage *)backImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"previous_white"];
    else
        return [Utilities imageFromName:@"previous"];
}

- (NSImage *)playImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"play_white"];
    else
        return [Utilities imageFromName:@"play"];
}

- (NSImage *)pauseImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"pause_white"];
    else
        return [Utilities imageFromName:@"pause"];
}

- (NSImage *)forwardImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"next_white"];
    else
        return [Utilities imageFromName:@"next"];
}

- (NSImage *)shuffleOffImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"shuffle_off_white"];
    else
        return [Utilities imageFromName:@"shuffle_off"];
}

- (NSImage *)shuffleOnImage
{
    return [Utilities imageFromName:@"shuffle_on"];
}

- (NSImage *)thumbsUpOffImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"thumbsup_outline_white"];
    else
        return [Utilities imageFromName:@"thumbsup_outline"];
}

- (NSImage *)thumbsUpOnImage
{
    return [Utilities imageFromName:@"thumbsup_on"];
}

- (NSImage *)thumbsDownOffImage
{
    if (popup.popupView.isLargePlayer)
        return [Utilities imageFromName:@"thumbsdown_outline_white"];
    else
        return [Utilities imageFromName:@"thumbsdown_outline"];
}

- (NSImage *)thumbsDownOnImage
{
    return [Utilities imageFromName:@"thumbsdown_on"];
}

- (NSImage *)expandContractImage
{
    if (popup.popupView.isLargePlayer)
    return [Utilities imageFromName:@"arrow_contract_art"];
    else
    return [Utilities imageFromName:@"arrow_expand_art"];
}

@end
