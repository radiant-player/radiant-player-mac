//
//  BarakaLyricMusix.m
//  Baraka Lyrics For Radiant Player
//  Main Controller For MusixMatch
//  @date April 6th, 2016
// MUSIXMATCH WHY? `We detected that your IP is blocked.` Sad so i can't complete this =\

#import "BarakaLyricMusix.h"

@implementation BarakaLyricMusix

// Lets Get Our Current Class
- (NSString *)__whatClass {
    [BarakaLyricMusix temp];
    return @"";
}

+ (NSString *)temp {
    return @"";
}

- (NSString *)__findBarakaLyrics:(NSString *)artist album:(NSString *)album title:(NSString *)title {
    
    if (title == nil || artist == nil) {
        return @"";
    }
    
    NSString *lyrics;
    NSString *url;
    
    url = [BarakaLyricMusix createMusixmatchUrlFor:[title lowercaseString] by:[NSString stringWithFormat:@"%@%@",[[artist substringToIndex:1] uppercaseString],[artist substringFromIndex:1]]];
    lyrics = [BarakaLyricMusix downloadMusixmatchLyricsFrom:url];

    if (lyrics != nil) {
        return lyrics;
    } else {
        return nil;
    }
    
}

+(NSString *) createMusixmatchUrlFor:(NSString *)title by:(NSString *)artist {
    NSString *url = @"https://www.musixmatch.com/lyrics/";
    url = [url stringByAppendingString:[BarakaLyricMusix escapeUri:artist by:@"-"]];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:[BarakaLyricMusix escapeUri:title by:@"-"]];
    return url;
}

+ (NSString *)downloadMusixmatchLyricsFrom:(NSString *)url {
    //NSLog(@"obtaining lyrics '%@'", url);
    
    NSURL *BarakaURL = [NSURL URLWithString:url];
    NSData *HTML = [NSData dataWithContentsOfURL:BarakaURL];
    if (HTML != nil) {
        TFHpple *Parser = [TFHpple hppleWithHTMLData:HTML];
        NSString *xpathQueryLyrics = @"//p[@class=\"mxm-lyrics__content\"]";
        NSArray *NodeLyrics = [Parser searchWithXPathQuery:xpathQueryLyrics];
        NSUInteger ele = (NSUInteger)[NodeLyrics count]; //劜 / Ya ? :| fixes (aka 'unsigned') crap
        NSMutableArray *LyricArray = [[NSMutableArray alloc] initWithCapacity:0];
        if(ele > 0){
            if (NodeLyrics > 0) {
                for (TFHppleElement *element in NodeLyrics) {
                    [LyricArray addObject:[element raw]];
                }
    
                /*NSString* Remove = [self stringByStrippingHTML:LyricArray[0]];*/
    
                NSString *Final = LyricArray[0];
                return Final;
            }
        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
    return @"";
}

@end
