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

#import "PSWebSocketServer.h"
#import "PSwebSocket.h"
#import "PSWebSocketDriver.h"
#import "PSWebSocketInternal.h"
#import "PSWebSocketBuffer.h"
#import "PSWebSocketNetworkThread.h"
#import <CFNetwork/CFNetwork.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <arpa/inet.h>

typedef NS_ENUM(NSInteger, PSWebSocketServerConnectionReadyState) {
    PSWebSocketServerConnectionReadyStateConnecting = 0,
    PSWebSocketServerConnectionReadyStateOpen,
    PSWebSocketServerConnectionReadyStateClosing,
    PSWebSocketServerConnectionReadyStateClosed
};

@interface PSWebSocketServerConnection : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, assign) PSWebSocketServerConnectionReadyState readyState;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) BOOL inputStreamOpenCompleted;
@property (nonatomic, assign) BOOL outputStreamOpenCompleted;
@property (nonatomic, strong) PSWebSocketBuffer *inputBuffer;
@property (nonatomic, strong) PSWebSocketBuffer *outputBuffer;

@end
@implementation PSWebSocketServerConnection

- (instancetype)init {
    if((self = [super init])) {
        _identifier = [[NSProcessInfo processInfo] globallyUniqueString];
        _readyState = PSWebSocketServerConnectionReadyStateConnecting;
        _inputBuffer = [[PSWebSocketBuffer alloc] init];
        _outputBuffer = [[PSWebSocketBuffer alloc] init];
    }
    return self;
}

@end


void PSWebSocketServerAcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@interface PSWebSocketServer() <NSStreamDelegate, PSWebSocketDelegate> {
    PSWebSocketNetworkThread *_networkThread;
    dispatch_queue_t _workQueue;
    
    NSData *_addrData;
    CFSocketContext _socketContext;
    
    BOOL _running;
    CFSocketRef _socket;
    CFRunLoopSourceRef _socketRunLoopSource;
    
    NSMutableSet *_connections;
    NSMapTable *_connectionsByStreams;
    
    NSMutableSet *_webSockets;
}
@end
@implementation PSWebSocketServer

#pragma mark - Properties

- (NSRunLoop *)runLoop {
    if(!_networkThread) {
        _networkThread = [[PSWebSocketNetworkThread alloc] init];
    }
    return _networkThread.runLoop;
}

#pragma mark - Initialization

+ (instancetype)serverWithHost:(NSString *)host port:(NSUInteger)port {
    return [[self alloc] initWithHost:host port:port];
}
- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port {
    NSParameterAssert(port);
    if((self = [super init])) {
        _networkThread = [[PSWebSocketNetworkThread alloc] init];
        _workQueue = dispatch_queue_create(nil, nil);
        
        // create addr data
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        if(host && ![host isEqualToString:@"0.0.0.0"]) {
            addr.sin_addr.s_addr = inet_addr(host.UTF8String);
            if(!addr.sin_addr.s_addr) {
                [NSException raise:@"Invalid host" format:@"Could not formulate internet address from host: %@", host];
                return nil;
            }
        } else {
            addr.sin_addr.s_addr = htonl(INADDR_ANY);
        }
        addr.sin_port = htons(port);
        _addrData = [NSData dataWithBytes:&addr length:sizeof(addr)];
        
        // create socket context
        _socketContext = (CFSocketContext){0, (__bridge void *)self, NULL, NULL, NULL};
        
        _connections = [NSMutableSet set];
        _connectionsByStreams = [NSMapTable weakToWeakObjectsMapTable];
        
        _webSockets = [NSMutableSet set];
        
    }
    return self;
}

#pragma mark - Actions

- (void)start {
    [self executeWork:^{
        [self connect:NO];
    }];
}
- (void)stop {
    [self executeWork:^{
        [self disconnectGracefully:NO];
    }];
}

#pragma mark - Connection

