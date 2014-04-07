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
        NSString *path = [NSString stringWithFormat:@"images/%@", name];
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

- (NSString *)mimeTypeFromURL:(NSURL *)url
{
    NSString *extension = [[url pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"png"])
        return @"image/png";
    
    if ([extension isEqualToString:@"jpg"])
        return @"image/jpeg";
    
    if ([extension isEqualToString:@"gif"])
        return @"image/gif";
}

@end
