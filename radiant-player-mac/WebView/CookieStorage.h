/*
 * CookieStorage.h
 *
 * Created by Sajid Anwar. Much thanks to Sasmito Adibowo.
 * http://cutecoder.org/programming/implementing-cookie-storage/
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <WebKit/WebKit.h>

@interface CookieStorage : NSObject {
    NSMutableArray *_storage;
    NSString *_storagePath;
    NSHTTPCookieAcceptPolicy _policy;
}

+ (CookieStorage *)instance;

// Mimic the parts of the NSHTTPCookieStorage interface that we need.
- (void)deleteCookie:(NSHTTPCookie *)cookie;
- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;
- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)policy;
- (NSArray *)cookies;
- (NSArray *)cookiesForURL:(NSURL *)URL;
- (NSArray *)sortedCookiesUsingDescriptors:(NSArray*)sortOrder;
- (void)setCookie:(NSHTTPCookie *)cookie;
- (void)setCookies:(NSArray *)cookies;

// HTTP request/response handling.
- (void)handleCookiesInRequest:(NSMutableURLRequest *)request;
- (void)handleCookiesInResponse:(NSHTTPURLResponse *)response;

- (BOOL)archive;
- (void)unarchive;
- (void)clearCookies;

+ (NSString *)defaultCookieStoragePath;

@end