- (void)connect:(BOOL)silent {
    if(_running) {
        return;
    }
    
    // create socket
    _socket = CFSocketCreate(kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketAcceptCallBack,
                             PSWebSocketServerAcceptCallback,
                             &_socketContext);
    // configure socket
    int yes = 1;
    setsockopt(CFSocketGetNative(_socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    
    // bind
    CFSocketError err = CFSocketSetAddress(_socket, (__bridge CFDataRef)_addrData);
    if(err == kCFSocketError) {
        return;
    } else if(err == kCFSocketTimeout) {
        return;
    }
    
    // schedule
    _socketRunLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
    
    CFRunLoopRef runLoop = [[self runLoop] getCFRunLoop];
    CFRunLoopAddSource(runLoop, _socketRunLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoop);
    
    _running = YES;
    
    if(!silent) {
        [self notifyDelegateDidStart];
    }
}
- (void)disconnectGracefully:(BOOL)silent {
    if(!_running) {
        return;
    }
    
    for(PSWebSocketServerConnection *connection in _connections.allObjects) {
        [self disconnectConnectionGracefully:connection statusCode:500 description:@"Service Going Away"];
    }
    for(PSWebSocket *webSocket in _webSockets.allObjects) {
        [webSocket close];
    }
    
    [self pumpOutput];
    
    // disconnect
    [self executeWork:^{
        [self disconnect:silent];
    }];
    
    _running = NO;
}
- (void)disconnect:(BOOL)silent {
    if(_socketRunLoopSource) {
        CFRunLoopRef runLoop = [[self runLoop] getCFRunLoop];
        CFRunLoopRemoveSource(runLoop, _socketRunLoopSource, kCFRunLoopDefaultMode);
        CFRelease(runLoop);
        CFRelease(_socketRunLoopSource);
        _socketRunLoopSource = nil;
    }
    
    if(_socket) {
        if(CFSocketIsValid(_socket)) {
            CFSocketInvalidate(_socket);
        }
        CFRelease(_socket);
        _socket = nil;
    }
    
    _running = NO;
    
    if(!silent) {
        [self notifyDelegateDidStop];
    }
}

#pragma mark - Accepting

- (void)accept:(CFSocketNativeHandle)handle {
    [self executeWork:^{
        // create streams
        CFReadStreamRef readStream = nil;
        CFWriteStreamRef writeStream = nil;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, &readStream, &writeStream);
        
        // fail if we couldn't get streams
        if(!readStream || !writeStream) {
            return;
        }
        
        // configure streams
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        // create connection
        PSWebSocketServerConnection *connection = [[PSWebSocketServerConnection alloc] init];
        connection.inputStream = CFBridgingRelease(readStream);
        connection.outputStream = CFBridgingRelease(writeStream);
        
        // attach connection
        [self attachConnection:connection];
        
        // open
        [connection.inputStream open];
        [connection.outputStream open];
        
    }];
}

#pragma mark - WebSockets

- (void)attachWebSocket:(PSWebSocket *)webSocket {
    if([_webSockets containsObject:webSocket]) {
        return;
    }
    [_webSockets addObject:webSocket];
    webSocket.delegate = self;
}
- (void)detachWebSocket:(PSWebSocket *)webSocket {
    if(![_webSockets containsObject:webSocket]) {
        return;
    }
    [_webSockets removeObject:webSocket];
    webSocket.delegate = nil;
}

#pragma mark - PSWebSocketDelegate

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [self notifyDelegateWebSocketDidOpen:webSocket];
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    [self notifyDelegateWebSocket:webSocket didReceiveMessage:message];
}
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self detachWebSocket:webSocket];
    [self notifyDelegateWebSocket:webSocket didFailWithError:error];
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self detachWebSocket:webSocket];
    [self notifyDelegateWebSocket:webSocket didCloseWithCode:code reason:reason wasClean:wasClean];
}

#pragma mark - Connections

