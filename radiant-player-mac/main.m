/*
 * main.m
 *
 * Originally created by James Fator.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "Support/VisualEffectView.h"
#import "Popup/PopupView.h"

int main(int argc, char *argv[])
{
    // Register default preferences.
    NSString *prefsPath = [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
    
    // Register the NSVisualEffectView class if it doesn't exist.
    NSVisualEffectViewExists = NSClassFromString(@"NSVisualEffectView") != nil;
    
    if (!NSVisualEffectViewExists)
    {
        NSVisualEffectViewClass = [VisualEffectView class];
    }
    else
    {
        NSVisualEffectViewClass = [NSVisualEffectView class];
        class_setSuperclass([PopupView class], [NSVisualEffectView class]);
    }
    
    return NSApplicationMain(argc, (const char **)argv);
}
