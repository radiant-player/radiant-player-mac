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
    [backButton      setImage:[self imageFromName:@"back"]];
    [playPauseButton setImage:[self imageFromName:@"play"]];
    [forwardButton   setImage:[self imageFromName:@"forward"]];
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

- (void)repeatAction:(NSObject *)sender
{
    
}

- (void)backAction:(NSObject *)sender
{
    
}

- (void)playPauseAction:(NSObject *)sender
{
    
}

- (void)forwardAction:(NSObject *)sender
{
    
}

- (void)shuffleAction:(NSObject *)sender
{
    
}

@end
