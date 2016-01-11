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

#import "DDHidAppleMikey.h"
#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"
#include <IOKit/hid/IOHIDUsageTables.h>

#define APPLE_MIC_ONLY 1

@interface DDHidAppleMikey (DDHidAppleMikeyDelegate)

- (void) ddhidAppleMikey: (DDHidAppleMikey *) mikey
               press: (unsigned) usageId
                upOrDown:(BOOL)upOrDown;

@end

@interface DDHidAppleMikey (Private)

- (void) initPressElements: (NSArray *) elements;
- (void) ddhidQueueHasEvents: (DDHidQueue *) hidQueue;

@end

@implementation DDHidAppleMikey

+ (NSArray *) allMikeys;
{
    //add mikeys
    id a2 = [self allDevicesMatchingUsagePage:12 usageId:1 withClass:self skipZeroLocations:NO];
#if APPLE_MIC_ONLY
    a2 = [a2 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"productName == \"Apple Mikey HID Driver\""]];
#endif
    
    return a2;
}

- (id) initWithDevice: (io_object_t) device error: (NSError **) error_;
{
    self = [super initWithDevice: device error: error_];
    if (self == nil)
        return nil;
    
    mPressElements = [[NSMutableArray alloc] init];
    [self initPressElements: [self elements]];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mPressElements release];
    
    mPressElements = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Elements

- (NSArray *) pressElements;
{
    return mPressElements;
}

- (unsigned) numberOfKeys;
{
    return (unsigned)[mPressElements count];
}

- (void) addElementsToQueue: (DDHidQueue *) queue;
{
    [queue addElements: mPressElements];
}

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) addElementsToDefaultQueue;
{
    [self addElementsToQueue: mDefaultQueue];
}

@end

@implementation DDHidAppleMikey (DDHidAppleMikeyDelegate)

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned int)usageId upOrDown:(BOOL)upOrDown
{
    if ([mDelegate respondsToSelector: _cmd])
        [mDelegate ddhidAppleMikey: mikey press: usageId upOrDown:(BOOL)upOrDown];
}

@end

@implementation DDHidAppleMikey (Private)

- (void) initPressElements: (NSArray *) elements;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
//        unsigned usagePage = [[element usage] usagePage];
//        unsigned usageId = [[element usage] usageId];
//        if (usagePage == kHIDPage_KeyboardOrKeypad)
//        {
//            if ((usageId >= 0x04) && (usageId <= 0xA4) ||
//                (usageId >= 0xE0) && (usageId <= 0xE7))
            {
                [mPressElements addObject: element];
            }
//        }
        NSArray * subElements = [element elements];
        if (subElements != nil)
            [self initPressElements: subElements];
    }
}

- (void) ddhidQueueHasEvents: (DDHidQueue *) hidQueue;
{
    DDHidEvent * event;
    while ((event = [hidQueue nextEvent]))
    {
        DDHidElement * element = [self elementForCookie: [event elementCookie]];
        unsigned usageId = [[element usage] usageId];
        SInt32 value = [event value];
        [self ddhidAppleMikey:self press:usageId upOrDown:value==1];
    }
}

@end
