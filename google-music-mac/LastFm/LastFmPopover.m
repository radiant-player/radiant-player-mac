/*
 * LastFmPopover.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "LastFmPopover.h"

@implementation LastFmPopover

@synthesize service;

- (id)init
{
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LastFmPopover class]) owner:self topLevelObjects:nil];
        [self setBehavior:NSPopoverBehaviorTransient];
    }
    
    return self;
}

- (void)refreshTracks
{
    // Make sure the user is signed in.
    if ([[LastFm sharedInstance] session] == nil) {
        // Hide everything but the warning message.
        for (NSView *view in [self.contentViewController.view subviews])
        {
            [view setHidden:([view tag] != LASTFM_SIGN_IN_TAG)];
        }
    }
    else {
        // Show everything but the warning message.
        for (NSView *view in [self.contentViewController.view subviews])
        {
            [view setHidden:([view tag] == LASTFM_SIGN_IN_TAG)];
        }
        
        // Refresh the Last.fm service history.
        [service refreshTracks];
    }
}


@end
