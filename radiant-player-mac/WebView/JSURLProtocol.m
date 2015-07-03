/*
 * JSURLProtocol.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "JSURLProtocol.h"

@implementation JSURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest*)request
{
    CustomWebView *delegate = [NSURLProtocol propertyForKey:@"JSCustomWebView" inRequest:request];
    return (delegate != nil);
}

- (id) initWithRequest:(NSURLRequest*)theRequest cachedResponse:(NSCachedURLResponse*)cachedResponse client:(id<NSURLProtocolClient>)client
{
    // Move the delegate from the request to this instance
    _request = (NSMutableURLRequest *)theRequest;
    _delegate = [NSURLProtocol propertyForKey:@"JSCustomWebView" inRequest:_request];
    [NSURLProtocol removePropertyForKey:@"JSCustomWebView" inRequest:_request];
    
    self = [super initWithRequest:_request cachedResponse:cachedResponse client:client];
    if (self) {
        NSString *name = [[_request URL] lastPathComponent];
        NSString *path = [NSString stringWithFormat:@"js/%@", name];
        _data = [Utilities dataWithContentsOfPath:path];
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
    return @"application/javascript";
}

@end
