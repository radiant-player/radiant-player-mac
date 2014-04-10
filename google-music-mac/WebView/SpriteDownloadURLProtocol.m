/*
 * SpriteDownloadURLProtocol.m
 *
 * Created by Sajid Anwar.
 *
 * Many, many thanks to @starkos at Stack Overflow:
 * http://stackoverflow.com/a/5103892/406330
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import "SpriteDownloadURLProtocol.h"

@implementation SpriteDownloadURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest*)request
{
    CustomWebView *delegate = [NSURLProtocol propertyForKey:@"OriginalCustomWebView" inRequest:request];
    
    if (delegate != nil) {
        return [delegate invertedSpriteSheet] == nil;
    }
    
    return NO;
}

- (id) initWithRequest:(NSURLRequest*)theRequest cachedResponse:(NSCachedURLResponse*)cachedResponse client:(id<NSURLProtocolClient>)client
{
    // Move the delegate from the request to this instance
    NSMutableURLRequest* req = (NSMutableURLRequest*)theRequest;
    _delegate = [NSURLProtocol propertyForKey:@"OriginalCustomWebView" inRequest:req];
    [NSURLProtocol removePropertyForKey:@"OriginalCustomWebView" inRequest:req];
    
    self = [super initWithRequest:req cachedResponse:cachedResponse client:client];
    if (self) {
        _data = [NSMutableData data];
    }
    return self;
}

- (void) startLoading
{
    _connection = [NSURLConnection connectionWithRequest:[self request] delegate:self];
}

- (void) stopLoading
{
    [_connection cancel];
}

- (void)connection:(NSURLConnection*)conn didReceiveResponse:(NSURLResponse*)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:[[self request] cachePolicy]];
    [_data setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)conn
{
    [[self client] URLProtocolDidFinishLoading:self];
    
    // Process the data to invert it and provide it to the app delegate.
    CIContext *context = [[CIContext alloc] init];
    CIImage *image = [CIImage imageWithData:_data];
    CIFilter *invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
    [invertFilter setDefaults];
    [invertFilter setValue:image forKey:kCIInputImageKey];
    CIImage *result = [invertFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgimage = [context createCGImage:result fromRect:[result extent]];
    
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)(data), kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(dest, cgimage, NULL);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
    // Forward the response to your delegate however you like
    if (_delegate) {
        [_delegate setInvertedSpriteSheet:[data copy]];
    }
}

- (NSURLRequest*)connection:(NSURLConnection*)connection willSendRequest:(NSURLRequest*)theRequest redirectResponse:(NSURLResponse*)redirectResponse
{
    return theRequest;
}

- (void)connection:(NSURLConnection*)conn didFailWithError:(NSError*)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

@end
