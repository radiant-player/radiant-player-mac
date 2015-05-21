/*
 * UpdateChecker.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>

@interface UpdateChecker : NSObject

+ (NSDictionary *)latestReleaseFromGitHub:(NSString *)releaseChannel;
+ (NSString *)releaseChannel;
+ (NSString *)applicationVersion;
+ (BOOL)isVersionUpToDateWithApplication:(NSString *)appVersion latest:(NSString *)latest;
+ (BOOL)isApplicationUpToDate;

@end
