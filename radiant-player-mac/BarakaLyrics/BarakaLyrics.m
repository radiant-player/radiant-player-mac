//
//  BarakaLyrics.m
//  Baraka Lyrics For Radiant Player
//  Main Header to tie things together
//  @date April 6th, 2016

#import "BarakaLyrics.h"

@implementation BarakaLyrics

- (NSString *)__findBarakaLyrics:(NSString *)artist album:(NSString *)album title:(NSString *)title {
    [[NSException exceptionWithName:@"bad" reason:@"exception Baraka" userInfo:nil] raise];
    return nil;
}

- (NSString *)_whatClass {
    NSString *what = NSStringFromClass([self class]);
    return what;
}

- (NSString *)whatClass {
    NSString *result = nil;
    
    result = [self _whatClass];
    
    if (result) {
        return result;
    } else {
        return nil;
    }
 
}

- (NSString *)_findBarakaLyrics:(NSString *)artist album:(NSString *)album title:(NSString *)title {
    NSString *lyrics = [self __findBarakaLyrics:artist album:album title:title];
    
    if (!lyrics && ![lyrics length])
        return nil;

    if ([lyrics length] / [[lyrics componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count] > 200)
    {
        
        NSString *what = NSStringFromClass([self class]);
        if ([what isEqualToString:@"BarakaLyricWikia"]) {
            //continue as wiki for some reason is not with \n just <br /> pretty much the same so continue
        } else {
            //NSLog([NSString stringWithFormat:@"Warning: Stopping BarakaLyrics for artist '%@' and title '%@' from fetcher '%@' for lack of line sets.", artist, title, [self className]]);
           return nil;
        }
    }
    
    return lyrics;
}

- (NSString *)findBarakaLyrics:(NSString *)artist album:(NSString *)album title:(NSString *)title {
    //NSLog(@" artist: %@ album: %@ title: %@", artist, album, title);
    artist = [artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([[artist lowercaseString] isEqualToString:@"various artists"] && [title rangeOfString:@" - "].location != NSNotFound) {
        artist = [title componentsSeparatedByString:@" - "][0];
        title = [title componentsSeparatedByString:@" - "][1];
    }
    NSString *result = nil;
    
    result = [self _findBarakaLyrics:artist album:album title:title];
    
    if (result)
        return result;
    
    while ([self LastRoundBracketed:title]) {
        title = [self LastRoundBracketed:title];
        
        result = [self _findBarakaLyrics:artist album:album title:title];
        
        if (result)
            return result;
    }
    
    while ([self LastSquareBracketed:title]) {
        title = [self LastSquareBracketed:title];
        
        result = [self _findBarakaLyrics:artist album:album title:title];
        if (result)
            return result;
    }
    
    return nil;
}


- (NSString *)LastRoundBracketed:(NSString *)title {
    if ([title rangeOfString:@"("].location != NSNotFound &&
        [title rangeOfString:@")"].location != NSNotFound &&
        [title rangeOfString:@"("].location < [title rangeOfString:@")"].location)
        return [title substringToIndex:[title rangeOfString:@"(" options:NSBackwardsSearch].location];
    else
        return nil;
}

- (NSString *)LastSquareBracketed:(NSString *)title {
    if ([title rangeOfString:@"["].location != NSNotFound &&
        [title rangeOfString:@"]"].location != NSNotFound &&
        [title rangeOfString:@"["].location < [title rangeOfString:@"]"].location)
        return [title substringToIndex:[title rangeOfString:@"[" options:NSBackwardsSearch].location];
    else
        return nil;
}

/**
 * replace whitespaces by underscores and escape special URI characters
 */
+ (NSString *) escapeUri:(NSString *)uri by:(NSString *)separator {
    uri = [uri stringByReplacingOccurrencesOfString:@" "
                                         withString:separator];
    
    CFStringRef escapedURI = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (CFStringRef)uri,
                                                                     NULL,
                                                                     (CFStringRef)@";/?:@&=+$,",
                                                                     kCFStringEncodingUTF8);
    return ((NSString *) CFBridgingRelease(escapedURI));
}

+ (NSString *)stringByStrippingHTML:(NSString*)str {
    NSRange r;
    while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location  != NSNotFound)
    {
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    }
    return str;
}

+ (NSString *)stringByElement:(NSString*)str Element:(NSString *)elm {
    NSRange r;
    while ((r = [str rangeOfString:elm options:NSRegularExpressionSearch]).location  != NSNotFound)
    {
       // NSString *h =  [NSString stringWithFormat:@"<div id=\"BarakaHideThis\" style=\"display:none;\"%@", r];
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    }
    return str;
}

@end

@implementation NSMutableArray (Lyrics)

- (void) Jumble {
    int count = (int)[self count];
    for (uint i = 0; i < count; ++i)
    {
        int Ele = count - i;
        int n = arc4random_uniform(Ele) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end