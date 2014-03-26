/*
 * RadiantPlayerScriptCommand.m
 *
 * Originally created by Walter Da Col.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "RadiantPlayerScriptCommand.h"
#import "AppDelegate.h"

@implementation RadiantPlayerScriptCommand

/**
 Called when supported AppleScript are executed
 
 @see google-music-mac.sdef for all commands
 @return nothing for now
 */
- (id)performDefaultImplementation
{
    // Retrieve command
    NSString *command = [[self commandDescription] commandName];
    
    // Retrieve command param
    //NSString *parameter = [self directParameter];
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([command isEqualToString:@"playpause"]){
        [delegate playPause:self];
    }
    else if ([command isEqualToString:@"back track"]){
        [delegate backAction:self];
    }
    else if ([command isEqualToString:@"next track"]){
        [delegate forwardAction:self];
    }
    else if ([command isEqualToString:@"toggle thumbs up"]){
        [delegate toggleThumbsUp:self];
    }
    else if ([command isEqualToString:@"toggle thumbs down"]){
        [delegate toggleThumbsDown:self];
    }
    else if ([command isEqualToString:@"toggle shuffle"]){
        [delegate toggleShuffle:self];
    }
    else if ([command isEqualToString:@"toggle repeatmode"]){
        [delegate toggleRepeatMode:self];
    }
    else if ([command isEqualToString:@"toggle visualization"]){
        [delegate toggleVisualization:self];
    }
    
    return nil;
}

@end
