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

- (void)awakeFromNib
{
    [repeatButton    setImage:[self imageFromName:@"repeat_none"]];
    [backButton      setImage:[self imageFromName:@"previous"]];
    [playPauseButton setImage:[self imageFromName:@"play"]];
    [forwardButton   setImage:[self imageFromName:@"next"]];
    [shuffleButton   setImage:[self imageFromName:@"shuffle_off"]];
}

- (NSImage *)imageFromName:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"images/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"png"];
    
    return [[NSImage alloc] initWithContentsOfFile:path];
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
        [playPauseButton setImage:[self imageFromName:@"pause"]];
    else
        [playPauseButton setImage:[self imageFromName:@"play"]];
}

- (void)repeatChanged:(NSString *)mode
{
    if ([MUSIC_NO_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self imageFromName:@"repeat_none"]];
    else if ([MUSIC_LIST_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self imageFromName:@"repeat_list"]];
    else if ([MUSIC_SINGLE_REPEAT isEqualToString:mode])
        [repeatButton setImage:[self imageFromName:@"repeat_single"]];
}

- (void)shuffleChanged:(NSString *)mode
{
    if ([MUSIC_ALL_SHUFFLE isEqualToString:mode])
        [shuffleButton setImage:[self imageFromName:@"shuffle_on"]];
    else
        [shuffleButton setImage:[self imageFromName:@"shuffle_off"]];
}

@end
