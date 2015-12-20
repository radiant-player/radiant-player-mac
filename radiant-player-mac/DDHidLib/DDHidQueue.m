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

#import "DDHidQueue.h"
#import "DDHidElement.h"
#import "DDHIdEvent.h"
#import "NSXReturnThrowError.h"

static void queueCallbackFunction(void* target,  IOReturn result, void* refcon,
                                  void* sender);

@interface DDHidQueue (Private)

- (void) handleQueueCallback;

@end

@implementation DDHidQueue

- (id) initWithHIDQueue: (IOHIDQueueInterface **) queue
                   size: (unsigned) size;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mQueue = queue;
    IOReturn result = (*mQueue)->create(mQueue, 0, size);
    if (result != kIOReturnSuccess)
    {
        [self release];
        return nil;
    }
     
    return self;
}

- (void) dealloc;
{
    [self stop];
    (*mQueue)->dispose(mQueue);
    (*mQueue)->Release(mQueue);
    [super dealloc];
}

- (void) addElement: (DDHidElement *) element;
{
    IOHIDElementCookie cookie = [element cookie];
    (*mQueue)->addElement(mQueue, cookie, 0);
}

- (void) addElements: (NSArray *) elements;
{
    return [self addElements: elements recursively: NO];
}

- (void) addElements: (NSArray *) elements recursively: (BOOL) recursively;
{
    NSEnumerator * e = [elements objectEnumerator];
    DDHidElement * element;
    while (element = [e nextObject])
    {
        [self addElement: element];
        if (recursively)
            [self addElements: [element elements]];
    }
}

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) startOnCurrentRunLoop;
{
    [self startOnRunLoop: [NSRunLoop currentRunLoop]];
}

- (void) startOnRunLoop: (NSRunLoop *) runLoop;
{
    if (mStarted)
        return;
    
    mRunLoop = [runLoop retain];
    
    NSXThrowError((*mQueue)->createAsyncEventSource(mQueue, &mEventSource));
    NSXThrowError((*mQueue)->setEventCallout(mQueue, queueCallbackFunction, self, NULL));
    CFRunLoopAddSource([mRunLoop getCFRunLoop], mEventSource,
                       kCFRunLoopDefaultMode);
    (*mQueue)->start(mQueue);
    mStarted = YES;
}

- (void) stop;
{
    if (!mStarted)
        return;
    
    CFRunLoopRemoveSource([mRunLoop getCFRunLoop], mEventSource, kCFRunLoopDefaultMode);
    (*mQueue)->stop(mQueue);
    [mRunLoop release];
    CFRelease(mEventSource);
    
    mRunLoop = nil;
    mStarted = NO;
}

- (BOOL) isStarted;
{
    return mStarted;
}

- (BOOL) getNextEvent: (IOHIDEventStruct *) event;
{
    AbsoluteTime zeroTime = {0, 0};
    IOReturn result = (*mQueue)->getNextEvent(mQueue, event, zeroTime, 0);
    return (result == kIOReturnSuccess);
}

- (DDHidEvent *) nextEvent;
{
    AbsoluteTime zeroTime = {0, 0};
    IOHIDEventStruct event;
    IOReturn result = (*mQueue)->getNextEvent(mQueue, &event, zeroTime, 0);
    if (result != kIOReturnSuccess)
        return nil;
    else
        return [DDHidEvent eventWithIOHIDEvent: &event];
}

@end

@implementation DDHidQueue (Private)

- (void) handleQueueCallback;
{
    if ([mDelegate respondsToSelector: @selector(ddhidQueueHasEvents:)])
    {
        [mDelegate ddhidQueueHasEvents: self];
    }
}

@end

static void queueCallbackFunction(void* target,  IOReturn result, void* refcon,
                                  void* sender)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDHidQueue * queue = (DDHidQueue *) target;
    [queue handleQueueCallback];
    [pool release];
    
}
