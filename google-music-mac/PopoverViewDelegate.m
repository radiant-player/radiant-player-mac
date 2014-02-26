/*
 * PopoverViewDelegate.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopoverViewDelegate.h"

@implementation PopoverViewDelegate

@synthesize appDelegate;

@synthesize artView;
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

- (void)awakeFromNib
{
    [repeatButton    setImage:[AppDelegate imageFromName:@"repeat_none"]];
    [backButton      setImage:[AppDelegate imageFromName:@"previous"]];
    [playPauseButton setImage:[AppDelegate imageFromName:@"play"]];
    [forwardButton   setImage:[AppDelegate imageFromName:@"next"]];
    [shuffleButton   setImage:[AppDelegate imageFromName:@"shuffle_off"]];
    
    [thumbsupButton   setImage:[AppDelegate imageFromName:@"thumbsup_outline"]];
    [thumbsdownButton   setImage:[AppDelegate imageFromName:@"thumbsdown_outline"]];
}

- (void)updateSong:(NSString *)title artist:(NSString *)artist album:(NSString *)album art:(NSString *)art
{
    [titleLabel setStringValue:title];
    [artistLabel setStringValue:artist];
    [albumLabel setStringValue:album];
    
    if (art != nil) {
        NSURL *url = [NSURL URLWithString:art];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
        [artView setImage:image];
    }
}
    
- (void)playbackChanged:(NSInteger)mode
{
    if (mode == MUSIC_PLAYING)
        [playPauseButton setImage:[AppDelegate imageFromName:@"pause"]];
    else
        [playPauseButton setImage:[AppDelegate imageFromName:@"play"]];
}

- (void)repeatChanged:(NSString *)mode
{
    if ([MUSIC_NO_REPEAT isEqualToString:mode])
        [repeatButton setImage:[AppDelegate imageFromName:@"repeat_none"]];
    else if ([MUSIC_LIST_REPEAT isEqualToString:mode])
        [repeatButton setImage:[AppDelegate imageFromName:@"repeat_list"]];
    else if ([MUSIC_SINGLE_REPEAT isEqualToString:mode])
        [repeatButton setImage:[AppDelegate imageFromName:@"repeat_single"]];
}

- (void)shuffleChanged:(NSString *)mode
{
    if ([MUSIC_ALL_SHUFFLE isEqualToString:mode])
        [shuffleButton setImage:[AppDelegate imageFromName:@"shuffle_on"]];
    else
        [shuffleButton setImage:[AppDelegate imageFromName:@"shuffle_off"]];
}
    
- (void)ratingChanged:(NSInteger)rating
{
    if (rating == MUSIC_RATING_THUMBSUP)
    {
        [thumbsupButton setImage:[AppDelegate imageFromName:@"thumbsup_on"]];
        [thumbsdownButton setImage:[AppDelegate imageFromName:@"thumbsdown_outline"]];
    }
    else if (rating == MUSIC_RATING_THUMBSDOWN)
    {
        [thumbsupButton setImage:[AppDelegate imageFromName:@"thumbsup_outline"]];
        [thumbsdownButton setImage:[AppDelegate imageFromName:@"thumbsdown_on"]];
    }
    else
    {
        [thumbsupButton setImage:[AppDelegate imageFromName:@"thumbsup_outline"]];
        [thumbsdownButton setImage:[AppDelegate imageFromName:@"thumbsdown_outline"]];
    }
}

@end
