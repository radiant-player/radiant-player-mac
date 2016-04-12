//
//  BarakaLyricAZ.m
//  Baraka Lyrics For Radiant Player
//  Main Controller For AZLyrics
//  @date April 6th, 2016

#import "BarakaLyricAZ.h"

@implementation BarakaLyricAZ

// Lets Get Our Current Class
- (NSString *)__whatClass {
    [BarakaLyricAZ temp];
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
    
    url = [BarakaLyricAZ createAZUrlFor:[title lowercaseString] by:[NSString stringWithFormat:@"%@%@",[[artist substringToIndex:1] uppercaseString],[artist substringFromIndex:1]]];
    lyrics = [BarakaLyricAZ downloadAZLyricsFrom:url artist:artist title:title];
    
    
    url = [BarakaLyricAZ createAZUrlForLow:[title lowercaseString] by:[NSString stringWithFormat:@"%@",[artist lowercaseString]]];
    lyrics = [BarakaLyricAZ downloadAZLyricsFrom:url artist:artist title:title];
    
    if (lyrics != nil) {
        return lyrics;
    } else {
        return nil;
    }
    
}

+(NSString *) createAZUrlForLow:(NSString *)title by:(NSString *)artist {
    NSString *Art = [artist lowercaseString];
    NSString *Title = [title lowercaseString];
    NSString* cleanedStringA = [Art stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    NSString* cleanedStringT = [Title stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    NSString *url = @"http://www.azlyrics.com/lyrics/";
    url = [url stringByAppendingString:[BarakaLyricAZ escapeUri:cleanedStringA by:@""]];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:[BarakaLyricAZ escapeUri:cleanedStringT by:@""]];
    url = [url stringByAppendingString:@".html"];
    return url;
}


+(NSString *) createAZUrlFor:(NSString *)title by:(NSString *)artist {
    NSString *Art = [artist lowercaseString];
    NSString *Title = [title lowercaseString];
    NSString *url = @"http://www.azlyrics.com/lyrics/";
    url = [url stringByAppendingString:[BarakaLyricAZ escapeUri:Art by:@"-"]];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:[BarakaLyricAZ escapeUri:Title by:@"-"]];
    url = [url stringByAppendingString:@".html"];
    return url;
}

+ (NSString *)downloadAZLyricsFrom:(NSString *)url artist:(NSString *)artist title:(NSString *)title {
    //NSLog(@"obtaining lyrics '%@'", url);
    
    NSURL *BarakaURL = [NSURL URLWithString:url];
    NSData *HTML = [NSData dataWithContentsOfURL:BarakaURL];
    if (HTML != nil) {
        TFHpple *Parser = [TFHpple hppleWithHTMLData:HTML];
        NSString *xpathQueryLyrics = @"//div[@class=\"col-xs-12 col-lg-8 text-center\"]";
        NSArray *NodeLyrics = [Parser searchWithXPathQuery:xpathQueryLyrics];
        NSUInteger ele = (NSUInteger)[NodeLyrics count]; //劜 / Ya ? :| fixes (aka 'unsigned') crap
        NSMutableArray *LyricArray = [[NSMutableArray alloc] initWithCapacity:0];
        if(ele > 0){
            if (NodeLyrics > 0) {
                for (TFHppleElement *element in NodeLyrics) {
                    [LyricArray addObject:[element raw]];
                }
            
                NSString *Art = [artist lowercaseString];
                NSString *Title = [title lowercaseString];
                NSString *by = [NSString stringWithFormat:@"\"%@%@\" lyrics", [[Art substringToIndex:1] uppercaseString],[Art substringFromIndex:1]];
                NSString *Letter = [NSString stringWithFormat:@"%@", [[Art substringToIndex:1] uppercaseString]];
                NSString *By = [NSString stringWithFormat:@"%@ LYRICS", [Art uppercaseString]];
                NSString *bY = [NSString stringWithFormat:@"%@ Lyrics", [Art uppercaseString]];
                NSString *Song = [NSString stringWithFormat:@"\"%@%@\" lyrics", [[Title substringToIndex:1] uppercaseString],[Title substringFromIndex:1]];
                NSString* Remove = [self stringByStrippingHTML:LyricArray[0]];
                NSString *Remove1 = [self stringByElement:Remove Element:@"&#13;"];
                NSString *Remove2 = [self stringByElement:Remove1 Element:@"MP3"];
                NSString *Remove3 = [self stringByElement:Remove2 Element:@"Email"];
                NSString *Remove4 = [self stringByElement:Remove3 Element:@"Print"];
                NSString *Remove5 = [self stringByElement:Remove4 Element:by];
                NSString *Remove6 = [self stringByElement:Remove5 Element:By];
                NSString *Remove7 = [self stringByElement:Remove6 Element:bY];
                NSString *Remove8 = [self stringByElement:Remove7 Element:@"Submit Corrections"];
                NSString *Remove9 = [self stringByElement:Remove8 Element:@"Visit www.azlyrics.com for these lyrics."];
                NSString *Remove10 = [self stringByElement:Remove9 Element:@"A-Z Lyrics"];
                NSString *Remove11 = [self stringByElement:Remove10 Element:@"Search"];
                NSString *Remove12 = [self stringByElement:Remove11 Element:Letter];
                NSString *Remove13 = [self stringByElement:Remove12 Element:Song];
                //NSString *search = [Remove13 stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
                NSString *Final = Remove13;
                /*NSLog(@"Art %@", Art);
                 NSLog(@"by %@", by);
                 NSLog(@"By %@", By);
                 NSLog(@"bY %@", bY);
                 NSLog(@"Letter %@", Letter);
                 NSLog(@"Song %@", Song);
                 NSLog(@"Final '%@'", Final);*/
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
