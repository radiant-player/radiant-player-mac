//
//  PopoverDelegate.m
//  google-music-mac
//
//  Created by Sajid Anwar on 23/02/2014.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import "PopoverDelegate.h"

@implementation PopoverDelegate

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
