/*
 * LastFm+TrackInfo.m
 *
 * Adds extra methods to the LastFm class.
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "LastFm+TrackInfo.h"

@implementation LastFm (TrackInfo)

/**
 *  Gets info for the track in the context of the username.
 *
 *  @param title          Track title
 *  @param artist         Track artist
 *  @param username       Username context (nil for current user)
 *  @param successHandler
 *  @param failureHandler
 *
 *  @return
 */
- (NSOperation *)getInfoForTrack:(NSString *)title artist:(NSString *)artist username:(NSString *)username successHandler:(LastFmReturnBlockWithDictionary)successHandler failureHandler:(LastFmReturnBlockWithError)failureHandler
{
    NSDictionary *mappingObject = @{
                                    @"name": @[ @"./name", @"NSString" ],
                                    @"listeners": @[ @"./listeners", @"NSNumber" ],
                                    @"playcount": @[ @"./playcount", @"NSNumber" ],
                                    @"tags": @[ @"./toptags/tag/name", @"NSArray" ],
                                    @"artist": @[ @"./artist/name", @"NSString" ],
                                    @"album": @[ @"./album/title", @"NSString" ],
                                    @"image": @[ @"./album/image[@size=\"large\"]", @"NSURL" ],
                                    @"wiki": @[ @"./wiki/summary", @"NSString" ],
                                    @"duration": @[ @"./duration", @"NSNumber" ],
                                    @"userplaycount": @[ @"./userplaycount", @"NSNumber" ],
                                    @"userloved": @[ @"./userloved", @"NSNumber" ],
                                    @"url": @[ @"./url", @"NSURL" ]
                                    };
    
    NSString *un = username ? [self forceString:username] : [self forceString:self.username];
    
    return [self performApiCallForMethod:@"track.getInfo"
                                useCache:NO
                              withParams:@{ @"track": [self forceString:title], @"artist": [self forceString:artist], @"username": un }
                               rootXpath:@"./track"
                        returnDictionary:YES
                           mappingObject:mappingObject
                          successHandler:successHandler
                          failureHandler:failureHandler];
}

@end
