//
//  BarakaLyricMetro.m
//  Baraka Lyrics For Radiant Player
//  Main Controller For MetroLyrics
//  @date April 6th, 2016

#import "BarakaLyricMetro.h"

@implementation BarakaLyricMetro

// Lets Get Our Current Class
- (NSString *)__whatClass {
    [BarakaLyricMetro temp];
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
    
    url = [BarakaLyricMetro createMetroUrlFor:[title lowercaseString] by:[NSString stringWithFormat:@"%@%@",[[artist substringToIndex:1] uppercaseString],[artist substringFromIndex:1]]];
    lyrics = [BarakaLyricMetro downloadMetroLyricsFrom:url];
    
    if (lyrics != nil) {
        return lyrics;
    } else {
        return nil;
    }
    
}

+ (NSString *) createMetroUrlFor:(NSString *)title by:(NSString *)artist {
    NSString *url = @"http://www.metrolyrics.com/";
    url = [url stringByAppendingString:[BarakaLyricMetro escapeUri:[title lowercaseString] by:@"-"]];
    url = [url stringByAppendingString:@"-"];
    url = [url stringByAppendingString:@"lyrics-"];
    url = [url stringByAppendingString:[BarakaLyricMetro escapeUri:[artist lowercaseString] by:@"-"]];
    url = [url stringByAppendingString:@".html"];
    return url;
}

+ (NSString *)downloadMetroLyricsFrom:(NSString *)url {
    //NSLog(@"obtaining lyrics '%@'", url);
    
    NSURL *BarakaURL = [NSURL URLWithString:url];
    NSData *HTML = [NSData dataWithContentsOfURL:BarakaURL];
    if (HTML != nil) {
        TFHpple *Parser = [TFHpple hppleWithHTMLData:HTML];
        NSString *xpathQueryLyrics = @"//div[@id=\"lyrics-body-text\"]";
        NSArray *NodeLyrics = [Parser searchWithXPathQuery:xpathQueryLyrics];
        NSUInteger ele = (NSUInteger)[NodeLyrics count]; //劜 / Ya ? :| fixes (aka 'unsigned') crap
        NSMutableArray *LyricArray = [[NSMutableArray alloc] initWithCapacity:0];
        if(ele > 0){
            if (NodeLyrics > 0) {
                for (TFHppleElement *element in NodeLyrics) {
                    [LyricArray addObject:[element raw]];
                }
            
                /*NSString* Remove = [self stringByStrippingHTML:LyricArray[0]];
             
                 NSString *Remove1 = [self stringByElement:LyricArray[0] Element:@"meaning"];
                 NSString *Remove2 = [self stringByElement:Remove1 Element:@",  Editor"];
                 NSString *Remove3 = [self stringByElement:Remove2 Element:@"See all"];
                 NSString *Final = [self stringByElement:Remove3 Element:@"by"];*/
                
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
