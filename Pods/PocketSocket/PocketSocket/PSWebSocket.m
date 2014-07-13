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

#import "PSWebSocket.h"
#import "PSWebSocketNetworkThread.h"
#import "PSWebSocketInternal.h"
#import "PSWebSocketDriver.h"
#import "PSWebSocketBuffer.h"

@interface PSWebSocket() <NSStreamDelegate, PSWebSocketDriverDelegate> {
    PSWebSocketMode _mode;
    NSMutableURLRequest *_request;
    dispatch_queue_t _workQueue;
    PSWebSocketDriver *_driver;
    PSWebSocketBuffer *_inputBuffer;
    PSWebSocketBuffer *_outputBuffer;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    PSWebSocketReadyState _readyState;
    BOOL _secure;
    BOOL _opened;
    BOOL _closeWhenFinishedOutput;
    BOOL _sentClose;
    BOOL _failed;
    BOOL _pumpingInput;
    BOOL _pumpingOutput;
    NSInteger _closeCode;
    NSString *_closeReason;
    NSMutableArray *_pingHandlers;
}
@end
@implementation PSWebSocket

#pragma mark - Class Methods

+ (BOOL)isWebSocketRequest:(NSURLRequest *)request {
    return [PSWebSocketDriver isWebSocketRequest:request];
}

#pragma mark - Class Properties

+ (NSRunLoop *)runLoop {
    return [[PSWebSocketNetworkThread sharedNetworkThread] runLoop];
}

#pragma mark - Properties

@dynamic readyState;

#pragma mark - Initialization

- (instancetype)initWithMode:(PSWebSocketMode)mode request:(NSURLRequest *)request {
	if((self = [super init])) {
        _mode = mode;
        _request = [request mutableCopy];
		_readyState = PSWebSocketReadyStateConnecting;
        _workQueue = dispatch_queue_create(nil, nil);
        if(_mode == PSWebSocketModeClient) {
            _driver = [PSWebSocketDriver clientDriverWithRequest:_request];
        } else {
            _driver = [PSWebSocketDriver serverDriverWithRequest:_request];
        }
        _driver.delegate = self;
        _secure = ([_request.URL.scheme hasPrefix:@"https"] || [_request.URL.scheme hasPrefix:@"wss"]);
        _opened = NO;
        _closeWhenFinishedOutput = NO;
        _sentClose = NO;
        _failed = NO;
        _pumpingInput = NO;
        _pumpingOutput = NO;
        _closeCode = 0;
        _closeReason = nil;
        _pingHandlers = [NSMutableArray array];
        _inputBuffer = [[PSWebSocketBuffer alloc] init];
        _outputBuffer = [[PSWebSocketBuffer alloc] init];
        if(_request.HTTPBody.length > 0) {
            [_inputBuffer appendData:_request.HTTPBody];
            _request.HTTPBody = nil;
        }
	}
	return self;
}

+ (instancetype)clientSocketWithRequest:(NSURLRequest *)request {
    return [[self alloc] initClientSocketWithRequest:request];
}
- (instancetype)initClientSocketWithRequest:(NSURLRequest *)request {
	if((self = [self initWithMode:PSWebSocketModeClient request:request])) {
        NSURL *URL = request.URL;
        NSString *host = URL.host;
        UInt32 port = (UInt32)request.URL.port.integerValue;
        if(port == 0) {
            port = (_secure) ? 443 : 80;
        }
        
        CFReadStreamRef readStream = nil;
        CFWriteStreamRef writeStream = nil;
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           (__bridge CFStringRef)host,
                                           port,
                                           &readStream,
                                           &writeStream);
        NSAssert(readStream && writeStream, @"Failed to create streams for client socket");
        
        _inputStream = CFBridgingRelease(readStream);
        _outputStream = CFBridgingRelease(writeStream);
        
        if(_secure) {
            NSMutableDictionary *opts = [NSMutableDictionary dictionary];
            
            opts[(__bridge id)kCFStreamSSLLevel] = (__bridge id)kCFStreamSocketSecurityLevelNegotiatedSSL;
            
            // @TODO PINNED SSL
            
#if DEBUG
            opts[(__bridge id)kCFStreamSSLValidatesCertificateChain] = @NO;
            NSLog(@"PSWebSocket: debug mode allowing all SSL certificates");
#endif
            [_outputStream setProperty:opts forKey:(__bridge id)kCFStreamPropertySSLSettings];
        }
	}
	return self;
}

