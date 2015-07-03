/*
 * WebComponentsURLProtocol.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import "CustomWebView.h"
#import "Utilities.h"

@interface WebComponentsURLProtocol : NSURLProtocol {
    CustomWebView *_delegate;
    NSData *_data;
    NSMutableURLRequest *_request;
}

- (NSString *)mimeTypeFromURL:(NSURL *)url;

@end
