/*
 * WebComponentsURLProtocol.m
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "WebComponentsURLProtocol.h"

@implementation WebComponentsURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest*)request
{
    CustomWebView *delegate = [NSURLProtocol propertyForKey:@"WebComponentsCustomWebView" inRequest:request];
    return (delegate != nil);
}

- (id) initWithRequest:(NSURLRequest*)theRequest cachedResponse:(NSCachedURLResponse*)cachedResponse client:(id<NSURLProtocolClient>)client
{
    // Move the delegate from the request to this instance
    _request = (NSMutableURLRequest *)theRequest;
    _delegate = [NSURLProtocol propertyForKey:@"WebComponentsCustomWebView" inRequest:_request];
    [NSURLProtocol removePropertyForKey:@"WebComponentsCustomWebView" inRequest:_request];
    
    self = [super initWithRequest:_request cachedResponse:cachedResponse client:client];
    if (self) {
        _data = [Utilities dataWithContentsOfPath:@"js/webcomponents.js"];
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
