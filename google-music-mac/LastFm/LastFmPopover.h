/*
 * LastFmPopover.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <LastFM/LastFm.h>

#import "LastFmService.h"

#define LASTFM_SIGN_IN_TAG 1

@interface LastFmPopover : NSPopover<NSPopoverDelegate>

@property (retain) IBOutlet LastFmService *service;

- (void)refreshTracks;

@end
