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
    // Refresh the Last.fm service history.
    [service refreshTracks];
}


@end
