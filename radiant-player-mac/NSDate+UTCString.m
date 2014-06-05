/*
 * NSDate+UTCString.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSDate+UTCString.h"

@implementation NSDate (UTCString)

- (NSString *)toUTCString
{
    static NSDateFormatter *formatter = nil;
    
    if(formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [formatter setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
    }
    
    return [formatter stringFromDate:self];
}

@end