- (void)attachConnection:(PSWebSocketServerConnection *)connection {
    if([_connections containsObject:connection]) {
        return;
    }
    [_connections addObject:connection];
    [_connectionsByStreams setObject:connection forKey:connection.inputStream];
    [_connectionsByStreams setObject:connection forKey:connection.outputStream];
    connection.inputStream.delegate = self;
    connection.outputStream.delegate = self;
    [connection.inputStream scheduleInRunLoop:[self runLoop] forMode:NSRunLoopCommonModes];
    [connection.outputStream scheduleInRunLoop:[self runLoop] forMode:NSRunLoopCommonModes];
}
- (void)detatchConnection:(PSWebSocketServerConnection *)connection {
    if(![_connections containsObject:connection]) {
        return;
    }
    [_connections removeObject:connection];
    [_connectionsByStreams removeObjectForKey:connection.inputStream];
    [_connectionsByStreams removeObjectForKey:connection.outputStream];
    [connection.inputStream removeFromRunLoop:[self runLoop] forMode:NSRunLoopCommonModes];
    [connection.outputStream removeFromRunLoop:[self runLoop] forMode:NSRunLoopCommonModes];
    connection.inputStream.delegate = nil;
    connection.outputStream.delegate = nil;
}
- (void)disconnectConnectionGracefully:(PSWebSocketServerConnection *)connection statusCode:(NSInteger)statusCode description:(NSString *)description {
    if(connection.readyState >= PSWebSocketServerConnectionReadyStateClosing) {
        return;
    }
    connection.readyState = PSWebSocketServerConnectionReadyStateClosing;
    CFHTTPMessageRef msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, (__bridge CFStringRef)description, kCFHTTPVersion1_1);
    NSData *data = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(msg));
    CFRelease(msg);
    [connection.outputBuffer appendData:data];
    [self pumpOutput];
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), _workQueue, ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf disconnectConnection:connection];
        }
    });
}
- (void)disconnectConnection:(PSWebSocketServerConnection *)connection {
    if(connection.readyState == PSWebSocketServerConnectionReadyStateClosed) {
        return;
    }
    connection.readyState = PSWebSocketServerConnectionReadyStateClosed;
    [self detatchConnection:connection];
    [connection.inputStream close];
    [connection.outputStream close];
}

#pragma mark - Pumping

