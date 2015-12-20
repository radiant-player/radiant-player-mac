/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "NSDictionary+DDHidExtras.h"


@implementation NSDictionary (DDHidExtras)

- (unsigned) ddhid_unsignedForKey: (NSString *) key;
{
    NSNumber * number = [self objectForKey: key];
    return [number unsignedIntValue];
}

- (id) ddhid_objectForString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithUTF8String: key];
    return [self objectForKey: objcKey];
}

- (NSString *) ddhid_stringForString: (const char *) key;
{
    return [self ddhid_objectForString: key];
}

- (long) ddhid_longForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number longValue];
}

- (unsigned int) ddhid_unsignedIntForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number unsignedIntValue];
}

- (BOOL) ddhid_boolForString: (const char *) key;
{
    NSNumber * number =  [self ddhid_objectForString: key];
    return [number boolValue];
}

@end

@implementation NSMutableDictionary (DDHidExtras)

- (void) ddhid_setObject: (id) object forString: (const char *) key;
{
    NSString * objcKey = [NSString stringWithUTF8String: key];
    [self setObject: object forKey: objcKey];
}

- (void) ddhid_setInt: (int) i forKey: (id) key;
{
    NSNumber * number = [NSNumber numberWithInt: i];
    [self setObject: number forKey: key];
}

@end
