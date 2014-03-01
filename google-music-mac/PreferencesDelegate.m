/*
 * PreferencesDelegate.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "PreferencesDelegate.h"
#import <LastFm/LastFm.h>

@implementation PreferencesDelegate

@synthesize lastFMAuthorizeButton;
@synthesize lastFMUsernameField;
@synthesize lastFMPasswordField;

@synthesize defaults;

- (void)awakeFromNib
{
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void) lastFMSync
{
    NSString *session = [defaults objectForKey:@"lastfm.session"];
    NSString *username = [defaults objectForKey:@"lastfm.username"];
    
    [LastFm sharedInstance].apiKey = [defaults objectForKey:@"lastfm.apiKey"];
    [LastFm sharedInstance].apiSecret = [defaults objectForKey:@"lastfm.apiSecret"];
    [LastFm sharedInstance].username = username;
    [LastFm sharedInstance].session = session;
    
    if ([username length] != 0) {
        [lastFMUsernameField setStringValue:username];
    }
    
    if ([session length] != 0) {
        [lastFMAuthorizeButton setTitle:@"Deauthorize"];
    }
    else {
        [lastFMAuthorizeButton setTitle:@"Authorize"];
    }
}

- (IBAction) lastFMAuthorizeScrobble:(NSButton *)sender
{
    NSString *session = [defaults objectForKey:@"lastfm.session"];
    if ([session length]) {
        // Deauthorize.
        [defaults removeObjectForKey:@"lastfm.session"];
        [defaults removeObjectForKey:@"lastfm.username"];
        [defaults synchronize];
        
        [lastFMUsernameField setStringValue:nil];
        [lastFMPasswordField setStringValue:nil];
        
        [self lastFMSync];
    }
    else {
        // Attempt to obtain session key.
        [lastFMAuthorizeButton setTitle:@"Authorizing..."];
        [lastFMAuthorizeButton setEnabled:false];
        
        [[LastFm sharedInstance] getSessionForUser:[lastFMUsernameField stringValue] password:[lastFMPasswordField stringValue] successHandler:^(NSDictionary *result) {
                [defaults setObject:result[@"key"] forKey:@"lastfm.session"];
                [defaults setObject:result[@"name"] forKey:@"lastfm.username"];
                [defaults synchronize];
            
                [self lastFMSync];
                [lastFMAuthorizeButton setEnabled:true];
            }
            failureHandler:^(NSError *error) {
                [lastFMAuthorizeButton setTitle:@"Login Failed. Try Again!"];
                [lastFMAuthorizeButton setEnabled:true];
        }];
    }
}


@end