+ (instancetype)serverSocketWithRequest:(NSURLRequest *)request inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    return [[self alloc] initServerWithRequest:request inputStream:inputStream outputStream:outputStream];
}
- (instancetype)initServerWithRequest:(NSURLRequest *)request inputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    if((self = [self initWithMode:PSWebSocketModeServer request:request])) {
        _inputStream = inputStream;
        _outputStream = outputStream;
    }
    return self;
}

#pragma mark - Actions

- (void)open {
    [self executeWork:^{
        NSAssert(!_opened, @"You cannot open a PSWebSocket more than once");
        NSAssert(_readyState == PSWebSocketReadyStateConnecting, @"State should be connecting");
        _opened = YES;
        
        [self connect];
    }];
}
- (void)send:(id)message {
    NSParameterAssert(message);
    [self executeWork:^{
        if([message isKindOfClass:[NSString class]]) {
            [_driver sendText:message];
        } else if([message isKindOfClass:[NSData class]]) {
            [_driver sendBinary:message];
        } else {
            NSAssert(NO, @"You can only send text or binary data");
        }
    }];
}
- (void)ping:(NSData *)pingData handler:(void (^)(NSData *pongData))handler {
    [self executeWork:^{
        if(handler) {
            [_pingHandlers addObject:handler];
        }
        [_driver sendPing:pingData];
    }];
}
- (void)close {
    [self closeWithCode:1000 reason:nil];
}
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason {
    [self executeWork:^{
        // already closing so lets exit
        if(_readyState >= PSWebSocketReadyStateClosing) {
            return;
        }
        
        BOOL connecting = (_readyState == PSWebSocketReadyStateConnecting);
        _readyState = PSWebSocketReadyStateClosing;
        
        // if we were connecting lets disconnect quickly
        if(connecting) {
            [self disconnectGracefully];
            return;
        }
        
        // send close code
        [_driver sendCloseCode:code reason:reason];
    }];
}

#pragma mark - Connection

