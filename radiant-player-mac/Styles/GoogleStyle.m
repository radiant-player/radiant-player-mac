/*
 * GoogleStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "GoogleStyle.h"

@implementation GoogleStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Google"];
        [self setAuthor:@"Google"];
        [self setDescription:@"The default Google style"];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.898f green:0.898f blue:0.898f alpha:1.0f]];
        [self setTitleColor:nil];
        [self setCss:[ApplicationStyle cssNamed:@"google"]];
        [self setJs:[ApplicationStyle jsNamed:@"google"]];
    }
    
    return self;
}

@end
