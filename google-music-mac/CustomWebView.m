/*
 * CustomWebView.m
 *
 * Originally created by James Fator. Modified by Sajid Anwar.
 *
 * Swipe tracking code per Oscar Del Ben:
 * https://github.com/oscardelben/CocoaNavigationGestures
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "CustomWebView.h"

@implementation CustomWebView

@synthesize appDelegate;
@synthesize swipeView;

- (void)awakeFromNib
{
    swipeView = [[SwipeView alloc] initWithFrame:self.frame];
    [swipeView setWebView:self];
    [self setWantsLayer:YES];
    [self addSubview:swipeView];
}

@end