//
//  BarakaLyrics.m
//  Baraka Lyrics For Radiant Player
//  Main Controller to tie things together
//  @date April 6th, 2016

#import "TFHpple.h"

@interface BarakaLyrics : NSObject

- (NSString *)findBarakaLyrics:(NSString *)artist album:(NSString *)album title:(NSString *)title;

- (NSString *)whatClass;

+ (NSString *)stringByStrippingHTML:(NSString*)str;

+ (NSString *)stringByElement:(NSString*)str Element:(NSString *)elm;

+ (NSString *)escapeUri:(NSString *)uri by:(NSString *)separator;

@end

@interface NSMutableArray (Lyrics)
- (void) Jumble;
@end