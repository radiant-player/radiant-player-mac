/*
 * NotificationCenter.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

#import "../Utilities.h"

extern NSString * const SONG_NOTIFICATION_NAME;

typedef NS_ENUM(NSInteger, NotificationActivationType) {
    NotificationActivationTypeNone,
    NotificationActivationTypeButtonClicked,
    NotificationActivationTypeContentsClicked
};

@protocol NotificationCenterDelegate <NSObject>

- (void) notificationWasActivated:(NotificationActivationType)activationType;

@end

@interface NotificationCenter : NSObject<NSUserNotificationCenterDelegate, GrowlApplicationBridgeDelegate>

@property (retain) id<NotificationCenterDelegate> delegate;

+ (NotificationCenter *) center;
- (void) scheduleNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL;
- (void) postDistributedNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL;
@end
