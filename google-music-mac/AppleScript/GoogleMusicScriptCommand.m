//
//  GoogleMusicScriptCommand.m
//  google-music-mac
//
//  Created by Walter Da Col on 3/7/14.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import "GoogleMusicScriptCommand.h"
#import "AppDelegate.h"

@implementation GoogleMusicScriptCommand

/**
 Called when supported applescript are executed
 
 @see google-music-mac.sdef for all commands
 @return nothing for now
 */
- (id)performDefaultImplementation {
    // Retrive command
    NSString *o_command = [[self commandDescription] commandName];
    
    // Retrive command param
    //NSString *o_parameter = [self directParameter];
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([o_command isEqualToString:@"playpause"]){
        [delegate playPause:self];
    }
    if ([o_command isEqualToString:@"back track"]){
        [delegate backAction:self];
    }
    if ([o_command isEqualToString:@"next track"]){
        [delegate forwardAction:self];
    }
    if ([o_command isEqualToString:@"toggle thumbs up"]){
        [delegate toggleThumbsUp:self];
    }
    if ([o_command isEqualToString:@"toggle thumbs down"]){
        [delegate toggleThumbsDown:self];
    }
    if ([o_command isEqualToString:@"toggle shuffle"]){
        [delegate toggleShuffle:self];
    }
    if ([o_command isEqualToString:@"toggle repeatmode"]){
        [delegate toggleRepeatMode:self];
    }
    if ([o_command isEqualToString:@"toggle visualization"]){
        [delegate toggleVisualization:self];
    }
    
    return nil;
}
@end
