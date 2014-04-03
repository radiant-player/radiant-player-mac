/*
 * LastFmService.h
 *
 * Created by Sajid Anwar and Anant Narayanan.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import <LastFm/LastFm.h>
#import "LastFm+TrackInfo.h"

#import "LastFmTrackTableCellView.h"
#import "Utilities.h"

@interface LastFmService : NSObject<NSTableViewDelegate, NSTableViewDataSource> {
    NSMutableDictionary *_lovedStatus;
}

@property (nonatomic, retain) NSMutableArray *tracks;
@property (retain) IBOutlet NSTableView *tracksTable;
@property (retain) IBOutlet NSProgressIndicator *loadProgress;

- (void)refreshTracks;
- (IBAction)toggleTrackLovedStatus:(id)sender;
- (void)fetchTrackLovedStatus:(NSString *)track artist:(NSString *)artist sender:(LastFmTrackTableCellView *)sender;

- (IBAction)openRecentTracksPage:(id)sender;

+ (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;
+ (void)sendNowPlaying:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;
+ (void)getRecentTracksWithLimit:(NSInteger)limit successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;
+ (void)loveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;
+ (void)unloveTrack:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;
+ (void)getTrackInfo:(NSString *)title artist:(NSString *)artist successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;

@end
