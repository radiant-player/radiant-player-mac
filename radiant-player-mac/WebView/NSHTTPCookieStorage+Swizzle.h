/*
 * NSHTTPCookieStorage+Swizzle.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>

@interface NSHTTPCookieStorage (Swizzle)

- (void)rp_deleteCookie:(NSHTTPCookie *)cookie;
- (NSHTTPCookieAcceptPolicy)rp_cookieAcceptPolicy;
- (void)rp_setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)policy;
- (NSArray *)rp_cookies;
- (NSArray *)rp_cookiesForURL:(NSURL *)URL;
- (NSArray *)rp_sortedCookiesUsingDescriptors:(NSArray*)sortOrder;
- (void)rp_setCookie:(NSHTTPCookie *)cookie;
- (void)rp_setCookies:(NSArray *)cookies forURL:(NSURL *)URL mainDocumentURL:(NSURL *)mainDocumentURL;

@end
