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

#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>

@class DDHidUsage;
@class DDHidElement;
@class DDHidQueue;

@interface DDHidDevice : NSObject
{
    io_object_t mHidDevice;
	IOHIDDeviceInterface122** mDeviceInterface;

    NSMutableDictionary * mProperties;
    DDHidUsage * mPrimaryUsage;
    NSMutableArray * mUsages;
    NSArray * mElements;
    NSMutableDictionary * mElementsByCookie;
    BOOL mListenInExclusiveMode;
    DDHidQueue * mDefaultQueue;
    int mTag;
    int mLogicalDeviceNumber;
}

- (id) initWithDevice: (io_object_t) device error: (NSError **) error;
- (id) initLogicalWithDevice: (io_object_t) device
         logicalDeviceNumber: (int) logicalDeviceNumber
                       error: (NSError **) error;
- (int) logicalDeviceCount;

#pragma mark -
#pragma mark Finding Devices

+ (NSArray *) allDevices;

+ (NSArray *) allDevicesMatchingUsagePage: (unsigned) usagePage
                                  usageId: (unsigned) usageId
                                withClass: (Class) hidClass
                        skipZeroLocations: (BOOL) emptyLocation;

+ (NSArray *) allDevicesMatchingCFDictionary: (CFDictionaryRef) matchDictionary
                                   withClass: (Class) hidClass
                           skipZeroLocations: (BOOL) emptyLocation;

#pragma mark -
#pragma mark I/O Kit Objects

- (io_object_t) ioDevice;
- (IOHIDDeviceInterface122**) deviceInterface;

#pragma mark -
#pragma mark Operations

- (void) open;
- (void) openWithOptions: (UInt32) options;
- (void) close;
- (DDHidQueue *) createQueueWithSize: (unsigned) size;
- (long) getElementValue: (DDHidElement *) element;

#pragma mark -
#pragma mark Asynchronous Notification

- (BOOL) listenInExclusiveMode;
- (void) setListenInExclusiveMode: (BOOL) flag;

- (void) startListening;

- (void) stopListening;

- (BOOL) isListening;

#pragma mark -
#pragma mark Properties

- (NSDictionary *) properties;

- (NSArray *) elements;
- (DDHidElement *) elementForCookie: (IOHIDElementCookie) cookie;

- (NSString *) productName;
- (NSString *) manufacturer;
- (NSString *) serialNumber;
- (NSString *) transport;
- (long) vendorId;
- (long) productId;
- (long) version;
- (long) locationId;
- (long) usagePage;
- (long) usage;
- (DDHidUsage *) primaryUsage;
- (NSArray *) usages;

- (NSComparisonResult) compareByLocationId: (DDHidDevice *) device;

- (int) tag;
- (void) setTag: (int) theTag;

@end

@interface DDHidDevice (Protected)

- (unsigned) sizeOfDefaultQueue;
- (void) addElementsToDefaultQueue;

@end
