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
        //[self setWindowColor:[NSColor colorWithDeviceRed:(239/255.0f) green:(108/255.0f) blue:(0/255.0f) alpha:1.0]];
        [self setWindowColor:[NSColor colorWithDeviceRed:(245/255.0f) green:(245/255.0f) blue:(245/255.0f) alpha:1.0]];
        [self setCss:[ApplicationStyle cssNamed:@"google"]];
        [self setJs:[ApplicationStyle jsNamed:@"google"]];
    }
    
    return self;
}

@end
