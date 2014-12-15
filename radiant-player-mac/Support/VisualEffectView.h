/*
 * VisualEffectView.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

/* The main material that this view displays.
 */
typedef NS_ENUM(NSInteger, VisualEffectMaterial) {
    VisualEffectMaterialAppearanceBased,
    VisualEffectMaterialLight,
    VisualEffectMaterialDark,
    VisualEffectMaterialTitlebar
};

typedef NS_ENUM(NSInteger, VisualEffectBlendingMode) {
    VisualEffectBlendingModeBehindWindow,
};

/* The material may look different when it is inactive.
 */
typedef NS_ENUM(NSInteger, VisualEffectState) {
    VisualEffectStateFollowsWindowActiveState,
    VisualEffectStateActive,
    VisualEffectStateInactive,
};

@interface VisualEffectView : NSVisualEffectView {
    VisualEffectBlendingMode _blendingMode;
    VisualEffectMaterial _material;
    VisualEffectState _state;
    
    BOOL _isImitation;
}

@property (assign) VisualEffectState state;
@property (assign) VisualEffectMaterial material;
@property (assign) VisualEffectBlendingMode blendingMode;

@end
