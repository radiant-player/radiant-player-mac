/*
 * NotificationCenter.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "NotificationCenter.h"

NSString *const SONG_NOTIFICATION_NAME = @"SongNotification";

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

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    
    return self;
}

- (void)scheduleNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"notifications.use-growl"] && [GrowlApplicationBridge isGrowlRunning])
    {
        [self _scheduleGrowlNotificationWithTitle:title artist:artist album:album imageURL:imageURL];
    }
    else
    {
        [self _scheduleNSUserNotificationWithTitle:title artist:artist album:album imageURL:imageURL];
    }
}

- (void)_scheduleNSUserNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL
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
    
    // Remove the previous notifications in order to make this notification appear immediately.
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    // Deliver the notification.
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notif];
}

- (void)_scheduleGrowlNotificationWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album imageURL:(NSString *)imageURL
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [NSData data];
    
    // Try to load the album art if possible.
    if ([defaults boolForKey:@"notifications.show-album-art"] && imageURL)
    {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
        imageData = [image TIFFRepresentation];
    }
    
    NSDictionary *properties = @{
        GROWL_NOTIFICATION_NAME: SONG_NOTIFICATION_NAME,
        GROWL_NOTIFICATION_TITLE: title,
        GROWL_NOTIFICATION_DESCRIPTION: [NSString stringWithFormat:@"%@ - %@", artist, album],
        GROWL_NOTIFICATION_ICON_DATA: imageData
    };
    
    [GrowlApplicationBridge notifyWithDictionary:properties];
}

#pragma mark - Delegates

/*
 * NSUserNotificationCenter delegate
 */
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

/*
 * GrowlApplicationBridge delegate
 */
- (void)growlNotificationWasClicked:(id)clickContext
{
    [delegate notificationWasActivated:NotificationActivationTypeContentsClicked];
}

- (NSDictionary *)registrationDictionaryForGrowl
{
    return @{
                GROWL_NOTIFICATIONS_ALL:        @[SONG_NOTIFICATION_NAME],
                GROWL_NOTIFICATIONS_DEFAULT:    @[SONG_NOTIFICATION_NAME]
            };
}

- (NSString *)applicationNameForGrowl
{
    return [Utilities applicationName];
}


@end
