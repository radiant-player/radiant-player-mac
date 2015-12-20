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

// Based on Martin Kahr's Apple Remote wrapper
// http://www.martinkahr.com/source-code/

#import "DDHidAppleRemote.h"
#import "DDHidElement.h"
#import "DDHidUsage.h"
#import "DDHidQueue.h"
#import "DDHidEvent.h"
#import "NSDictionary+DDHidExtras.h"

@interface DDHidAppleRemote (Private)

- (void) initRemoteElements: (NSArray *) elements;

- (void) ddhidQueueHasEvents: (DDHidQueue *) hidQueue;

- (void) handleEventWithCookieString: (NSString*) cookieString
                         sumOfValues: (SInt32) sumOfValues;

@end

@implementation DDHidAppleRemote

+ (NSArray *) allRemotes;
{
    CFMutableDictionaryRef hidMatchDictionary =
        IOServiceMatching("AppleIRController");
    
    return
        [DDHidDevice allDevicesMatchingCFDictionary: hidMatchDictionary
                                          withClass: self
                                  skipZeroLocations: YES];
}

+ (DDHidAppleRemote *) firstRemote;
{
    NSArray * allRemotes = [self allRemotes];
    if ([allRemotes count] > 0)
        return [allRemotes objectAtIndex: 0];
    else
        return nil;
}

- (id) initWithDevice: (io_object_t) device error: (NSError **) error_;
{
    self = [super initWithDevice: device error: error_];
    if (self == nil)
        return nil;
    
    mCookieToButtonMapping = [[NSMutableDictionary alloc] init];
    
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonVolume_Plus
                                  forKey: @"14_12_11_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonVolume_Plus
                                  forKey: @"31_29_28_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonVolume_Minus
                                  forKey: @"14_13_11_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonVolume_Minus
                                  forKey: @"31_30_28_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonMenu
                                  forKey: @"14_7_6_5_14_7_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonMenu
                                  forKey: @"31_20_19_18_31_20_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlay
                                  forKey: @"14_8_6_5_14_8_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlay
                                  forKey: @"31_21_19_18_31_21_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonRight
                                  forKey: @"14_9_6_5_14_9_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonRight
                                  forKey: @"31_22_19_18_31_22_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonLeft
                                  forKey: @"14_10_6_5_14_10_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonLeft
                                  forKey: @"31_23_19_18_31_23_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonRight_Hold
                                  forKey: @"14_6_5_4_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonRight_Hold
                                  forKey: @"31_19_18_4_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonLeft_Hold
                                  forKey: @"14_6_5_3_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonLeft_Hold
                                  forKey: @"31_19_18_3_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonMenu_Hold
                                  forKey: @"14_6_5_14_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonMenu_Hold
                                  forKey: @"31_19_18_31_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlay_Sleep
                                  forKey: @"18_14_6_5_18_14_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlay_Sleep
                                  forKey: @"35_31_19_18_35_31_19_18_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteControl_Switched
                                  forKey: @"19_"];
    //[mCookieToButtonMapping ddhid_setInt: kDDHidRemoteControl_Switched
    //                              forKey: @"??_"]; // unknown for 10.5
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteControl_Paired
                                  forKey: @"15_14_6_5_15_14_6_5_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteControl_Paired
                                  forKey: @"32_31_19_18_32_31_19_18_"];
    
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonVolume_Plus
                                  forKey: @"33_31_30_21_20_2_"];
    [mCookieToButtonMapping ddhid_setInt:kDDHidRemoteButtonVolume_Minus
                                  forKey:@"33_32_30_21_20_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonRight
                                  forKey:@"33_24_21_20_2_33_24_21_20_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonLeft
                                  forKey:@"33_25_21_20_2_33_25_21_20_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlay
                                  forKey:@"33_21_20_3_2_33_21_20_3_2_"]; // center
                                                                         // button
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonMenu
                                  forKey:@"33_22_21_20_2_33_22_21_20_2_"];
    [mCookieToButtonMapping ddhid_setInt: kDDHidRemoteButtonPlayPause
                                  forKey:@"33_21_20_8_2_33_21_20_8_2_"];

    [self initRemoteElements: [self elements]];
    
    
    return self;
}

//===========================================================
// dealloc
//===========================================================
- (void) dealloc
{
    [mCookieToButtonMapping release];
    [mButtonElements release];
    [mIdElement release];
    
    mCookieToButtonMapping = nil;
    mButtonElements = nil;
    mIdElement = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Asynchronous Notification

- (void) setDelegate: (id) delegate;
{
    mDelegate = delegate;
}

- (void) addElementsToDefaultQueue;
{
    [mDefaultQueue addElements: mButtonElements];
}

#pragma mark -
#pragma mark Properties

//=========================================================== 
//  remoteId 
//=========================================================== 
- (int) remoteId
{
    return mRemoteId;
}

- (void) setRemoteId: (int) theRemoteId
{
    mRemoteId = theRemoteId;
}

@end

@implementation DDHidAppleRemote (Private)

- (void) initRemoteElements: (NSArray *) elements;
{
    NSAssert([elements count] == 1, @"Assume only 1 top level remote element");
    DDHidElement * consumerControlsElement = [elements objectAtIndex: 0];
    mButtonElements = [[consumerControlsElement elements] retain];
    DDHidElement * element;
    NSEnumerator * e = [mButtonElements objectEnumerator];
    while (element = [e nextObject])
    {
        if ([[element usage] isEqualToUsagePage: 0x0006
                                        usageId: 0x0022])
        {
            mIdElement = [element retain];
        }
    }
}

- (void) ddhidQueueHasEvents: (DDHidQueue *) hidQueue;
{
	NSMutableString * cookieString = [NSMutableString string];
	SInt32 sumOfValues = 0;

    DDHidEvent * event;
    while ((event = [hidQueue nextEvent]))
    {
        if ([event elementCookie] == [mIdElement cookie])
        {
            [self setRemoteId: [event value]];
        }
        else
        {
            sumOfValues += [event value];
            [cookieString appendString:
                [NSString stringWithFormat: @"%u_", [event elementCookieAsUnsigned]]];
        }
    }
    [self handleEventWithCookieString: cookieString sumOfValues: sumOfValues];	
}

- (void) handleEventWithCookieString: (NSString*) cookieString
                         sumOfValues: (SInt32) sumOfValues;
{
	NSNumber* buttonId = [mCookieToButtonMapping objectForKey: cookieString];
	if (buttonId != nil)
    {
		if ([mDelegate respondsToSelector: @selector(ddhidAppleRemoteButton:pressedDown:)])
        {
			[mDelegate ddhidAppleRemoteButton: [buttonId intValue]
                                 pressedDown: (sumOfValues>0)];
		}
	}
    else
		NSLog(@"Unknown button for cookiestring %@", cookieString);

}

@end

