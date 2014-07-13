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
#import "PSWebSocketTypes.h"

typedef NS_ENUM(NSInteger, PSWebSocketReadyState) {
    PSWebSocketReadyStateConnecting = 0,
    PSWebSocketReadyStateOpen,
    PSWebSocketReadyStateClosing,
    PSWebSocketReadyStateClosed
};

@class PSWebSocket;

/**
 *  PSWebSocketDelegate
 */
@protocol PSWebSocketDelegate <NSObject>

@required
- (void)webSocketDidOpen:(PSWebSocket *)webSocket;
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message;
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

/**
 *  PSWebSocket
 */
@interface PSWebSocket : NSObject

#pragma mark - Class Methods

/**
 *  Given a NSURLRequest determine if it is a websocket request based on it's headers
 *
 *  @param request request to check
 *
 *  @return whether or not the given request is a websocket request
 */
+ (BOOL)isWebSocketRequest:(NSURLRequest *)request;

#pragma mark - Properties

@property (nonatomic, assign, readonly) PSWebSocketReadyState readyState;
@property (nonatomic, weak) id <PSWebSocketDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

#pragma mark - Initialization

/**
 *  Initialize a PSWebSocket instance in client mode.
 *
 *  @param request that is to be used to initiate the handshake
 *
 *  @return an initialized instance of PSWebSocket in client mode
 */
+ (instancetype)clientSocketWithRequest:(NSURLRequest *)request;

/**
 *  Initialize a PSWebSocket instance in server mode
 *
 *  @param request      request that is to be used to initiate the handshake response
 *  @param inputStream  opened input stream to be taken over by the websocket
 *  @param outputStream opened output stream to be taken over by the websocket
 *
 *  @return an initialized instance of PSWebSocket in server mode
 */
+ (instancetype)serverSocketWithRequest:(NSURLRequest *)request inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

#pragma mark - Actions

/**
 *  Opens the websocket connection and initiates the handshake. Once
 *  opened an instance of PSWebSocket can never be opened again. The
 *  connection obeys any timeout interval set on the NSURLRequest used
 *  to initialize the websocket.
 */
- (void)open;

/**
 *  Send a message over the websocket
 *
 *  @param message an instance of NSData or NSString to send
 */
- (void)send:(id)message;

/**
 *  Send a ping over the websocket
 *
 *  @param pingData data to include with the ping
 *  @param handler  optional callback handler when the corrosponding pong is received
 */
- (void)ping:(NSData *)pingData handler:(void (^)(NSData *pongData))handler;


/**
 *  Close the websocket will default to code 1000 and nil reason
 */
- (void)close;

/**
 *  Close the websocket with a specific code and/or reason
 *
 *  @param code   close code reason
 *  @param reason short textual reason why the connection was closed
 */
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

@end
