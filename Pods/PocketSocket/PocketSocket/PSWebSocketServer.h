//  Copyright 2014 Zwopple Limited
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>
#import "PSWebSocket.h"

@class PSWebSocketServer;

@protocol PSWebSocketServerDelegate <NSObject>

@required

- (void)serverDidStart:(PSWebSocketServer *)server;
- (void)serverDidStop:(PSWebSocketServer *)server;

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request;
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket;
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message;
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

@interface PSWebSocketServer : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id <PSWebSocketServerDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

#pragma mark - Initialization

+ (instancetype)serverWithHost:(NSString *)host port:(NSUInteger)port;

#pragma mark - Actions

- (void)start;
- (void)stop;

@end
