/*
 * CustomWebView.m
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

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
