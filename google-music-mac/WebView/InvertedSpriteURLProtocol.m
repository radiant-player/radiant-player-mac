/*
 * InvertedSpriteURLProtocol.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "InvertedSpriteURLProtocol.h"

@implementation InvertedSpriteURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest*)request
{
    CustomWebView *delegate = [NSURLProtocol propertyForKey:@"InvertedCustomWebView" inRequest:request];
    return (delegate != nil);
}

- (id) initWithRequest:(NSURLRequest*)theRequest cachedResponse:(NSCachedURLResponse*)cachedResponse client:(id<NSURLProtocolClient>)client
{
    // Move the delegate from the request to this instance
    _request = (NSMutableURLRequest *)theRequest;
    _delegate = [NSURLProtocol propertyForKey:@"InvertedCustomWebView" inRequest:_request];
    [NSURLProtocol removePropertyForKey:@"InvertedCustomWebView" inRequest:_request];
    
    self = [super initWithRequest:_request cachedResponse:cachedResponse client:client];
    if (self) {
        _data = [_delegate invertedSpriteSheet];
    }
    return self;
}

- (void)startLoading
{
    NSDictionary *headers = @{
        @"Content-Type": @"image/png",
        @"Content-Length": [NSString stringWithFormat:@"%ld", [_data length]]
    };
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[_request URL] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:headers];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:_data];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}

@end
