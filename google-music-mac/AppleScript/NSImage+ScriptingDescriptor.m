/*
 * NSImage+ScriptingDescriptor.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NSImage+ScriptingDescriptor.h"

@implementation NSImage (ScriptingDescriptor)

- (id)scriptingImageDescriptor
{
	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeTIFF data:[self TIFFRepresentation]];
}


@end
