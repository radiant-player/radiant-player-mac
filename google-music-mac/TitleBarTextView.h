/*
 * TitleBarTextView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface TitleBarTextView : NSView {
    NSColor *_color;
}

@property (retain) NSString *title;
@property (retain) NSColor *color;

@end
