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

#import "DDHidEvent.h"


@implementation DDHidEvent

+ (DDHidEvent *) eventWithIOHIDEvent: (IOHIDEventStruct *) event;
{
    return [[[self alloc] initWithIOHIDEvent: event] autorelease];
}

- (id) initWithIOHIDEvent: (IOHIDEventStruct *) event;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mEvent = *event;
    
    return self;
}

- (IOHIDElementType) type;
{
    return mEvent.type;
}

- (IOHIDElementCookie) elementCookie;
{
    return mEvent.elementCookie;
}

- (unsigned) elementCookieAsUnsigned;
{
    return (unsigned) mEvent.elementCookie;
}

- (SInt32) value;
{
    return mEvent.value;
}

- (AbsoluteTime) timestamp;
{
    return mEvent.timestamp;
}

- (UInt32) longValueSize;
{
    return mEvent.longValueSize;
}

- (void *) longValue;
{
    return mEvent.longValue;
}

@end