- (void)connect {
    // delegate
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    // driver
    [_driver start];
    
    // schedule streams
    [_inputStream scheduleInRunLoop:[[self class] runLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[[self class] runLoop] forMode:NSDefaultRunLoopMode];
    
    // open streams
    if(_inputStream.streamStatus == NSStreamStatusNotOpen) {
        [_inputStream open];
    }
    if(_outputStream.streamStatus == NSStreamStatusNotOpen) {
        [_outputStream open];
    }
    
    // pump
    [self pumpInput];
    [self pumpOutput];
    
    // prepare timeout
    if(_request.timeoutInterval > 0.0) {
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _request.timeoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if(strongSelf) {
                [strongSelf executeWork:^{
                    if(strongSelf->_readyState == PSWebSocketReadyStateConnecting) {
                        strongSelf->_readyState = PSWebSocketReadyStateClosing;
                        strongSelf->_closeCode = -1;
                        strongSelf->_closeReason = @"Timed out";
                        [strongSelf disconnectGracefully];
                    }
                }];
            }
        });
    }
}
- (void)disconnectGracefully {
    _closeWhenFinishedOutput = YES;
    [self pumpOutput];
}
- (void)disconnect {
    _inputStream.delegate = nil;
    _outputStream.delegate = nil;
    
    [_inputStream close];
    [_outputStream close];
    
    [_inputStream removeFromRunLoop:[[self class] runLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[[self class] runLoop] forMode:NSDefaultRunLoopMode];
    
    _inputStream = nil;
    _outputStream = nil;
}

#pragma mark - Pumping

- (void)pumpInput {
    if(_readyState >= PSWebSocketReadyStateClosing) {
        return;
    }
    if(_pumpingInput) {
        return;
    }
    _pumpingInput = YES;
    
    @autoreleasepool {
        uint8_t chunkBuffer[4096];
        while(_inputStream.hasBytesAvailable) {
            NSInteger readLength = [_inputStream read:chunkBuffer maxLength:sizeof(chunkBuffer)];
            if(readLength > 0) {
                if(!_inputBuffer.hasBytesAvailable) {
                    NSInteger consumedLength = [_driver execute:chunkBuffer maxLength:readLength];
                    if(consumedLength < readLength) {
                        NSInteger offset = MAX(0, consumedLength);
                        NSInteger remaining = readLength - offset;
                        [_inputBuffer appendBytes:chunkBuffer + offset length:remaining];
                    }
                } else {
                    [_inputBuffer appendBytes:chunkBuffer length:readLength];
                }
            } else if(readLength < 0) {
                [self failWithError:_inputStream.streamError];
                break;
            }
            if(readLength < sizeof(chunkBuffer)) {
                break;
            }
        }
        
        while(_inputBuffer.hasBytesAvailable) {
            NSInteger readLength = [_driver execute:_inputBuffer.mutableBytes maxLength:_inputBuffer.bytesAvailable];
            if(readLength <= 0) {
                break;
            }
            _inputBuffer.offset += readLength;
        }
        
        
        [_inputBuffer compact];
    }
    
    _pumpingInput = NO;
    if(_inputStream.hasBytesAvailable) {
        [self pumpInput];
    }
}
- (void)pumpOutput {
    if(_pumpingOutput) {
        return;
    }
    _pumpingOutput = YES;
    
    while(_outputStream.hasSpaceAvailable && _outputBuffer.hasBytesAvailable) {
        NSInteger writeLength = [_outputStream write:_outputBuffer.bytes maxLength:_outputBuffer.bytesAvailable];
        if(writeLength <= -1) {
            _failed = YES;
            [self disconnect];
            NSString *reason = @"Failed to write to output stream";
            NSError *error = [NSError errorWithDomain:PSWebSocketErrorDomain code:PSWebSocketErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: reason}];
            [self notifyDelegateDidFailWithError:error];
            return;
        }
        _outputBuffer.offset += writeLength;
    }
    if(_closeWhenFinishedOutput &&
       !_outputBuffer.hasBytesAvailable &&
       (_inputStream.streamStatus != NSStreamStatusNotOpen &&
        _inputStream.streamStatus != NSStreamStatusClosed) &&
       !_sentClose) {
        _sentClose = YES;
        
        [self disconnect];
        
        if(!_failed) {
            [self notifyDelegateDidCloseWithCode:_closeCode reason:_closeReason wasClean:YES];
        }
    }
    
    [_outputBuffer compact];
    
    _pumpingOutput = NO;
    if(_outputStream.hasSpaceAvailable && _outputBuffer.hasBytesAvailable) {
        [self pumpOutput];
    }
}

#pragma mark - Failing

- (void)failWithCode:(NSInteger)code reason:(NSString *)reason {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: reason};
    [self failWithError:[NSError errorWithDomain:PSWebSocketErrorDomain code:code userInfo:userInfo]];
}
- (void)failWithError:(NSError *)error {
    if(error.code == PSWebSocketStatusCodeProtocolError) {
        [self executeDelegate:^{
            _closeCode = error.code;
            _closeReason = error.localizedDescription;
            [self closeWithCode:_closeCode reason:_closeReason];
            [self executeWork:^{
                [self disconnectGracefully];
            }];
        }];
    } else {
        [self executeWork:^{
            if(_readyState != PSWebSocketReadyStateClosed) {
                _failed = YES;
                _readyState = PSWebSocketReadyStateClosed;
                [self notifyDelegateDidFailWithError:error];
                [self disconnectGracefully];
            }
        }];
    }
}