- (void)pumpInput {
    uint8_t chunkBuffer[4096];
    for(PSWebSocketServerConnection *connection in _connections.allObjects) {
        if(connection.readyState != PSWebSocketServerConnectionReadyStateOpen ||
           !connection.inputStream.hasBytesAvailable) {
            continue;
        }
        
        while(connection.inputStream.hasBytesAvailable) {
            NSInteger readLength = [connection.inputStream read:chunkBuffer maxLength:sizeof(chunkBuffer)];
            if(readLength > 0) {
                [connection.inputBuffer appendBytes:chunkBuffer length:readLength];
            } else if(readLength < 0) {
                [self disconnectConnection:connection];
            }
            if(readLength < sizeof(chunkBuffer)) {
                break;
            }
        }
        
        if(connection.inputBuffer.bytesAvailable > 4) {
            uint8_t boundary[] = {'\r', '\n','\r', '\n'};
            NSUInteger boundaryOffset = 0;
            NSUInteger matched = 0;
            for(NSUInteger i = 0; i < connection.inputBuffer.bytesAvailable; ++i) {
                const uint8_t byte = ((const uint8_t *)connection.inputBuffer.bytes)[i];
                const uint8_t boundaryByte = boundary[matched];
                if(byte == boundaryByte) {
                    if(++matched == sizeof(boundary)) {
                        boundaryOffset = i + 1;
                        break;
                    }
                } else {
                    matched = 0;
                }
            }
            if(boundaryOffset == 0) {
                if(connection.inputBuffer.bytesAvailable >= 16384) {
                    [self disconnectConnection:connection];
                }
                continue;
            }
            
            CFHTTPMessageRef msg = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
            CFHTTPMessageAppendBytes(msg, connection.inputBuffer.bytes, connection.inputBuffer.bytesAvailable);
            if(!CFHTTPMessageIsHeaderComplete(msg)) {
                [self disconnectConnection:connection];
                CFRelease(msg);
                continue;
            }
            
            // move input buffer
            connection.inputBuffer.offset += boundaryOffset;
            if(connection.inputBuffer.hasBytesAvailable) {
                [self disconnectConnection:connection];
                CFRelease(msg);
                continue;
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:CFBridgingRelease(CFHTTPMessageCopyRequestURL(msg))];
            request.HTTPMethod = CFBridgingRelease(CFHTTPMessageCopyRequestMethod(msg));
            
            NSDictionary *headers = CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(msg));
            [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [request setValue:obj forHTTPHeaderField:key];
            }];
            
            if(![PSWebSocket isWebSocketRequest:request]) {
                [self disconnectConnection:connection];
                CFRelease(msg);
                continue;
            }
            
            if(_delegate) {
                __block BOOL accept = NO;
                [self executeDelegateAndWait:^{
                    accept = [_delegate server:self acceptWebSocketWithRequest:request];
                }];
                if(!accept) {
                    [self disconnectConnection:connection];
                    CFRelease(msg);
                    continue;
                }
            }
            
            // detach connection
            [self detatchConnection:connection];
            
            // create webSocket
            PSWebSocket *webSocket = [PSWebSocket serverSocketWithRequest:request inputStream:connection.inputStream outputStream:connection.outputStream];
            
            // attach webSocket
            [self attachWebSocket:webSocket];
            
            // open webSocket
            [webSocket open];
            
            // clean up
            CFRelease(msg);
        }
    }
}
- (void)pumpOutput {
    for(PSWebSocketServerConnection *connection in _connections.allObjects) {
        if(connection.readyState != PSWebSocketServerConnectionReadyStateOpen &&
           connection.readyState != PSWebSocketServerConnectionReadyStateClosing) {
            continue;
        }
        
        while(connection.outputStream.hasSpaceAvailable && connection.outputBuffer.hasBytesAvailable) {
            NSInteger writeLength = [connection.outputStream write:connection.outputBuffer.bytes maxLength:connection.outputBuffer.bytesAvailable];
            if(writeLength > 0) {
                connection.outputBuffer.offset += writeLength;
            } else if(writeLength < 0) {
                [self disconnectConnection:connection];
                break;
            }
            
            if(writeLength == 0) {
                break;
            }
        }
        
        if(connection.readyState == PSWebSocketServerConnectionReadyStateClosing &&
           !connection.outputBuffer.hasBytesAvailable) {
            [self disconnectConnection:connection];
        }
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    [self executeWork:^{
        if(stream.delegate != self) {
            [stream.delegate stream:stream handleEvent:event];
            return;
        }
        
        PSWebSocketServerConnection *connection = [_connectionsByStreams objectForKey:stream];
        NSAssert(connection, @"Connection should not be nil");
        
        if(event == NSStreamEventOpenCompleted) {
            if(stream == connection.inputStream) {
                connection.inputStreamOpenCompleted = YES;
            } else if(stream == connection.outputStream) {
                connection.outputStreamOpenCompleted = YES;
            }
        }
        if(!connection.inputStreamOpenCompleted || !connection.outputStreamOpenCompleted) {
            return;
        }
        
        switch(event) {
            case NSStreamEventOpenCompleted: {
                if(connection.readyState == PSWebSocketServerConnectionReadyStateConnecting) {
                    connection.readyState = PSWebSocketServerConnectionReadyStateOpen;
                }
                [self pumpInput];
                [self pumpOutput];
                break;
            }
            case NSStreamEventErrorOccurred: {
                [self disconnectConnection:connection];
                break;
            }
            case NSStreamEventEndEncountered: {
                [self disconnectConnection:connection];
                break;
            }
            case NSStreamEventHasBytesAvailable: {
                [self pumpInput];
                break;
            }
            case NSStreamEventHasSpaceAvailable: {
                [self pumpOutput];
                break;
            }
            default:
                break;
        }
    }];
}

#pragma mark - Delegation

- (void)notifyDelegateDidStart {
    [self executeDelegate:^{
        [_delegate serverDidStart:self];
    }];
}
- (void)notifyDelegateDidStop {
    [self executeDelegate:^{
        [_delegate serverDidStop:self];
    }];
}

- (void)notifyDelegateWebSocketDidOpen:(PSWebSocket *)webSocket {
    [self executeDelegate:^{
        [_delegate server:self webSocketDidOpen:webSocket];
    }];
}
- (void)notifyDelegateWebSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    [self executeDelegate:^{
        [_delegate server:self webSocket:webSocket didReceiveMessage:message];
    }];
}

- (void)notifyDelegateWebSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self executeDelegate:^{
        [_delegate server:self webSocket:webSocket didFailWithError:error];
    }];
}
- (void)notifyDelegateWebSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self executeDelegate:^{
        [_delegate server:self webSocket:webSocket didCloseWithCode:code reason:reason wasClean:wasClean];
    }];
}

#pragma mark - Queueing

- (void)executeWork:(void (^)(void))work {
    NSParameterAssert(work);
    dispatch_async(_workQueue, work);
}
- (void)executeWorkAndWait:(void (^)(void))work {
    NSParameterAssert(work);
    dispatch_sync(_workQueue, work);
}
- (void)executeDelegate:(void (^)(void))work {
    NSParameterAssert(work);
    dispatch_async((_delegateQueue) ? _delegateQueue : dispatch_get_main_queue(), work);
}
- (void)executeDelegateAndWait:(void (^)(void))work {
    NSParameterAssert(work);
    dispatch_sync((_delegateQueue) ? _delegateQueue : dispatch_get_main_queue(), work);
}

@end

void PSWebSocketServerAcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    [(__bridge PSWebSocketServer *)info accept:*(CFSocketNativeHandle *)data];
}
