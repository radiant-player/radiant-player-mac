/*
 * PopupPanel.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PopupView.h"

#define ARROW_WIDTH 18
#define ARROW_HEIGHT 7

#define LINE_THICKNESS 1.0f
#define CORNER_RADIUS 12.0f

@implementation PopupView

@synthesize isLargePlayer;
@synthesize trackingArea;
@synthesize backgroundImage = _backgroundImage;
@synthesize hoverAlphaMultiplier = _hoverAlphaMultiplier;

@synthesize arrowX;

@synthesize delegate;

- (void)awakeFromNib
{
    isLargePlayer = NO;
    _hoverAlphaMultiplier = 0.0;
    
    [self setAnimations:@{@"hoverAlphaMultiplier": [CABasicAnimation animation]}];
    [self setAppearance:[NSAppearance currentAppearance]];
    [self setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [self setMaterial:NSVisualEffectMaterialAppearanceBased];
    [self setState:NSVisualEffectStateActive];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect contentRect = NSInsetRect([self bounds], LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(arrowX, NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(arrowX + ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))];
    
    [path curveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:contentRect.origin controlPoint2:contentRect.origin];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    [NSGraphicsContext saveGraphicsState];
    [path addClip];
    [super drawRect:dirtyRect];
    [[NSColor colorWithWhite:1.0 alpha:0.3] set];
    [path fill];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
    
    // Draw the background album art image if possible.
    if (isLargePlayer)
    {
        if (_backgroundImage != nil)
        {
            [path addClip];
            [_backgroundImage drawInRect:[self bounds]
                                fromRect:NSMakeRect(0, 0, _backgroundImage.size.width, _backgroundImage.size.height)
                               operation:NSCompositeSourceOver
                                fraction:1.0];
        }
        
        NSColor *gradientDark = [NSColor colorWithDeviceWhite:0.1 alpha:_hoverAlphaMultiplier*0.7];
        NSColor *gradientLight = [NSColor colorWithDeviceWhite:0.05 alpha:_hoverAlphaMultiplier*0.2];
        NSColor *gradientNone = [NSColor colorWithDeviceWhite:0.0 alpha:_hoverAlphaMultiplier*0.1];
        NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:
                                    gradientDark, 0.0,
                                    gradientLight, 0.3,
                                    gradientNone, 0.50,
                                    gradientLight, 0.7,
                                    gradientDark, 1.0,
                                    nil];
        [gradient drawInBezierPath:path angle:-90.0];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    if (isLargePlayer)
    {
        // Begin the animation to show hover details.
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.25];
        [[self animator] setHoverAlphaMultiplier:1.0];
        [NSAnimationContext endGrouping];
    }
}

- (void)mouseExited:(NSEvent *)event
{
    if (isLargePlayer)
    {
        // Begin the animation to hide hover details.
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.25];
        [[self animator] setHoverAlphaMultiplier:0.0];
        [NSAnimationContext endGrouping];
    }
}

- (void)updateTrackingAreas
{
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setHoverAlphaMultiplier:(CGFloat)hoverAlphaMultiplier
{
    _hoverAlphaMultiplier = hoverAlphaMultiplier;
    
    // Update subviews.
    for (NSView *view in [self subviews])
    {
        if ([view tag] != NO_SONGS_PLAYING_TAG && [view tag] != EXPAND_ART_TAG && ![view isKindOfClass:[EDStarRating class]])
            [view setAlphaValue:_hoverAlphaMultiplier];
    }
    
    // Redraw.
    [self setNeedsDisplay:YES];
}

- (CGFloat)hoverAlphaMultiplier
{
    return _hoverAlphaMultiplier;
}

- (void)togglePlayerSize
{
    if (isLargePlayer == NO)
    {
        NSRect frame = [self.window frame];
        frame.origin.y -= (MINI_PLAYER_LARGE_HEIGHT - frame.size.height);
        frame.size.height = MINI_PLAYER_LARGE_HEIGHT;
        isLargePlayer = YES;
        
        // Show the controls.
        [self setHoverAlphaMultiplier:1.0];
        
        // Set the background image.
        [self setBackgroundImage:[delegate.artView image]];
        
        // Reset art's expand/contract image.
        [delegate.artExpandView setImage:[delegate expandContractImage]];
        
        // Begin the animation to resize.
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.25];
        [[self.window animator] setFrame:frame display:YES];
        [NSAnimationContext endGrouping];
        
        // Recolor elements.
        [delegate.titleLabel setTextColor:[NSColor whiteColor]];
        [delegate.titleLabel setAlignment:NSCenterTextAlignment];
        [delegate.artistLabel setTextColor:[NSColor whiteColor]];
        [delegate.artistLabel setAlignment:NSCenterTextAlignment];
        [delegate.albumLabel setTextColor:[NSColor whiteColor]];
        [delegate.albumLabel setAlignment:NSCenterTextAlignment];
        
        [delegate playbackChanged:delegate.playbackMode];
        [delegate repeatChanged:delegate.repeatMode];
        [delegate shuffleChanged:delegate.shuffleMode];
        [delegate ratingChanged:delegate.songRating];
        [delegate.backButton setImage:[delegate backImage]];
        [delegate.forwardButton setImage:[delegate forwardImage]];
        [delegate.showMainWindowButton setImage:[delegate showMainWindowImage]];
        [delegate.starBadgeButton setImage:[delegate starBadgeImage:[delegate songRating]]];
        [delegate.starRatingView setStarImage:[delegate starRatingImage]];
    }
    else
    {
        NSRect frame = [self.window frame];
        frame.origin.y += (frame.size.height - MINI_PLAYER_SMALL_HEIGHT);
        frame.size.height = MINI_PLAYER_SMALL_HEIGHT;
        isLargePlayer = NO;
        
        // Show the controls.
        [self setHoverAlphaMultiplier:1.0];
        
        // Remove the background image.
        [self setBackgroundImage:nil];
        
        // Reset art's expand/contract image.
        [delegate.artExpandView setImage:[delegate expandContractImage]];
        
        // Begin the animation to resize.
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:.25];
        [[self.window animator] setFrame:frame display:YES];
        [NSAnimationContext endGrouping];
        
        // Recolor elements.
        [delegate.titleLabel setTextColor:[NSColor blackColor]];
        [delegate.titleLabel setAlignment:NSLeftTextAlignment];
        [delegate.artistLabel setTextColor:[NSColor blackColor]];
        [delegate.artistLabel setAlignment:NSLeftTextAlignment];
        [delegate.albumLabel setTextColor:[NSColor blackColor]];
        [delegate.albumLabel setAlignment:NSLeftTextAlignment];
        
        [delegate playbackChanged:delegate.playbackMode];
        [delegate repeatChanged:delegate.repeatMode];
        [delegate shuffleChanged:delegate.shuffleMode];
        [delegate ratingChanged:delegate.songRating];
        [delegate.backButton setImage:[delegate backImage]];
        [delegate.forwardButton setImage:[delegate forwardImage]];
        [delegate.showMainWindowButton setImage:[delegate showMainWindowImage]];
        [delegate.starBadgeButton setImage:[delegate starBadgeImage:[delegate songRating]]];
        [delegate.starRatingView setStarImage:[delegate starRatingImage]];
    }
}

@end
