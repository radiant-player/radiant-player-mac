/*
 * SpriteDownloadURLProtocol.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomWebView.h"

@interface SpriteDownloadURLProtocol : NSURLProtocol {
    CustomWebView *_delegate;
    NSURLConnection *_connection;
    NSMutableData *_data;
}

@end
