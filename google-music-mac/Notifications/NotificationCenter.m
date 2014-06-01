/*
 * NotificationCenter.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NotificationCenter.h"

@implementation NotificationCenter

@synthesize delegate;

+ (NotificationCenter *)center
{
    static dispatch_once_t token;
    static NotificationCenter *shared = nil;
    
    dispatch_once(&token, ^{
        shared = [[NotificationCenter alloc] init];
    });
    
    return shared;
}

- (void)scheduleNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUserNotification *notif = [[NSUserNotification alloc] init];
    notif.title = title;
    
    if ([defaults boolForKey:@"notifications.itunes-style"]) {
        notif.subtitle = [NSString stringWithFormat:@"%@ — %@", artist, album];
        [notif setValue:@YES forKey:@"_showsButtons"];
    }
    else {
        notif.informativeText = [NSString stringWithFormat:@"%@ — %@", artist, album];
    }
    
    // Make sure the version of OS X supports this.
    if ([notif respondsToSelector:@selector(setContentImage:)])
    {
        // Try to load the album art if possible.
        if ([defaults boolForKey:@"notifications.show-album-art"] && imageURL)
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
            
            if ([defaults boolForKey:@"notifications.itunes-style"]) {
                [notif setValue:image forKey:@"_identityImage"];
            }
            else {
                notif.contentImage = image;
            }
        }
    }
    
    notif.actionButtonTitle = @"Skip";
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Remove the previous notifications in order to make this notification appear immediately.
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    // Deliver the notification.
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notif];
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NotificationActivationType type;
    
    switch (notification.activationType)
    {
        case NSUserNotificationActivationTypeActionButtonClicked:
            type = NotificationActivationTypeButtonClicked;
            break;
            
        case NSUserNotificationActivationTypeContentsClicked:
            type = NotificationActivationTypeContentsClicked;
            break;
            
        default:
            type = NotificationActivationTypeNone;
            break;
    }
    
    [delegate notificationWasActivated:type];
}


@end
