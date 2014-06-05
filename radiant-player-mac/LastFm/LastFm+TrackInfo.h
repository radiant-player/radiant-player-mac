/*
 * LastFm+TrackInfo.h
 *
 * Adds extra methods to the LastFm class.
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "LastFm.h"

@interface LastFm (TrackInfo)

- (NSOperation *)getInfoForTrack:(NSString *)title artist:(NSString *)artist username:(NSString *)username successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler;

@end
