/*
 * Utilities.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "Utilities.h"

@implementation Utilities

+ (NSImage *)imageFromName:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"images/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"png"];
    
    return [[NSImage alloc] initWithContentsOfFile:path];
}

+ (NSData *)dataWithContentsOfPath:(NSString *)path
{
    NSString *location = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    return [NSData dataWithContentsOfFile:location];
}

/*
 * Many thanks to @Dov at Stack Overflow.
 * http://stackoverflow.com/a/6292308/406330
 *
 */
+ (NSImage *)templateImage:(NSString *)templateName withColor:(NSColor *)tint
{
    NSImage *template = [NSImage imageNamed:templateName];
    NSSize size = [template size];
    NSRect imageBounds = NSMakeRect(0, 0, size.width, size.height);
    
    NSImage *copiedImage = [template copy];
    [copiedImage setTemplate:NO];
    [copiedImage setSize:size];
    
    [copiedImage lockFocus];
    
    [tint set];
    NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
    
    [copiedImage unlockFocus];
    
    return copiedImage;
}

+ (NSString *)latestVersionFromGithub
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
                NSDictionary *latest = [releases firstObject];
                NSString *version = [latest objectForKey:@"name"];
                
                if ([version length] > 0)
                {
                    return [version substringFromIndex:1];
                }
                else
                {
                    NSLog(@"Unable to read version number of latest release from Github");
                    return nil;
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
    return [Utilities isVersionUpToDateWithApplication:[Utilities applicationVersion] latest:[Utilities latestVersionFromGithub]];
}

+ (NSString *)applicationHomepage
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApplicationHomepage"];
}

+ (NSString *)applicationName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApplicationName"];
}

@end
