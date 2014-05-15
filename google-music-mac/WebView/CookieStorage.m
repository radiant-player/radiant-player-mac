/*
 * CookieStorage.m
 *
 * Created by Sajid Anwar. Much thanks to Sasmito Adibowo.
 * http://cutecoder.org/programming/implementing-cookie-storage/
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "CookieStorage.h"
#import "NSDate+UTCString.h"

@implementation CookieStorage

+ (void)load
{
    [CookieStorage unarchive];
}

- (id)init
{
    return self;
}

/*
 * This is our key, which overrides the private initializer
 * that accesses the global cookies. We make this do nothing,
 * so that we can handle everything about cookies ourselves.
 */
- (id)_initWithCFHTTPCookieStorage:(id)something {
    return [self init];
}

/*
 * We need cookies so there's no point for this to change.
 */
- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy
{
    return NSHTTPCookieAcceptPolicyAlways;
}

- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)cookieAcceptPolicy
{

}

- (void)deleteCookie:(NSHTTPCookie *)cookie
{
    [[CookieStorage storage] removeObject:cookie];
}

- (void)setCookie:(NSHTTPCookie *)cookie
{
    NSString *domain = [[cookie domain] lowercaseString];
    NSString *path = [cookie path];
    NSString *name = [cookie name];

    // Find the existing cookie in the array if possible.
    for (int i = 0; i < [CookieStorage storage].count; i++)
    {
	NSHTTPCookie *cookie = [[CookieStorage storage] objectAtIndex:i];

	// Check if the name, domain, and path matches.
	if ([name isEqualToString:[cookie name]] &&
	    [domain isEqualToString:[cookie domain]] &&
	    [path isEqualToString:[cookie path]])
	{
	    // Remove the cookie.
	    [[CookieStorage storage] removeObjectAtIndex:i];
	    break;
	}
    }

    // Add the cookie.
    [[CookieStorage storage] addObject:cookie];
}

- (void)setCookies:(NSArray *)cookies forURL:(NSURL *)URL mainDocumentURL:(NSURL *)mainDocumentURL
{
    for (NSHTTPCookie *cookie in cookies)
    {
	[self setCookie:cookie];
    }

    [CookieStorage archive];
}

- (NSArray *)cookiesForURL:(NSURL *)url
{
    NSMutableArray *cookies = [NSMutableArray array];
    NSMutableArray *expired = [NSMutableArray array];

    for (NSHTTPCookie *cookie in [CookieStorage storage])
    {
	NSString *domain = [cookie domain];
	NSString *path = [cookie path];

	if ([CookieStorage hostMatchesDomainWithURL:url domain:domain] == NO)
	    continue;

	if ([[url path] hasPrefix:path] == NO)
	    continue;

	// Queue removal of expired cookies.
	if ([cookie expiresDate] != nil && [[cookie expiresDate] isLessThan:[NSDate date]])
	{
	    [expired addObject:cookie];
	    continue;
	}

	// Only include secure cookies on HTTPS sites.
	if ([cookie isSecure] && [[url scheme] caseInsensitiveCompare:@"https"] != NSEqualToComparison)
	{
	    continue;
	}

	[cookies addObject:cookie];
    }

    // Remove the expired cookies.
    for (NSHTTPCookie *cookie in expired)
    {
	[[CookieStorage storage] removeObject:cookie];
    }

    return cookies;
}

- (NSArray *)cookies
{
    return [NSArray arrayWithArray:[CookieStorage storage]];
}

- (NSArray *)sortedCookiesUsingDescriptors:(NSArray *)sortOrder
{
    return [[self cookies] sortedArrayUsingDescriptors:sortOrder];
}

+ (BOOL)hostMatchesDomainWithURL:(NSURL *)url domain:(NSString *)domain
{
    // The domain must either match the host exactly, or it must
    // be a suffix that is preceded by a ".", for example:
    //
    //   www.example.com matches example.com
    //   www.example.com matches .example.com
    //   www.example.com does not match google.com
    //   someexample.com does not match example.com

    NSString *host = [[url host] lowercaseString];
    NSString *baseDomain = ([domain hasPrefix:@"."]) ? [domain substringFromIndex:1] : domain;

    if ([host isEqualToString:baseDomain])
	return YES;

    NSString *effectiveDomain = baseDomain;

    // Add the "." at the beginning if it doesn't exist.
    if ([effectiveDomain hasPrefix:@"."] == NO)
	effectiveDomain = [@"." stringByAppendingString:effectiveDomain];

    return [host hasSuffix:effectiveDomain];
}

#pragma mark - Serialization

+ (BOOL)archive
{
    NSString *path = [CookieStorage cookieStoragePath];
    return [NSKeyedArchiver archiveRootObject:[[CookieStorage storage] copy] toFile:path];
}

+ (void)unarchive
{
    NSString *path = [CookieStorage cookieStoragePath];
    id storage;

    @try {
	storage = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception) {
	NSLog(@"Could not load cookies file: %@", exception);
    }

    if ([storage isKindOfClass:[NSArray class]])
    {
	[[CookieStorage storage] addObjectsFromArray:storage];
    }
}

#pragma mark - Cookie Storage

/*
 * We need a singleton array here because method swizzling wouldn't allow us
 * to add instance variables to the NSHTTPCookieStorage class.
 */
+ (NSMutableArray *)storage
{
    static NSMutableArray *storageArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
	storageArray = [NSMutableArray array];
    });

    return storageArray;
}

+ (NSString *)cookieStoragePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *folder = [[paths firstObject] stringByAppendingPathComponent:@"Radiant Player"];

    if ([fileManager fileExistsAtPath:folder] == NO)
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return [folder stringByAppendingPathComponent:@"Cookies"];
}

+ (void)clearCookies
{
    // First remove all cookies from memory.
    [[CookieStorage storage] removeAllObjects];
    
    // Delete the storage file.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[CookieStorage cookieStoragePath] error:nil];
}

@end
