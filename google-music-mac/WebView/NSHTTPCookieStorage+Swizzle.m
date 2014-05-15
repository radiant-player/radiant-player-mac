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

void SwizzleInstanceMethods(SEL method)
{
    Class a = [NSHTTPCookieStorage class];
    Class b = [CookieStorage class];
    Method originalMethod = class_getInstanceMethod(a, method);
    Method swizzledMethod = class_getInstanceMethod(b, method);

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        SwizzleInstanceMethods(@selector(init));
        SwizzleInstanceMethods(@selector(_initWithCFHTTPCookieStorage:));
        SwizzleInstanceMethods(@selector(cookieAcceptPolicy));
        SwizzleInstanceMethods(@selector(setCookieAcceptPolicy:));
        SwizzleInstanceMethods(@selector(cookies));
        SwizzleInstanceMethods(@selector(cookiesForURL:));
        SwizzleInstanceMethods(@selector(sortedCookiesUsingDescriptors:));
        SwizzleInstanceMethods(@selector(setCookie:));
        SwizzleInstanceMethods(@selector(setCookies:forURL:mainDocumentURL:));
    });
}

@end