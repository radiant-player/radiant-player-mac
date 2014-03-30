/*
 * LastFmService.h
 *
 * Created by Sajid Anwar and Anant Narayanan.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "LastFmService.h"

@implementation LastFmService

@synthesize tracks;
@synthesize tracksTable;
@synthesize loadProgress;

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        tracks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)refreshTracks
{
    [loadProgress startAnimation:self];
    
    id successHandler = ^(NSArray *result) {
        [tracks removeAllObjects];
        
        for (NSDictionary *trackResult in result)
        {
            NSURL *imageUrl = [trackResult objectForKey:@"image"];
            NSString *title = [trackResult objectForKey:@"name"];
            NSString *artist = [trackResult objectForKey:@"artist"];
            NSString *album = [trackResult objectForKey:@"album"];
            NSDate *date = [trackResult objectForKey:@"date"];
            
            NSMutableDictionary *track = [[NSMutableDictionary alloc] init];
            
            if (imageUrl)   [track setObject:imageUrl forKey:@"image"];
            if (title)      [track setObject:title forKey:@"title"];
            if (artist)     [track setObject:artist forKey:@"artist"];
            if (album)      [track setObject:album forKey:@"album"];
            if (date) {
                // Adjust the time to local.
                NSTimeZone *zone = [NSTimeZone localTimeZone];
                NSInteger seconds = [zone secondsFromGMTForDate:date];
                date = [NSDate dateWithTimeInterval:seconds sinceDate:date];
                [track setObject:date forKey:@"date"];
            }
            
            [tracks addObject:track];
        }
        
        [loadProgress performSelectorOnMainThread:@selector(stopAnimation:) withObject:self waitUntilDone:NO];
        [tracksTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    };
    
    id failureHandler = ^(NSError *error) {
        NSLog(@"%@", error);
        [loadProgress performSelectorOnMainThread:@selector(stopAnimation:) withObject:self waitUntilDone:NO];
    };
    
    [LastFmService getRecentTracksWithLimit:10 successHandler:successHandler failureHandler:failureHandler];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [tracks count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *track = [tracks objectAtIndex:row];
    
    if (track != nil)
    {
        LastFmTrackTableCellView *view = [tableView makeViewWithIdentifier:@"TrackCellView" owner:self];

        // Get the track details.
        NSString *title = [track objectForKey:@"title"];
        NSString *artist = [track objectForKey:@"artist"];
        NSString *album = [track objectForKey:@"album"];
        NSURL *imageUrl = [track objectForKey:@"image"];
        NSDate *date = [track objectForKey:@"date"];
        NSString *dateString = @"";
        
        if (artist == nil)  artist = @"Unknown Artist";
        if (album == nil)   album = @"Unknown Album";
        if (date != nil)    dateString = [date timeAgoSimple];
        
        // Set up the track view.
        [view.titleView setStringValue:title];
        [view.artistAlbumView setStringValue:[NSString stringWithFormat:@"%@ - %@", artist, album]];
        [view.timestampView setStringValue:dateString];
        //[view.artView setImage:[[NSImage alloc] initWithContentsOfURL:imageUrl]];
        
        return view;
    }
    
    return nil;
}

+ (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp
{
    NSTimeInterval curTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if ([title length] && curTimestamp - timestamp >= duration / 2) {
        [[LastFm sharedInstance] sendScrobbledTrack:title
                                           byArtist:artist
                                            onAlbum:album
                                       withDuration:duration
                                        atTimestamp:timestamp
                                     successHandler:^(NSDictionary *result) {
                                         return;
                                     }
                                     failureHandler:^(NSError *error) {
                                         NSLog(@"Error scrobbling song: %@, %@", error, [error userInfo]);
                                     }
         ];
    }
    
    
}

+ (void)sendNowPlaying:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp
{
    [[LastFm sharedInstance] sendNowPlayingTrack:title
                                        byArtist:artist
                                         onAlbum:album
                                    withDuration:duration
                                  successHandler:^(NSDictionary *result) {
                                      return;
                                  }
     
                                  failureHandler:^(NSError *error) {
                                      NSLog(@"Error sending now playing song: %@, %@", error, [error userInfo]);
                                  }
     ];
}

+ (void)getRecentTracksWithLimit:(NSInteger)limit successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;
{
    [[LastFm sharedInstance] getRecentTracksForUserOrNil:nil limit:limit successHandler:successHandler failureHandler:failureHandler];
}

@end
