/*
 * NSImage+Data.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSImage+Data.h"

@implementation NSImage (Daata)

- (NSImage *)resizeImage:(NSSize)size
{
    NSData *sourceData = [self TIFFRepresentation];
    NSImage *sourceImage = [[NSImage alloc] initWithData:sourceData];
    NSImage *resizedImage = [[NSImage alloc] initWithSize:size];
    
    NSSize originalSize = [sourceImage size];
    
    [resizedImage lockFocus];
    [sourceImage drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height) operation:NSCompositeSourceOver fraction:1.0];
    [resizedImage unlockFocus];
    
    return resizedImage;
}

- (NSData *)PNGData {
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    return [imageRep representationUsingType:NSPNGFileType properties:nil];
}

@end
