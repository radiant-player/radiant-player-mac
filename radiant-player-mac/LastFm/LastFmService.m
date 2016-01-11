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
        _lovedStatus = [NSMutableDictionary dictionary];
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
            
            if (imageUrl)   [track setObject:[[NSImage alloc] initWithContentsOfURL:imageUrl] forKey:@"image"];
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
            else {
                [track setObject:[NSNumber numberWithBool:YES] forKey:@"now-playing"];
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

- (void)toggleTrackLovedStatus:(id)sender
{
    if ([[sender superview] isKindOfClass:[LastFmTrackTableCellView class]])
    {
        LastFmTrackTableCellView *trackView = (LastFmTrackTableCellView *)[sender superview];
        NSDictionary *track = [trackView trackData];
        
        NSString *title = [track objectForKey:@"title"];
        NSString *artist = [track objectForKey:@"artist"];
        NSString *path = [NSString stringWithFormat:@"%@/%@", title, artist];
        
        id loveSuccessHandler = ^(NSDictionary *result) {
            [_lovedStatus setObject:[NSNumber numberWithBool:YES] forKey:path];
        };
        
        id unloveSuccessHandler = ^(NSDictionary *result) {
            [_lovedStatus removeObjectForKey:path];
        };
        
        id failureHandler = ^(NSError *error) {
            [self fetchTrackLovedStatus:title artist:artist sender:trackView];
            NSLog(@"%@", error);
        };
        
        if ([[_lovedStatus objectForKey:path] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            // Track is already loved, so unlove it.
            [LastFmService unloveTrack:title artist:artist successHandler:unloveSuccessHandler failureHandler:failureHandler];
            [trackView.loveButton setImage:[Utilities imageFromName:@"heart-outline"]];
        }
        else {
            // Track is not loved.
            [LastFmService loveTrack:title artist:artist successHandler:loveSuccessHandler failureHandler:failureHandler];
            [trackView.loveButton setImage:[Utilities imageFromName:@"heart"]];
        }
    }
}

- (void)fetchTrackLovedStatus:(NSString *)track artist:(NSString *)artist sender:(LastFmTrackTableCellView *)sender
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", track, artist];
    NSNumber *loved = [_lovedStatus objectForKey:path];
    
    // Initially use the cached status.
    if (loved != nil) {
        if ([loved isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            [sender.loveButton setImage:[Utilities imageFromName:@"heart"]];
        }
        else {
            [sender.loveButton setImage:[Utilities imageFromName:@"heart-outline"]];
        }
    }
    
    id successHandler = ^(NSDictionary *result) {
        NSNumber *loved = [result objectForKey:@"userloved"];
        
        if ([loved isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            [_lovedStatus setObject:loved forKey:path];
            [sender.loveButton setImage:[Utilities imageFromName:@"heart"]];
        }
        else {
            [_lovedStatus removeObjectForKey:path];
            [sender.loveButton setImage:[Utilities imageFromName:@"heart-outline"]];
        }
    };
    
    id failureHandler = ^(NSError *error) {
        NSLog(@"%@", error);
    };
    
    [LastFmService getTrackInfo:track artist:artist successHandler:successHandler failureHandler:failureHandler];
}

- (void)openRecentTracksPage:(id)sender
{
    NSString *username = [[[LastFm sharedInstance] username] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *page = [NSString stringWithFormat:@"https://www.last.fm/user/%@", username];
    NSURL *url = [NSURL URLWithString:page];
    
    [[NSWorkspace sharedWorkspace] openURL:url];
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
        NSImage *image = [track objectForKey:@"image"];
        NSDate *date = [track objectForKey:@"date"];
        NSString *dateString = @"";
        
        if (artist == nil)  artist = @"Unknown Artist";
        if (album == nil)   album = @"Unknown Album";
        
        if (date != nil) {
            dateString = [date timeAgoSimple];
        }
        else {
            if ([track objectForKey:@"now-playing"] == [NSNumber numberWithBool:YES]) {
                dateString = @"▶";
            }
        }
        
        // Set up the track view.
        [view setTrackData:[track copy]];
        [view.titleView setStringValue:title];
        [view.artistAlbumView setStringValue:[NSString stringWithFormat:@"%@ - %@", artist, album]];
        [view.timestampView setStringValue:dateString];
        [view.artView setImage:image];
        
        // Get the track's loved status.
        [view.loveButton setImage:[Utilities imageFromName:@"heart-outline"]];
        [self fetchTrackLovedStatus:title artist:artist sender:view];
        
        return view;
    }
    
    return nil;
}

+ (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp percentage:(NSString *)percentage
{
    NSTimeInterval curTimestamp = [[NSDate date] timeIntervalSince1970];

    long percent = [percentage integerValue];
    long scrobbleAt = (duration / 100) * percent;

    /*NSLog(@"scrobbleAt: %ld", scrobbleAt);
    NSLog(@"curTimestamp: %f", curTimestamp);
    NSLog(@"timestamp: %f", timestamp);
    NSLog(@"curTimestamp - timestamp: %f", curTimestamp - timestamp);*/
    
    if ([title length] && curTimestamp - timestamp >= scrobbleAt) {
        NSLog(@"Song scrobbled");
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

+ (void)loveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler
{
    [[LastFm sharedInstance] loveTrack:title artist:artist successHandler:successHandler failureHandler:failureHandler];
}

+ (void)unloveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler
{
    [[LastFm sharedInstance] unloveTrack:title artist:artist successHandler:successHandler failureHandler:failureHandler];
}

+ (void)getTrackInfo:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler
{
    [[LastFm sharedInstance] getInfoForTrack:title artist:artist username:nil successHandler:successHandler failureHandler:failureHandler];
}

@end
