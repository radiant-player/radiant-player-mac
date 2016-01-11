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

#import "DDHidUsage.h"
#import "DDHidUsageTables.h"

@implementation DDHidUsage

+ (DDHidUsage *) usageWithUsagePage: (unsigned) usagePage
                            usageId: (unsigned) usageId;
{
    return [[[self alloc] initWithUsagePage: usagePage usageId: usageId]
        autorelease];
}

- (id) initWithUsagePage: (unsigned) usagePage
                 usageId: (unsigned) usageId;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUsagePage = usagePage;
    mUsageId = usageId;
    
    return self;
}

- (unsigned) usagePage;
{
    return mUsagePage;
}

- (unsigned) usageId;
{
    return mUsageId;
}

- (NSString *) usageName;
{
    DDHidUsageTables * usageTables = [DDHidUsageTables standardUsageTables];
    return
        [usageTables descriptionForUsagePage: mUsagePage
                                       usage: mUsageId];
}

- (NSString *) usageNameWithIds;
{
    return [NSString stringWithFormat: @"%@ (0x%04x : 0x%04x)",
        [self usageName], mUsagePage, mUsageId];
}

- (NSString *) description;
{
    return [NSString stringWithFormat: @"HID Usage: %@", [self usageName]];
}

- (BOOL) isEqualToUsagePage: (unsigned) usagePage usageId: (unsigned) usageId;
{
    return ((mUsagePage == usagePage) && (mUsageId == usageId));
}

@end
