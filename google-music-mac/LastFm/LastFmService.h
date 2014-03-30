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

#import "LastFmTrackTableCellView.h"

@interface LastFmService : NSObject<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, retain) NSMutableArray *tracks;
@property (retain) IBOutlet NSTableView *tracksTable;
@property (retain) IBOutlet NSProgressIndicator *loadProgress;

- (void)refreshTracks;

+ (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;
+ (void)sendNowPlaying:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;
+ (void)getRecentTracksWithLimit:(NSInteger)limit successHandler:(LastFmReturnBlockWithArray)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;

@end
