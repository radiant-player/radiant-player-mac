//
//  BarakaLyricWikia.m
//  Baraka Lyrics For Radiant Player
//  Main Controller For LyricsWikia
//  @date April 6th, 2016

#import "BarakaLyricWikia.h"

@implementation BarakaLyricWikia

// Lets Get Our Current Class
- (NSString *)__whatClass {
    [BarakaLyricWikia temp];
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
    
    url = [BarakaLyricWikia createWikiUrlFor:[title lowercaseString] by:[NSString stringWithFormat:@"%@%@",[[artist substringToIndex:1] uppercaseString],[artist substringFromIndex:1]]];
    lyrics = [BarakaLyricWikia downloadWikiLyricsFrom:url];
    
    url = [BarakaLyricWikia createWikiUrlFor:[title capitalizedString] by:artist];
    lyrics = [BarakaLyricWikia downloadWikiLyricsFrom:url];
    
    if (lyrics != nil) {
        return lyrics;
    } else {
        return nil;
    }
    
}

+(NSString *) createWikiUrlFor:(NSString *)title by:(NSString *)artist {
    NSString *url = @"http://lyrics.wikia.com/wiki/";
    url = [url stringByAppendingString:[BarakaLyricWikia escapeUri:artist by:@"_"]];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:[BarakaLyricWikia escapeUri:title by:@"_"]];
    return url;
}

+ (NSString *)downloadWikiLyricsFrom:(NSString *)url {
    //NSLog(@"obtaining lyrics '%@'", url);

    NSURL *BarakaURL = [NSURL URLWithString:url];
    NSData *HTML = [NSData dataWithContentsOfURL:BarakaURL];
    
    if (HTML != nil) {
        TFHpple *Parser = [TFHpple hppleWithHTMLData:HTML];
        
        NSString *xpathQueryLyrics = @"//div[@class=\"lyricbox\"]";
        
        NSArray *NodeLyrics = [Parser searchWithXPathQuery:xpathQueryLyrics];
        NSUInteger ele = (NSUInteger)[NodeLyrics count]; //劜 / Ya ? :| fixes (aka 'unsigned') crap
        NSMutableArray *LyricArray = [[NSMutableArray alloc] initWithCapacity:0];
        if(ele > 0){
            if (NodeLyrics > 0) {
                for (TFHppleElement *element in NodeLyrics) {
                    [LyricArray addObject:[element raw]];
                }
            
                NSString *Remove = [self stringByElement:LyricArray[0] Element:@"<div class=\"lyricsbreak\"/>"];
                NSString *Final = Remove;
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