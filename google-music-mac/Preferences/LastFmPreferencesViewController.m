/*
 * LastFmPreferencesViewController.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "LastFmPreferencesViewController.h"

@implementation LastFmPreferencesViewController

@synthesize authorizeButton;
@synthesize usernameField;
@synthesize passwordField;
@synthesize logo;

@synthesize defaults;

- (void)awakeFromNib
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    // Fix for Xcode's inability to use images in paths in Interface Builder.
    [logo setImage:[Utilities imageFromName:@"lastfm"]];
    
    // Synchronize the settings.
    [self sync];
}

- (void) sync
{
    NSString *session = [defaults objectForKey:@"lastfm.session"];
    NSString *username = [defaults objectForKey:@"lastfm.username"];
    
    [LastFm sharedInstance].apiKey = [defaults objectForKey:@"lastfm.api-key"];
    [LastFm sharedInstance].apiSecret = [defaults objectForKey:@"lastfm.api-secret"];
    [LastFm sharedInstance].username = username;
    [LastFm sharedInstance].session = session;
    
    if ([session length] != 0) {
        [authorizeButton setTitle:@"Deauthorize"];
        [authorizeButton setEnabled:YES];
        [usernameField setEnabled:NO];
        [passwordField setEnabled:NO];
    }
    else {
        [authorizeButton setTitle:@"Authorize"];
        [authorizeButton setEnabled:YES];
        [usernameField setEnabled:YES];
        [passwordField setEnabled:YES];
    }
}

- (IBAction) authorizeScrobble:(NSButton *)sender
{
    NSString *session = [defaults objectForKey:@"lastfm.session"];
    
    if ([session length]) {
        // Deauthorize.
        [defaults removeObjectForKey:@"lastfm.session"];
        [defaults removeObjectForKey:@"lastfm.username"];
        [defaults synchronize];
        
        [usernameField setStringValue:@""];
        [passwordField setStringValue:@""];
        
        [self sync];
    }
    else {
        // Attempt to obtain session key.
        [authorizeButton setTitle:@"Authorizing..."];
        [authorizeButton setEnabled:NO];
        
        NSString *username = [usernameField stringValue];
        NSString *password = [passwordField stringValue];
        
        [[LastFm sharedInstance] getSessionForUser:username password:password
            successHandler:^(NSDictionary *result) {
                [defaults setObject:result[@"key"] forKey:@"lastfm.session"];
                [defaults setObject:result[@"name"] forKey:@"lastfm.username"];
                [defaults synchronize];
                
                [self sync];
            }
            failureHandler:^(NSError *error) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Unable to login to Last.fm."];
                [alert setIcon:nil];
                [alert beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
                
                [authorizeButton setTitle:@"Authorize"];
                [authorizeButton setEnabled:YES];
                [passwordField setStringValue:@""];
            }];
    }
}


- (NSString *)identifier
{
    return @"LastFmPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [Utilities imageFromName:@"lastfm-icon"];
}

- (NSString *)toolbarItemLabel
{
    return @"Last.fm";
}

@end
