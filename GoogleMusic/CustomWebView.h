//
//  CustomWebView.h
//  Google Music
//
//  Created by James Fator on 10/7/13.
//  Copyright (c) 2013 James Fator. All rights reserved.
//

#import <WebKit/WebKit.h>

@protocol CustomWebViewDelegate

@end

@interface CustomWebView : WebView

@property (nonatomic, strong) id<CustomWebViewDelegate> appDelegate;

@end
