/*
 * NSImage+Data.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

@interface NSImage (Data)

- (NSImage *)resizeImage:(NSSize)size;
- (NSData *)PNGData;

@end