#pragma mark - PSWebSocketDriverDelegate

- (void)driverDidOpen:(PSWebSocketDriver *)driver {
    NSAssert(_readyState == PSWebSocketReadyStateConnecting, @"Ready state must be connecting to become open");
    _readyState = PSWebSocketReadyStateOpen;
    [self notifyDelegateDidOpen];
    [self pumpInput];
    [self pumpOutput];
}
- (void)driver:(PSWebSocketDriver *)driver didFailWithError:(NSError *)error {
    [self failWithError:error];
}
- (void)driver:(PSWebSocketDriver *)driver didCloseWithCode:(NSInteger)code reason:(NSString *)reason {
    _closeCode = code;
    _closeReason = reason;
    if(_readyState == PSWebSocketReadyStateOpen) {
        [self closeWithCode:1000 reason:nil];
    }
    [self executeWork:^{
        [self disconnectGracefully];
    }];
}
- (void)driver:(PSWebSocketDriver *)driver didReceiveMessage:(id)message {
    [self notifyDelegateDidReceiveMessage:message];
}
- (void)driver:(PSWebSocketDriver *)driver didReceivePing:(NSData *)ping {
    [self executeDelegate:^{
        [self executeWork:^{
            [driver sendPong:ping];
        }];
    }];
}
- (void)driver:(PSWebSocketDriver *)driver didReceivePong:(NSData *)pong {
    void (^handler)(NSData *pong) = [_pingHandlers firstObject];
    if(handler) {
        [self executeDelegate:^{
            handler(pong);
        }];
        [_pingHandlers removeObjectAtIndex:0];
    }
}
- (void)driver:(PSWebSocketDriver *)driver write:(NSData *)data {
    if(_closeWhenFinishedOutput) {
        return;
    }
    [_outputBuffer appendData:data];
    [self pumpOutput];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    // @TODO HANDLE PINNED SSL CERTIFICATES
    [self executeWork:^{
        switch(event) {
            case NSStreamEventOpenCompleted: {
                NSAssert(_mode == PSWebSocketModeClient, @"Server mode should have already opened streams.");
                if(_readyState >= PSWebSocketReadyStateClosing) {
                    return;
                }
                [self pumpOutput];
                [self pumpInput];
                break;
            }
            case NSStreamEventErrorOccurred: {
                [self failWithError:stream.streamError];
                [_inputBuffer reset];
                break;
            }
            case NSStreamEventEndEncountered: {
                [self pumpInput];
                if(stream.streamError) {
                    [self failWithError:stream.streamError];
                } else {
                    _readyState = PSWebSocketReadyStateClosed;
                    if(!_sentClose && !_failed) {
                        _failed = YES;
                        [self disconnect];
                        NSString *reason = [NSString stringWithFormat:@"%@ stream end encountered", (stream == _inputStream) ? @"Input" : @"Output"];
                        NSError *error = [NSError errorWithDomain:PSWebSocketErrorDomain code:PSWebSocketErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: reason}];
                        [self notifyDelegateDidFailWithError:error];
                    }
                }
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

- (void)notifyDelegateDidOpen {
    [self executeDelegate:^{
        [_delegate webSocketDidOpen:self];
    }];
}
- (void)notifyDelegateDidReceiveMessage:(id)message {
    [self executeDelegate:^{
        [_delegate webSocket:self didReceiveMessage:message];
    }];
}
- (void)notifyDelegateDidFailWithError:(NSError *)error {
    [self executeDelegate:^{
        [_delegate webSocket:self didFailWithError:error];
    }];
}
- (void)notifyDelegateDidCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self executeDelegate:^{
        [_delegate webSocket:self didCloseWithCode:code reason:reason wasClean:wasClean];
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

#pragma mark - Dealloc

- (void)dealloc {
    _delegate = nil;
    dispatch_barrier_sync(_workQueue, ^{});
}

@end
