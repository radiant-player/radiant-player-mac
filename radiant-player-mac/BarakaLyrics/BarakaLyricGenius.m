//
//  BarakaLyricGenius.m
//  Baraka Lyrics For Radiant Player
//  Main Controller For Genius
//  @date April 6th, 2016

#import "BarakaLyricGenius.h"


@implementation BarakaLyricGenius

// Lets Get Our Current Class
- (NSString *)__whatClass {
    [BarakaLyricGenius temp];
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
    
    url = [BarakaLyricGenius createGeniusUrlFor:[title lowercaseString] by:[NSString stringWithFormat:@"%@%@",[[artist substringToIndex:1] uppercaseString],[artist substringFromIndex:1]]];
    lyrics = [BarakaLyricGenius downloadGeniusLyricsFrom:url];
    
    if (lyrics != nil) {
        return lyrics;
    } else {
        return nil;
    }
    
}

+(NSString *) createGeniusUrlFor:(NSString *)title by:(NSString *)artist {
     NSString *url = @"http://genius.com/";
     NSString *Art = [artist lowercaseString];
     url = [url stringByAppendingString:[BarakaLyricGenius escapeUri:[NSString stringWithFormat:@"%@%@",[[Art substringToIndex:1] uppercaseString],[Art substringFromIndex:1]] by:@"-"]];
     url = [url stringByAppendingString:@"-"];
     url = [url stringByAppendingString:[BarakaLyricGenius escapeUri:title by:@"-"]];
     url = [url stringByAppendingString:@"-lyrics"];
     return url;
}

+ (NSString *)downloadGeniusLyricsFrom:(NSString *)url {
    //NSLog(@"obtaining lyrics '%@'", url);

    NSURL *BarakaURL = [NSURL URLWithString:url];
    NSData *HTML = [NSData dataWithContentsOfURL:BarakaURL];
    if (HTML != nil) {
        TFHpple *Parser = [TFHpple hppleWithHTMLData:HTML];
        NSString *xpathQueryLyrics = @"//lyrics[@class=\"lyrics\"]";
        NSArray *NodeLyrics = [Parser searchWithXPathQuery:xpathQueryLyrics];
        NSUInteger ele = (NSUInteger)[NodeLyrics count]; //劜 / Ya ? :| fixes (aka 'unsigned') crap
        NSMutableArray *LyricArray = [[NSMutableArray alloc] initWithCapacity:0];
        if(ele > 0){
            if (NodeLyrics > 0) {
                for (TFHppleElement *element in NodeLyrics) {
                    [LyricArray addObject:[element raw]];
                }
            
                NSString* Remove = [self stringByStrippingHTML:LyricArray[0]];
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
