/*
 * UpdateChecker.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "UpdateChecker.h"
#import "ReleaseChannel.h"

@implementation UpdateChecker

+ (NSString *)latestVersionFromGithub:(NSString *)releaseChannel
{
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/repos/kbhomes/radiant-player-mac/releases"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data)
    {
        url = [NSURL URLWithString:@"https://api.github.com/repos/kbhomes/google-music-mac/releases"];
        data = [NSData dataWithContentsOfURL:url];
    }
    
    if (data)
    {
        id parsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([parsed isKindOfClass:[NSArray class]])
        {
            NSArray *releases = (NSArray *)parsed;
            
            if ([releases count] > 0)
            {
                for (NSDictionary *rel in releases)
                {
                    NSString *version = [rel objectForKey:@"name"];
                    
                    // Specific to this release chnnel, or is the stable channel (doesn't contain a -beta).
                    if ([version hasSuffix:releaseChannel] || ![version containsString:@"-"])
                    {
                        return [version substringFromIndex:1];
                    }
                }
            }
            else
            {
                NSLog(@"Unable to find any releases from Github");
                return nil;
            }
        }
        else
        {
            NSLog(@"Unable to process returned JSON from Github");
            return nil;
        }
    }
    else
    {
        NSLog(@"Unable to obtain response from Github");
        return nil;
    }
    
    return nil;
}

+ (NSString *)releaseChannel
{
    NSString *channel = [[NSUserDefaults standardUserDefaults] stringForKey:@"updates.channel"];
    
    if (!channel)
    {
        channel = CHANNEL_STABLE;
        [[NSUserDefaults standardUserDefaults] setObject:channel forKey:@"updates.channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return channel;
}

+ (NSString *)applicationVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isVersionUpToDateWithApplication:(NSString *)appVersionString latest:(NSString *)latestVersionString
{
    NSArray *appVersion = [appVersionString componentsSeparatedByString:@"."];
    NSArray *latestVersion = [latestVersionString componentsSeparatedByString:@"."];
    
    for (int i = 0; i < MAX([appVersion count], [latestVersion count]); i++) {
        NSInteger appComponent = (i >= [appVersion count]) ? 0 : [[appVersion objectAtIndex:i] integerValue];
        NSInteger latestComponent = (i >= [latestVersion count]) ? 0 : [[latestVersion objectAtIndex:i] integerValue];
        
        if (appComponent < latestComponent)
            return NO;
        else if (appComponent > latestComponent)
            return YES;
    }
    
    return YES;
}

+ (BOOL)isApplicationUpToDate
{
    NSString *channel = [UpdateChecker releaseChannel];
    NSString *latest = [UpdateChecker latestVersionFromGithub:channel];
    NSString *current = [UpdateChecker applicationVersion];
    
    return [UpdateChecker isVersionUpToDateWithApplication:current latest:latest];
}

@end
