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

#import "DDHidUsageTables.h"

@implementation DDHidUsageTables

static DDHidUsageTables * sStandardUsageTables = nil;

+ (DDHidUsageTables *) standardUsageTables;
{
    if (sStandardUsageTables == nil)
    {
        NSBundle * myBundle = [NSBundle bundleForClass: self];
        NSString * usageTablesPath =
            [myBundle pathForResource: @"DDHidStandardUsages" ofType: @"plist"];
        NSDictionary * lookupTables =
            [NSDictionary dictionaryWithContentsOfFile: usageTablesPath];
        sStandardUsageTables =
            [[DDHidUsageTables alloc] initWithLookupTables: lookupTables];
        [sStandardUsageTables retain];
    }
    
    return sStandardUsageTables;
}

- (id) initWithLookupTables: (NSDictionary *) lookupTables;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mLookupTables = [lookupTables retain];
    
    return self;
}

- (NSString *) descriptionForUsagePage: (unsigned) usagePage
                                usage: (unsigned) usage
{
    NSString * usagePageString = [NSString stringWithFormat: @"%u", usagePage];
    NSString * usageString = [NSString stringWithFormat: @"%u", usage];
    // NSNumber * usagePageNumber = [NSNumber numberWithUnsignedInt: usagePage];
    
    NSDictionary * usagePageLookup = [mLookupTables objectForKey: usagePageString];
    if (usagePageLookup == nil)
        return @"Unknown usage page";
    
    NSDictionary * usageLookup = [usagePageLookup objectForKey: @"usages"];
    NSString * description = [usageLookup objectForKey: usageString];
    if (description != nil)
        return description;
    
    NSString * defaultUsage = [usagePageLookup objectForKey: @"default"];
    if (defaultUsage != nil)
    {
        description = [NSString stringWithFormat: defaultUsage, usage];
        return description;
    }
    
    return @"Unknown usage";
}

@end
