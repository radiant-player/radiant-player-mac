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
        // Convert the inverted sprite sheet to data.
        NSImage *inverted = [_delegate invertedSpriteSheet];
        [inverted lockFocus] ;
        NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [inverted size].width, [inverted size].height)] ;
        _data = [imgRep representationUsingType: NSPNGFileType properties: nil];
        [inverted unlockFocus] ;
    }
    return self;
}

- (void)startLoading
{
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[_request URL] MIMEType:@"image/png" expectedContentLength:[_data length] textEncodingName:nil];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
    [[self client] URLProtocol:self didLoadData:_data];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{

}

@end
