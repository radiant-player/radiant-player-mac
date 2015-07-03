/*
 * TitleBarTextView.m
 *
 * Created by Sajid Anwar.
 * Many thanks to @iTroyd23 for the concept.
 * http://stackoverflow.com/questions/20016022/how-to-change-color-of-nswindow-title-bar-in-osx
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "TitleBarTextView.h"

@implementation TitleBarTextView

@synthesize title;
@synthesize color = _color;

- (void)drawRect:(NSRect)dirtyRect
{    
    // Get the frame of the title bar (the window frame, subtracting the content bounds).
    NSRect windowFrame = self.window.frame;
    NSRect contentBounds = [self.window.contentView bounds];
    NSRect titleBounds = NSMakeRect(0, 0, windowFrame.size.width, windowFrame.size.height - contentBounds.size.height);
    titleBounds.origin.y = windowFrame.size.height - titleBounds.size.height;
    titleBounds.size.height -= 2;
    
    // Get the color (or the default).
    NSColor *textColor = _color;
    
    if (textColor == nil)
        textColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
    
    // Center the text.
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [style setAlignment:NSCenterTextAlignment];
    
    // Form the attributes dictionary.
    NSDictionary *attributes = @{
        NSParagraphStyleAttributeName: style,
        NSForegroundColorAttributeName: textColor,
        NSFontAttributeName: [NSFont systemFontOfSize:13]
    };
    
    // Draw the string.
    [title drawInRect:titleBounds withAttributes:attributes];
}

- (NSColor *)color
{
    return _color;
}

- (void)setColor:(NSColor *)color
{
    _color = color;
    [self setNeedsDisplay:YES];
}

@end
