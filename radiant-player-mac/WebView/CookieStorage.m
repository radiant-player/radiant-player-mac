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

+ (CookieStorage *)instance
{
    static dispatch_once_t onceToken;
    static CookieStorage *shared = nil;
    
    dispatch_once(&onceToken, ^{
        shared = [[CookieStorage alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _storage = [NSMutableArray array];
        _storagePath = [CookieStorage defaultCookieStoragePath];
        _policy = NSHTTPCookieAcceptPolicyAlways;
        
        [self unarchive];
    }
    
    return self;
}

- (void)deleteCookie:(NSHTTPCookie *)cookie
{
    [_storage removeObject:cookie];
}

- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy
{
    return _policy;
}

- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)policy
{
    _policy = policy;
}

- (void)setCookie:(NSHTTPCookie *)cookie
{
    NSString *domain = [[cookie domain] lowercaseString];
    NSString *path = [cookie path];
    NSString *name = [cookie name];
    
    // Find the existing cookie in the array if possible.
    for (int i = 0; i < _storage.count; i++)
    {
        NSHTTPCookie *cookie = [_storage objectAtIndex:i];
        
        // Check if the name, domain, and path matches.
        if ([name isEqualToString:[cookie name]] &&
            [domain isEqualToString:[cookie domain]] &&
            [path isEqualToString:[cookie path]])
        {
            // Remove the cookie.
            [_storage removeObjectAtIndex:i];
            break;
        }
    }
    
    // Add the cookie.
    [_storage addObject:cookie];
}

- (void)setCookies:(NSArray *)cookies
{
    for (NSHTTPCookie *cookie in cookies)
    {
        [self setCookie:cookie];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cookies.dont-save"] == NO)
    {
        [self archive];
    }
}

- (NSArray *)cookiesForURL:(NSURL *)url
{
    NSMutableArray *cookies = [NSMutableArray array];
    NSMutableArray *expired = [NSMutableArray array];
    
    for (NSHTTPCookie *cookie in [_storage copy])
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
        [_storage removeObject:cookie];
    }
    
    return cookies;
}

- (NSArray *)cookies
{
    return [NSArray arrayWithArray:_storage];
}

- (NSArray *)sortedCookiesUsingDescriptors:(NSArray *)sortOrder
{
    return [[self cookies] sortedArrayUsingDescriptors:sortOrder];
}

- (void)clearCookies
{
    // First remove all cookies from memory.
    [_storage removeAllObjects];
    
    // Delete the storage file.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_storagePath error:nil];
}

- (void)handleCookiesInRequest:(NSMutableURLRequest *)request
{
    NSArray *cookies = [self cookiesForURL:[request URL]];
    NSDictionary *fields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    for (NSString *header in fields) {
        [request setValue:[fields objectForKey:header] forHTTPHeaderField:header];
    }
}

- (void)handleCookiesInResponse:(NSHTTPURLResponse *)response
{
    NSDictionary *headers = [response allHeaderFields];
    [[CookieStorage instance] setCookies:[NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:[response URL]]];
}

#pragma mark - Serialization

- (BOOL)archive
{
    return [NSKeyedArchiver archiveRootObject:[_storage copy] toFile:_storagePath];
}
- (void)unarchive
{
    id unarchived;
    
    @try {
        unarchived = [NSKeyedUnarchiver unarchiveObjectWithFile:_storagePath];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not load cookies file: %@", exception);
    }
    
    if ([unarchived isKindOfClass:[NSArray class]])
    {
        [_storage addObjectsFromArray:unarchived];
    }
}

#pragma mark - Cookie Storage

+ (NSString *)defaultCookieStoragePath
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

#pragma mark - Miscellaneous

- (BOOL)isSierra
{
    return floor(NSAppKitVersionNumber) >= 1485;
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

@end
