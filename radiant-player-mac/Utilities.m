/*
 * Utilities.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "Utilities.h"

@implementation Utilities

+ (NSImage *)imageFromName:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"images/%@", name];
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"png"];
    
    return [[NSImage alloc] initWithContentsOfFile:path];
}

+ (NSData *)dataWithContentsOfPath:(NSString *)path
{
    NSString *location = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    return [NSData dataWithContentsOfFile:location];
}

/*
 * Many thanks to @Dov at Stack Overflow.
 * http://stackoverflow.com/a/6292308/406330
 *
 */
+ (NSImage *)templateImage:(NSString *)templateName withColor:(NSColor *)tint
{
    NSImage *template = [NSImage imageNamed:templateName];
    NSSize size = [template size];
    NSRect imageBounds = NSMakeRect(0, 0, size.width, size.height);
    
    NSImage *copiedImage = [template copy];
    [copiedImage setTemplate:NO];
    [copiedImage setSize:size];
    
    [copiedImage lockFocus];
    
    [tint set];
    NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
    
    [copiedImage unlockFocus];
    
    return copiedImage;
}

+ (NSString *)applicationHomepage
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApplicationHomepage"];
}

+ (NSString *)applicationName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ApplicationName"];
}

+ (BOOL)isSystemInDarkMode
{
    return [[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
}

@end
