/*
 * InvertedSpriteURLProtocol.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import "CustomWebView.h"

@interface InvertedSpriteURLProtocol : NSURLProtocol {
    CustomWebView *_delegate;
    NSData *_data;
    NSMutableURLRequest *_request;
}

@end
