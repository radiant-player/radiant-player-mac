//
//  CustomStatusView.h
//  google-music-mac
//
//  Created by Sajid Anwar on 23/02/2014.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomStatusView : NSView 

@property (retain) id globalMonitor;
@property (retain) NSPopover *popover;
@property (assign) BOOL active;

- (void)showPopover;
- (void)hidePopover;

@end
