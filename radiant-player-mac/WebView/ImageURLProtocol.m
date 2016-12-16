/*
 * ImageURLProtocol.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "ImageURLProtocol.h"

@implementation ImageURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest*)request
{
    CustomWebView *delegate = [NSURLProtocol propertyForKey:@"ImagesCustomWebView" inRequest:request];
    return (delegate != nil);
}

- (id) initWithRequest:(NSURLRequest*)theRequest cachedResponse:(NSCachedURLResponse*)cachedResponse client:(id<NSURLProtocolClient>)client
{
    // Move the delegate from the request to this instance
    _request = (NSMutableURLRequest *)theRequest;
    _delegate = [NSURLProtocol propertyForKey:@"ImagesCustomWebView" inRequest:_request];
    [NSURLProtocol removePropertyForKey:@"ImagesCustomWebView" inRequest:_request];
    
    self = [super initWithRequest:_request cachedResponse:cachedResponse client:client];
    if (self) {
        NSString *name = [[_request URL] lastPathComponent];
        
        // Handle special images.
        if ([name caseInsensitiveCompare:@"arrow-left-yosemite.png"] == NSOrderedSame) {
            _data = [[[NSImage imageNamed:NSImageNameGoLeftTemplate] resizeImage:NSMakeSize(16, 18)] PNGData];
        }
        else if ([name caseInsensitiveCompare:@"arrow-right-yosemite.png"] == NSOrderedSame) {
            _data = [[[NSImage imageNamed:NSImageNameGoRightTemplate] resizeImage:NSMakeSize(16, 18)] PNGData];
        }
        else if ([name caseInsensitiveCompare:@"arrow-left-yosemite-inactive.png"] == NSOrderedSame) {
            NSColor *inactiveColor = [NSColor colorWithRed:0.68 green:0.68 blue:0.68 alpha:1.0];
            _data = [[[Utilities templateImage:NSImageNameGoLeftTemplate withColor:inactiveColor] resizeImage:NSMakeSize(16, 18)] PNGData];
        }
        else if ([name caseInsensitiveCompare:@"arrow-right-yosemite-inactive.png"] == NSOrderedSame) {
            NSColor *inactiveColor = [NSColor colorWithRed:0.68 green:0.68 blue:0.68 alpha:1.0];
            _data = [[[Utilities templateImage:NSImageNameGoRightTemplate withColor:inactiveColor] resizeImage:NSMakeSize(16, 18)] PNGData];
        }
        else {
            NSString *path = [NSString stringWithFormat:@"images/%@", name];
            _data = [Utilities dataWithContentsOfPath:path];
        }
    }
    return self;
}

- (void)startLoading
{
    NSString *mimeType = [self mimeTypeFromURL:[_request URL]];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[_request URL] MIMEType:mimeType expectedContentLength:[_data length] textEncodingName:nil];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [[self client] URLProtocol:self didLoadData:_data];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (NSString *)mimeTypeFromURL:(NSURL *)url
{
    NSString *extension = [[url pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"png"])
        return @"image/png";
    
    if ([extension isEqualToString:@"jpg"])
        return @"image/jpeg";
    
    if ([extension isEqualToString:@"gif"])
        return @"image/gif";
    
    if ([extension isEqualToString:@"svg"])
        return @"image/svg+xml";
}

@end
