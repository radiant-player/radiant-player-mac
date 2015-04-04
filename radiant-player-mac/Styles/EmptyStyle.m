/*
 * EmptyStyle.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "EmptyStyle.h"

@implementation EmptyStyle

- (id)init
{
    if (self = [super init]) {
        [self setName:@"Empty"];
        [self setAuthor:@"Google"];
        [self setDescription:@"An empty style"];
        [self setWindowColor:[NSColor colorWithSRGBRed:0.898f green:0.898f blue:0.898f alpha:1.0f]];
        [self setTitleColor:nil];
        [self setCss:[ApplicationStyle cssNamed:@"none"]];
        [self setJs:[ApplicationStyle jsNamed:@"none"]];
    }
    
    return self;
}

@end
