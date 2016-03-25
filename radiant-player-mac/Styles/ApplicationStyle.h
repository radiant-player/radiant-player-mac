/*
 * ApplicationStyle.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ApplicationStyle : NSObject

@property (retain) NSString *name;
@property (retain) NSString *author;
@property (retain) NSString *description;
@property (assign) NSInteger version;

@property (retain) NSColor *windowColor;
@property (retain) NSColor *titleColor;
@property (retain) NSString *css;
@property (retain) NSString *js;

- (void)applyToWebView:(WebView *)webView window:(NSWindow *)window;

+ (NSString *)cssNamed:(NSString *)name;
+ (NSMutableDictionary *)styles;

+ (void)applyYosemiteVisualEffects:(WebView *)webView window:(NSWindow *)window appearance:(NSString *)appearanceName;

@end
