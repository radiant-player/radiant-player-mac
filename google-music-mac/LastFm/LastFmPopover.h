/*
 * LastFmPopover.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

#import "LastFmService.h"

@interface LastFmPopover : NSPopover<NSPopoverDelegate>

@property (retain) IBOutlet LastFmService *service;

- (void)refreshTracks;

@end
