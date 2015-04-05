/*
 * Utilities.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface Utilities : NSObject

+ (NSImage *)imageFromName:(NSString *)name;
+ (NSData *)dataWithContentsOfPath:(NSString *)path;
+ (NSImage *)templateImage:(NSString *)templateName withColor:(NSColor *)tint;

+ (NSString *)applicationHomepage;
+ (NSString *)applicationName;

+ (BOOL)isSystemInDarkMode;

@end
