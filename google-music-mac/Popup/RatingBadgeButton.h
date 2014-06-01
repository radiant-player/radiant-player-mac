/*
 * RatingBadgeButton.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <EDStarRating/EDStarRating.h>

@interface RatingBadgeButton : NSButton {
    BOOL _entered;
}

@property (assign) IBOutlet EDStarRating *starRatingView;
@property (assign) IBOutlet NSView *infoView;

@end
