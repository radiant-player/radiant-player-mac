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
@property (retain) NSString *css;
@property (retain) NSString *js;

- (void)applyToWebView:(WebView *)webView;

+ (NSString *)cssNamed:(NSString *)name;
+ (NSString *)jsNamed:(NSString *)name;
+ (NSMutableDictionary *)styles;

@end
