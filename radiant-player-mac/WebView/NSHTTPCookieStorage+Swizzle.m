/*
 * NSHTTPCookieStorage+Swizzle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSHTTPCookieStorage+Swizzle.h"
#import "CookieStorage.h"

#include <objc/runtime.h>
#include <objc/objc.h>

@implementation NSHTTPCookieStorage (Swizzle)

void SwizzleInstanceMethods(Class class, SEL methodA, SEL methodB)
{
    Method originalMethod = class_getInstanceMethod(class, methodA);
    Method swizzledMethod = class_getInstanceMethod(class, methodB);

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

void SwizzleCookieStorageMethods(Class class)
{
    SwizzleInstanceMethods(class, @selector(deleteCookie:), @selector(rp_deleteCookie:));
    SwizzleInstanceMethods(class, @selector(cookieAcceptPolicy), @selector(rp_cookieAcceptPolicy));
    SwizzleInstanceMethods(class, @selector(setCookieAcceptPolicy:), @selector(rp_setCookieAcceptPolicy:));
    SwizzleInstanceMethods(class, @selector(cookies), @selector(rp_cookies));
    SwizzleInstanceMethods(class, @selector(cookiesForURL:), @selector(rp_cookiesForURL:));
    SwizzleInstanceMethods(class, @selector(sortedCookiesUsingDescriptors:), @selector(rp_sortedCookiesUsingDescriptors:));
    SwizzleInstanceMethods(class, @selector(setCookie:), @selector(rp_setCookie:));
    SwizzleInstanceMethods(class, @selector(setCookies:forURL:mainDocumentURL:), @selector(rp_setCookies:forURL:mainDocumentURL:));
}

+ (void)load
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cookies.use-safari"] == NO)
        {
            SwizzleCookieStorageMethods(self);
        }
    });
}

- (void)rp_deleteCookie:(NSHTTPCookie *)cookie
{
    return [[CookieStorage instance] deleteCookie:cookie];
}

- (NSHTTPCookieAcceptPolicy)rp_cookieAcceptPolicy
{
    return NSHTTPCookieAcceptPolicyAlways;
}

- (void)rp_setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)policy
{
    // We never need to change the accept policy from Always,
    // since we will always need the page to accept cookies.
}

- (NSArray *)rp_cookies
{
    return [[CookieStorage instance] cookies];
}

- (NSArray *)rp_cookiesForURL:(NSURL *)URL
{
    return [[CookieStorage instance] cookiesForURL:URL];
}

- (NSArray *)rp_sortedCookiesUsingDescriptors:(NSArray*)sortOrder
{
    return [[CookieStorage instance] sortedCookiesUsingDescriptors:sortOrder];
}

- (void)rp_setCookie:(NSHTTPCookie *)cookie
{
    [[CookieStorage instance] setCookie:cookie];
}

- (void)rp_setCookies:(NSArray *)cookies forURL:(NSURL *)URL mainDocumentURL:(NSURL *)mainDocumentURL
{
    [[CookieStorage instance] setCookies:cookies];
}


@end