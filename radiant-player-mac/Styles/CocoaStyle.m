/*
 * CocoaStyle.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "CocoaStyle.h"

@implementation CocoaStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Cocoa"];
        [self setAuthor:@"Sajid Anwar"];
        [self setDescription:@"An application style to match Mac OS X."];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.898f green:0.898f blue:0.898f alpha:1.0f]];
        [self setTitleColor:nil];
        [self setCss:[ApplicationStyle cssNamed:@"cocoa"]];
        [self setJs:[ApplicationStyle jsNamed:@"cocoa"]];
    }
    
    return self;
}

@end
