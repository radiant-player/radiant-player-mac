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

@interface LastFmService : NSObject

+ (void)scrobbleSong:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;
+ (void)sendNowPlaying:(NSString *)title withArtist:(NSString *)artist album:(NSString *)album duration:(NSTimeInterval)duration timestamp:(NSTimeInterval)timestamp;

@end
