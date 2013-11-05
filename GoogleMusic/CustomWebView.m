//
//  CustomWebView.m
//  Google Music
//
//  Created by James Fator on 10/7/13.
//  Copyright (c) 2013 James Fator. All rights reserved.
//

#import "CustomWebView.h"

@implementation CustomWebView

@synthesize appDelegate;

- (void)swipeWithEvent:(NSEvent *)event {
    CGFloat x = [event deltaX];
    if (x != 0) {
        if ( x > 0 ) {
            [self goForward];
        } else {
            [self goBack];
        }
    }
}

@end
