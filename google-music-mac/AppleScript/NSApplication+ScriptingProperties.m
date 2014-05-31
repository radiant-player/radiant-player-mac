/*
 * NSApplication+ScriptingProperties.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSApplication+ScriptingProperties.h"

@implementation NSApplication (ScriptingProperties)

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[self delegate];
}

- (NSString *)currentTitle
{
    return [[self appDelegate] currentTitle];
}

- (NSString *)currentArtist
{
    return [[self appDelegate] currentArtist];
}

- (NSString *)currentAlbum
{
    return [[self appDelegate] currentAlbum];
}

- (NSImage *)currentArt
{
    NSImage *image = [[self appDelegate] currentArt];
    
    if (image == nil)
    {
        image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[self appDelegate] currentArtURL]]];
        [[self appDelegate] setCurrentArt:image];
    }
    
    return image;
}

- (NSString *)currentSongURL
{
    return [[self appDelegate] currentSongURL];
}

- (NSInteger) currentPlaybackMode
{
    return [[self appDelegate] currentPlaybackMode];
}

@end
