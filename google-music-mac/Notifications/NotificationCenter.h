/*
 * NotificationCenter.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NotificationActivationType) {
    NotificationActivationTypeNone,
    NotificationActivationTypeButtonClicked,
    NotificationActivationTypeContentsClicked
};

@protocol NotificationCenterDelegate <NSObject>

- (void) notificationWasActivated:(NotificationActivationType)activationType;

@end

@interface NotificationCenter : NSObject<NSUserNotificationCenterDelegate>

@property (retain) id<NotificationCenterDelegate> delegate;

+ (NotificationCenter *) center;
- (void) scheduleNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL;

@end
