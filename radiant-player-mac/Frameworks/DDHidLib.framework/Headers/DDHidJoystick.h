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
#import "DDHidDevice.h"

@class DDHidElement;
@class DDHidQueue;

@interface DDHidJoystickStick : NSObject
{
    DDHidElement * mXAxisElement;
    DDHidElement * mYAxisElement;
    NSMutableArray * mStickElements;
    // Point of view elements (i.e. hat switches)
    NSMutableArray * mPovElements;
}

- (DDHidElement *) xAxisElement;

- (DDHidElement *) yAxisElement;

#pragma mark -
#pragma mark StickElements - indexed accessors

- (unsigned int) countOfStickElements;
- (DDHidElement *) objectInStickElementsAtIndex: (unsigned int)index;

#pragma mark -
#pragma mark PovElements - indexed accessors

- (unsigned int) countOfPovElements;
- (DDHidElement *) objectInPovElementsAtIndex: (unsigned int)index;

- (NSArray *) allElements;

-  (BOOL) addElement: (DDHidElement *) element;

@end

@interface DDHidJoystick : DDHidDevice
{
    NSMutableArray * mSticks;
    NSMutableArray * mButtonElements;
    NSMutableArray * mLogicalDeviceElements;

    id mDelegate;
}

+ (NSArray *) allJoysticks;

- (id) initLogicalWithDevice: (io_object_t) device 
         logicalDeviceNumber: (int) logicalDeviceNumber 
                       error: (NSError **) error;

- (int) logicalDeviceCount;

#pragma mark -
#pragma mark Joystick Elements

- (unsigned) numberOfButtons;

- (NSArray *) buttonElements;

#pragma mark -
#pragma mark Sticks - indexed accessors

- (unsigned int) countOfSticks;
- (DDHidJoystickStick *) objectInSticksAtIndex: (unsigned int)index;

- (void) addElementsToQueue: (DDHidQueue *) queue;

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;

- (void) addElementsToDefaultQueue;

@end

#define DDHID_JOYSTICK_VALUE_MIN -65536
#define DDHID_JOYSTICK_VALUE_MAX 65536

@interface NSObject (DDHidJoystickDelegate)

- (void) ddhidJoystick: (DDHidJoystick *) joystick
                 stick: (unsigned) stick
              xChanged: (int) value;

- (void) ddhidJoystick: (DDHidJoystick *) joystick
                 stick: (unsigned) stick
              yChanged: (int) value;

- (void) ddhidJoystick: (DDHidJoystick *) joystick
                 stick: (unsigned) stick
             otherAxis: (unsigned) otherAxis
          valueChanged: (int) value;

- (void) ddhidJoystick: (DDHidJoystick *) joystick
                 stick: (unsigned) stick
             povNumber: (unsigned) povNumber
          valueChanged: (int) value;

- (void) ddhidJoystick: (DDHidJoystick *) joystick
            buttonDown: (unsigned) buttonNumber;

- (void) ddhidJoystick: (DDHidJoystick *) joystick
              buttonUp: (unsigned) buttonNumber;

@end
