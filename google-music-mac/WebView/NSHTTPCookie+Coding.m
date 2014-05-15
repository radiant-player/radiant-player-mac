/*
 * NSHTTPCookie+Coding.m
 *
 * Created by Sajid Anwar. Much thanks to Sasmito Adibowo.
 * http://cutecoder.org/programming/implementing-cookie-storage/
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSHTTPCookie+Coding.h"

/*
 * Enable serialization of NSHTTPCookie objects.
 */

@implementation NSHTTPCookie (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *properties = [aDecoder decodeObjectForKey:@"properties"];

    // Make sure we actually were able to read something.
    if (properties == nil)
        return nil;

    return (self = [self initWithProperties:properties]);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Encode the cookie's properties.
    [aCoder encodeObject:[self properties] forKey:@"properties"];
}

@end
