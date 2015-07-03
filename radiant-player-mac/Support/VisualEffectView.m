/*
 * VisualEffectView.h
 *
 * A stub class to use NSVisualEffectView without runtime checks for its existence everywhere.
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "VisualEffectView.h"
#import "Utilities.h"
#import <objc/runtime.h>

#define FILL_OPACITY 0.98f
#define STROKE_OPACITY 1.0f

@implementation VisualEffectView

@synthesize material = _material;
@synthesize state = _state;
@synthesize blendingMode = _blendingMode;

BOOL NSVisualEffectViewExists;
Class NSVisualEffectViewClass;

- (void)setMaskImage:(NSImage *)maskImage
{
    
}

- (VisualEffectBlendingMode)blendingMode
{
    return _blendingMode;
}

- (void)setBlendingMode:(VisualEffectBlendingMode)blendingMode
{
    _blendingMode = blendingMode;
}

- (VisualEffectState)state
{
    return _state;
}

- (void)setState:(VisualEffectState)state
{
    _state = state;
}

- (VisualEffectMaterial)material
{
    return _material;
}

- (void)setMaterial:(VisualEffectMaterial)material
{
    _material = material;
}

- (BOOL)_isDark
{
    if (self.material == VisualEffectMaterialDark)
        return YES;
    
    if (self.material == VisualEffectMaterialAppearanceBased)
    {
        if (NSVisualEffectViewExists && self.appearance.name == NSAppearanceNameVibrantDark)
            return YES;
    }
    
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (NSVisualEffectViewExists)
    {
        [super drawRect:dirtyRect];
        return;
    }
    
    NSRect bounds = [self bounds];
    NSColor *colorTop;
    NSColor *colorBottom;
    
    if ([self _isDark])
    {
        colorTop = [NSColor colorWithRed:0.11f green:0.11f blue:0.14f alpha:FILL_OPACITY];
        colorBottom = [NSColor colorWithRed:0.08f green:0.08f blue:0.11f alpha:FILL_OPACITY];
    }
    else
    {
        colorTop = [NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY];
        colorBottom = [NSColor colorWithDeviceWhite:0.95 alpha:FILL_OPACITY];
    }
    
    NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:colorTop endingColor:colorBottom];
    
    [backgroundGradient drawInRect:bounds angle:-90];
}

@end
