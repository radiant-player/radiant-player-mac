/*
 * main.m
 *
 * Originally created by James Fator.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    // Register default preferences.
    NSString *prefsPath = [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
    
    return NSApplicationMain(argc, (const char **)argv);
}
