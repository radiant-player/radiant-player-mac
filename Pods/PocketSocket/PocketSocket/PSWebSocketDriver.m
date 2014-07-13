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

#import "PSWebSocketDriver.h"
#import "PSWebSocketBuffer.h"
#import "PSWebSocketInflater.h"
#import "PSWebSocketDeflater.h"
#import "PSWebSocketBuffer.h"
#import "PSWebSocketUTF8Decoder.h"
#import "PSWebSocketInternal.h"
#if TARGET_OS_IPHONE
#import <Endian.h>
#endif
#import <CommonCrypto/CommonCrypto.h>

@interface PSWebSocketFrame : NSObject {
@public
    BOOL fin;
    BOOL rsv1;
    BOOL rsv2;
    BOOL rsv3;
    PSWebSocketOpCode opcode;
    BOOL masked;
    NSUInteger payloadLength;
    BOOL control;
    NSUInteger headerExtraLength;
    uint8_t maskKey[4];
    uint32_t maskOffset;
    NSMutableData *buffer;
    NSUInteger payloadRemainingLength;
}
@end
@implementation PSWebSocketFrame

@end

typedef NS_ENUM(NSInteger, PSWebSocketDriverState) {
    PSWebSocketDriverStateHandshakeRequest = 0,
    PSWebSocketDriverStateHandshakeResponse,
    PSWebSocketDriverStateFrameHeader,
    PSWebSocketDriverStateFrameHeaderExtra,
    PSWebSocketDriverStateFramePayload
};

@interface PSWebSocketDriver() {
    NSURLRequest *_request;
    PSWebSocketDriverState _state;
    
    BOOL _failed;
    
    NSString *_handshakeSecKey;
    
    PSWebSocketFrame *_initialFrame;
    NSMutableArray *_frames;
    
    BOOL _pmdEnabled;
    NSInteger _pmdClientWindowBits;
    BOOL _pmdClientNoContextTakeover;
    NSInteger _pmdServerWindowBits;
    BOOL _pmdServerNoContextTakeover;
    PSWebSocketInflater *_inflater;
    PSWebSocketDeflater *_deflater;
    
    uint32_t _utf8DecoderState;
    uint32_t _utf8DecoderCodePoint;
}
@end
@implementation PSWebSocketDriver

#pragma mark - Class Methods

+ (BOOL)isWebSocketRequest:(NSURLRequest *)request {
    NSDictionary *headers = request.allHTTPHeaderFields;
    if(headers[@"Sec-WebSocket-Key"] &&
       [headers[@"Sec-WebSocket-Version"] isEqualToString:@"13"] &&
       [[headers[@"Connection"] lowercaseString] isEqualToString:@"upgrade"] &&
       [[headers[@"Upgrade"] lowercaseString] isEqualToString:@"websocket"] &&
       [request.HTTPMethod.lowercaseString isEqualToString:@"get"] &&
       request.HTTPBody.length == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - Initialization

+ (instancetype)clientDriverWithRequest:(NSURLRequest *)request {
    return [[self alloc] initWithMode:PSWebSocketModeClient request:request];
}
+ (instancetype)serverDriverWithRequest:(NSURLRequest *)request {
    return [[self alloc] initWithMode:PSWebSocketModeServer request:request];
}
- (instancetype)initWithMode:(PSWebSocketMode)mode request:(NSURLRequest *)request {
    NSParameterAssert(request);
    if((self = [super init])) {
        _mode = mode;
        _state = (_mode == PSWebSocketModeClient) ? PSWebSocketDriverStateHandshakeRequest : PSWebSocketDriverStateHandshakeResponse;
        _request = [request mutableCopy];
        _frames = [NSMutableArray array];
        _utf8DecoderState = 0;
        _utf8DecoderCodePoint = 0;
        _pmdEnabled = YES;
        _pmdClientWindowBits = -11;
        _pmdServerWindowBits = -11;
    }
    return self;
}

#pragma mark - Actions

- (void)start {
    if(_mode == PSWebSocketModeClient) {
        [self writeHandshakeRequest];
    } else {
        [self writeHandshakeResponse];
    }
}
- (NSUInteger)execute:(void *)bytes maxLength:(NSUInteger)maxLength {
    // skip if failed
    if(_failed) {
        return 0;
    }
    
    // skip if 0 bytes
    if(maxLength <= 0) {
        return 0;
    }
    
    NSError *error = nil;
    NSInteger bytesRead = 0;
    NSUInteger totalBytesRead = 0;
    while(totalBytesRead < maxLength) {
        bytesRead = [self readBytes:bytes maxLength:maxLength - totalBytesRead error:&error];
        if(bytesRead < 0) {
            if(error) {
                [self failWithError:error];
            } else {
                [self failWithErrorCode:-1 reason:@"An unknown error occurred"];
            }
            break;
        } else if(bytesRead == 0) {
            break;
        }
        totalBytesRead += bytesRead;
        bytes += bytesRead;
    }
    return totalBytesRead;
}
- (void)sendText:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [self writeMessageWithOpCode:PSWebSocketOpCodeText data:data];
}
- (void)sendBinary:(NSData *)binary {
    [self writeMessageWithOpCode:PSWebSocketOpCodeBinary data:binary];
}
- (void)sendCloseCode:(NSInteger)code reason:(NSString *)reason {
    NSUInteger reasonMaxLength = [reason maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData dataWithLength:sizeof(uint16_t) + reasonMaxLength];
    uint8_t *dataBytes = (uint8_t *)data.mutableBytes;
    ((uint16_t *)dataBytes)[0] = EndianU16_BtoN(code);
    if(reason) {
        NSRange remainingRange = NSMakeRange(0, 0);
        NSUInteger usedLength = 0;
        BOOL success = [reason getBytes:dataBytes + sizeof(uint16_t)
                              maxLength:data.length - sizeof(uint16_t)
                             usedLength:&usedLength
                               encoding:NSUTF8StringEncoding
                                options:NSStringEncodingConversionExternalRepresentation
                                  range:NSMakeRange(0, reason.length)
                         remainingRange:&remainingRange];
        NSAssert(success, @"Failed to write reason when sending close frame");
        NSAssert(remainingRange.length == 0, @"Failed to write reason when sending close frame");
        
        success = YES;
        data.length = usedLength + sizeof(uint16_t);
    }
    [self writeMessageWithOpCode:PSWebSocketOpCodeClose data:data];
}
- (void)sendPing:(NSData *)data {
    [self writeMessageWithOpCode:PSWebSocketOpCodePing data:data];
}
- (void)sendPong:(NSData *)data {
    [self writeMessageWithOpCode:PSWebSocketOpCodePong data:data];
}

#pragma mark - Writing

- (void)writeHandshakeRequest {
    NSAssert(_mode == PSWebSocketModeClient, @"Cannot send handshake requests in non client mode");
    NSAssert(_state == PSWebSocketDriverStateHandshakeRequest, @"Cannot start a driver more than once");
    
    // set handshake sec key
    NSMutableData *secKeyData = [NSMutableData dataWithLength:16];
    SecRandomCopyBytes(kSecRandomDefault, secKeyData.length, secKeyData.mutableBytes);
    _handshakeSecKey = [secKeyData base64EncodedStringWithOptions:0];
    
    NSURL *URL = _request.URL;
    BOOL secure = ([URL.scheme isEqualToString:@"https"] || [URL.scheme isEqualToString:@"wss"]);
    NSString *host = (URL.port) ? [NSString stringWithFormat:@"%@:%@", URL.host, URL.port] : URL.host;
    NSString *origin = [NSString stringWithFormat:@"http%@://%@", (secure) ? @"s" : @"", host];
    
    CFHTTPMessageRef msg = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)URL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Host"), (__bridge CFStringRef)host);
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Connection"), CFSTR("upgrade"));
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Upgrade"), CFSTR("websocket"));
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Sec-WebSocket-Version"), CFSTR("13"));
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Sec-WebSocket-Key"), (__bridge CFStringRef)_handshakeSecKey);
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Origin"), (__bridge CFStringRef)origin);
    
    [_request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CFHTTPMessageSetHeaderFieldValue(msg, (__bridge CFStringRef)[NSString stringWithFormat:@"%@", key], (__bridge CFStringRef)[NSString stringWithFormat:@"%@", obj]);
    }];
    
    // extensions
    NSMutableArray *extensionComponents = [NSMutableArray array];
    [extensionComponents addObjectsFromArray:[self pmdExtensionsHeaderComponents]];
    if(extensionComponents.count > 0) {
        NSString *value = [extensionComponents componentsJoinedByString:@"; "];
        CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Sec-WebSocket-Extensions"), (__bridge CFStringRef)value);
    }
    
    // serialize
    NSData *handshakeData = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(msg));
    
    // write handshake
    [_delegate driver:self write:handshakeData];
    
    // clean up
    CFRelease(msg);
    
    // transition state
    _state = PSWebSocketDriverStateHandshakeResponse;
}
- (void)writeHandshakeResponse {
    NSAssert(_state == PSWebSocketDriverStateHandshakeResponse, @"Cannot start a driver more than once");
    
    // get headers
    NSDictionary *headers = _request.allHTTPHeaderFields;
    
    // validate is websocket
    if(![[self class] isWebSocketRequest:_request]) {
        [self failWithErrorCode:-1 reason:@"Invalid websocket request"];
        return;
    }
    
    // validate extensions
    NSArray *extensionComponents = [headers[@"Sec-WebSocket-Extensions"] componentsSeparatedByString:@"; "];
    if(![self pmdConfigureWithExtensionsHeaderComponents:extensionComponents]) {
        [self failWithErrorCode:PSWebSocketErrorCodeHandshakeFailed reason:@"invalid permessage-deflate extension parameters"];
        return;
    }
    
    // set key
    _handshakeSecKey = headers[@"Sec-WebSocket-Key"];
    
    // create response
    CFHTTPMessageRef msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 101, CFSTR("Switching Protocols"), kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Connection"), CFSTR("Upgrade"));
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Upgrade"), CFSTR("websocket"));
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Sec-WebSocket-Accept"), (__bridge CFStringRef)[self acceptHeaderForKey:_handshakeSecKey]);
    
    NSMutableArray *negotiatedExtensionComponents = [NSMutableArray array];
    [negotiatedExtensionComponents addObjectsFromArray:[self pmdExtensionsHeaderComponents]];
    if(negotiatedExtensionComponents.count > 0) {
        NSString *value = [negotiatedExtensionComponents componentsJoinedByString:@"; "];
        CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Sec-WebSocket-Extensions"), (__bridge CFStringRef)value);
    }
    
    // serialize
    NSData *handshakeData = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(msg));
    
    // write handshake
    [_delegate driver:self write:handshakeData];
    
    // clean up
    CFRelease(msg);
    
    // transition state
    _state = PSWebSocketDriverStateFrameHeader;
    
    // open
    [_delegate driverDidOpen:self];
}
- (void)writeMessageWithOpCode:(PSWebSocketOpCode)opcode data:(NSData *)data {
    // create header
    NSMutableData *header = [NSMutableData dataWithLength:2];
    uint8_t *headerBytes = header.mutableBytes;
    
    headerBytes[0] |= PSWebSocketFinMask;
    //  headerBytes[0] |= (ZWPWebSocketRsv2Mask);
    //  headerBytes[0] |= (ZWPWebSocketRsv3Mask);
    headerBytes[0] |= (PSWebSocketOpCodeMask & opcode);
    
    // determine payload payload
    id payload = data;
    
    // deflate payload
    if(_pmdEnabled && !PSWebSocketOpCodeIsControl(opcode) && [payload length] > 0) {
        // reset deflater if needed
        if((_pmdClientNoContextTakeover && _mode == PSWebSocketModeClient) ||
           (_pmdServerNoContextTakeover && _mode == PSWebSocketModeServer)) {
            [_deflater reset];
        }
        
        // create deflate buffer
        NSMutableData *deflated = [NSMutableData dataWithCapacity:ceil([payload length]/4.0)];
        
        // error
        NSError *error = nil;
        
        // begin deflater
        if(![_deflater begin:deflated error:&error]) {
            NSAssert(NO, error.localizedDescription);
            [self failWithError:error];
            [_deflater reset];
            return;
        }
        
        // append bytes
        if(![_deflater appendBytes:[payload bytes] length:[payload length] error:&error]) {
            NSAssert(NO, error.localizedDescription);
            [self failWithError:error];
            [_deflater reset];
            return;
        }
        
        // end deflater
        if(![_deflater end:&error]) {
            NSAssert(NO, error.localizedDescription);
            [self failWithError:error];
            [_deflater reset];
            return;
        }
        
        // reassign data
        payload = deflated;
        
        // set rsv1 mask
        headerBytes[0] |= PSWebSocketRsv1Mask;
    }
    
    // set payload length data
    if([payload length] < 126) {
        headerBytes[1] |= [payload length];
    } else if([payload length] <= UINT16_MAX) {
        headerBytes[1] |= 126;
        uint16_t len = EndianU16_BtoN((uint16_t)[payload length]);
        [header appendBytes:&len length:sizeof(len)];
    } else {
        headerBytes[1] |= 127;
        uint64_t len = EndianU64_BtoN((uint64_t)[payload length]);
        [header appendBytes:&len length:sizeof(len)];
    }
    
    // set masking data
    if(_mode == PSWebSocketModeClient) {
        headerBytes[1] |= PSWebSocketMaskMask;
        
        uint8_t maskKey[4];
        SecRandomCopyBytes(kSecRandomDefault, sizeof(maskKey), maskKey);
        [header appendBytes:maskKey length:sizeof(maskKey)];
        
        // make copy if not already mutable
        if(![payload isKindOfClass:[NSMutableData class]]) {
            payload = [payload mutableCopy];
        }
        
        // mask payload inplace
        uint8_t *payloadBytes = (uint8_t *)[payload mutableBytes];
        for(NSUInteger i = 0; i < [payload length]; ++i) {
            payloadBytes[i] = payloadBytes[i] ^ maskKey[i % sizeof(maskKey)];
        }
    }
    
    // write data to delegate
    [_delegate driver:self write:header];
    [_delegate driver:self write:payload];
}

#pragma mark - Reading

- (NSInteger)readBytes:(void *)bytes maxLength:(NSUInteger)maxLength error:(NSError *__autoreleasing *)outError {
    NSAssert(maxLength > 0, @"Must have 1 or more bytes");
    switch(_state) {
        //
        // HANDSHAKE RESPONSE
        //
        case PSWebSocketDriverStateHandshakeResponse: {
            NSAssert(maxLength > 0, @"Must have 1 or more bytes");
            NSAssert(_state == PSWebSocketDriverStateHandshakeResponse, @"Invalid state for reading handshake response");
            
            uint8_t boundary[] = {'\r', '\n','\r', '\n'};
            NSUInteger preBoundaryLength = 0;
            NSUInteger matched = 0;
            for(NSUInteger i = 0; i < maxLength; ++i) {
                const uint8_t byte = ((const uint8_t *)bytes)[i];
                const uint8_t boundaryByte = boundary[matched];
                if(byte == boundaryByte) {
                    if(++matched == sizeof(boundary)) {
                        preBoundaryLength = i + 1;
                        break;
                    }
                } else {
                    matched = 0;
                }
            }
            if(preBoundaryLength == 0) {
                // do not allow too much data for headers
                if(maxLength >= 16384) {
                    PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"HTTP headers did not finish after reading 16384 bytes");
                    return -1;
                }
                return 0;
            }
            
            // create handshake
            CFHTTPMessageRef msg = CFHTTPMessageCreateEmpty(NULL, NO);
            CFHTTPMessageAppendBytes(msg, (const UInt8 *)bytes, preBoundaryLength);
            
            
            // validate complete
            if(!CFHTTPMessageIsHeaderComplete(msg)) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"HTTP headers found CRLFCRLF but not complete");
                CFRelease(msg);
                return -1;
            }
            
            // get values
            NSInteger statusCode = CFHTTPMessageGetResponseStatusCode(msg);
            NSDictionary *headers = [CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(msg)) copy];
            CFRelease(msg);
            
            // validate status
            if(statusCode != 101) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"Handshake failed");
                return - 1;
            }
            
            // validate protocol
            NSArray *protocolComponents = [_request.allHTTPHeaderFields[@"Sec-WebSocket-Protocol"] componentsSeparatedByString:@" "];
            if(headers[@"Sec-WebSocket-Protocol"] && ![protocolComponents containsObject:headers[@"Sec-WebSocket-Protocol"]]) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"Invalid Sec-WebSocket-Protocol");
                return -1;
            }
            _protocol = headers[@"Sec-WebSocket-Protocol"];
            
            // validate accept
            if(![headers[@"Sec-WebSocket-Accept"] isEqualToString:[self acceptHeaderForKey:_handshakeSecKey]]) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"Invalid Sec-WebSocket-Accept");
                return -1;
            }
            
            // validate version
            if(headers[@"Sec-WebSocket-Version"] && ![headers[@"Sec-WebSocket-Version"] isEqualToString:@"13"]) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"Invalid Sec-WebSocket-Version");
                return -1;
            }
            
            // extensions
            NSArray *extensionComponents = [headers[@"Sec-WebSocket-Extensions"] componentsSeparatedByString:@"; "];
            
            // per-message deflate
            if(![self pmdConfigureWithExtensionsHeaderComponents:extensionComponents]) {
                PSWebSocketSetOutError(outError, PSWebSocketErrorCodeHandshakeFailed, @"permessage-deflate could not negotiate parameters");
                return -1;
            }
            
            // transition state
            _state = PSWebSocketDriverStateFrameHeader;
            
            [_delegate driverDidOpen:self];
            
            return preBoundaryLength;
        }
        //
        // FRAME HEADER
        //
        case PSWebSocketDriverStateFrameHeader: {
            NSAssert(maxLength > 0, @"Must have 1 or more bytes");
            
            if(maxLength < 2) {
                return 0;
            }
            
            const uint8_t *header = (const uint8_t *)bytes;
            
            BOOL fin = !!(header[0] & PSWebSocketFinMask);
            BOOL rsv1 = !!(header[0] & PSWebSocketRsv1Mask);
            BOOL rsv2 = !!(header[0] & PSWebSocketRsv2Mask);
            BOOL rsv3 = !!(header[0] & PSWebSocketRsv3Mask);
            PSWebSocketOpCode opcode = (header[0] & PSWebSocketOpCodeMask);
            BOOL masked = !!(header[1] & PSWebSocketMaskMask);
            uint64_t payloadLength = (header[1] & PSWebSocketPayloadLenMask);
            uint32_t headerExtraLength = (masked) ? sizeof(uint32_t) : 0;
            if(payloadLength == 126) {
                headerExtraLength += sizeof(uint16_t);
            } else if(payloadLength == 127) {
                headerExtraLength += sizeof(uint64_t);
            }
            
            // validate opcode
            if(!PSWebSocketOpCodeIsValid(opcode)) {
                PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Invalid opcode");
                return -1;
            }
            
            // determine if control frame
            BOOL control = PSWebSocketOpCodeIsControl(opcode);
            
            // validate control frame
            if(control) {
                // control frames must be final
                if(!fin) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Control frames must be final");
                    return -1;
                }
                // control frames must not have any reserved bits set
                if(rsv1 || rsv2 || rsv3) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Control frames must not use reserved bits");
                    return -1;
                }
                // control frames must not have payload >= 126
                if(payloadLength >= 126) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Control frames payload must < 126");
                    return -1;
                }
            }
            // validate data frame
            else {
                // data continuation frames must follow an initial data frame
                if(opcode == PSWebSocketOpCodeContinuation && _frames.count == 0) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Data continuation frames must follow an initial data frame");
                    return -1;
                }
                // non data continuation frames must not follow an initial data frame
                if(opcode != PSWebSocketOpCodeContinuation && _frames.count > 0) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Data frames must not follow an initial data frame unless continuations");
                    return -1;
                }
                // rsv1 only set if permessage-deflate is enabled
                if(rsv1 && !_pmdEnabled) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Data frames must only use rsv1 bit if permessage-deflate extension is on");
                    return -1;
                }
                // rsv2 and rsv3 must never be set
                if(rsv2 || rsv3) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Data frames must never use rsv2 or rsv3 bits");
                    return -1;
                }
            }
            
            // ensure not masked if client mode
            if(masked && _mode == PSWebSocketModeClient) {
                PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Frames must never be masked from server");
                return -1;
            }
            // ensure masked if server mode
            if(!masked && _mode == PSWebSocketModeServer) {
                PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Frames must always be masked from client");
                return -1;
            }
            
            // create frame
            PSWebSocketFrame *frame = [[PSWebSocketFrame alloc] init];
            frame->fin = fin;
            frame->rsv1 = rsv1;
            frame->rsv2 = rsv2;
            frame->rsv3 = rsv3;
            frame->opcode = opcode;
            frame->masked = masked;
            frame->payloadLength = (NSUInteger)payloadLength;
            frame->payloadRemainingLength = (NSUInteger)payloadLength;
            frame->headerExtraLength = headerExtraLength;
            frame->control = control;
            
            if(!frame->control && _frames.count > 0) {
                _initialFrame = [_frames lastObject];
                frame->opcode = _initialFrame->opcode;
                frame->buffer = _initialFrame->buffer;
            } else {
                frame->buffer = [NSMutableData data];
            }
            [_frames addObject:frame];
            
            if(headerExtraLength > 0) {
                _state = PSWebSocketDriverStateFrameHeaderExtra;
            } else if(payloadLength > 0) {
                _state = PSWebSocketDriverStateFramePayload;
            } else {
                _state = PSWebSocketDriverStateFrameHeader;
                if(![self processFramesAndDelegate:outError]) {
                    return -1;
                }
            }
            return 2;
        }
        //
        // FRAME HEADER EXTRA
        //
        case PSWebSocketDriverStateFrameHeaderExtra: {
            NSAssert(maxLength > 0, @"Must have 1 or more bytes");
            
            // get current frame
            PSWebSocketFrame *frame = [_frames lastObject];
            
            // we need at least current frames header extra length
            if(maxLength < frame->headerExtraLength) {
                return 0;
            }
            
            uint64_t payloadLength = frame->payloadLength;
            if(payloadLength == 126) {
                payloadLength = EndianU16_BtoN(*(uint16_t *)bytes);
            } else if(payloadLength == 127) {
                payloadLength = EndianU64_BtoN(*(uint64_t *)bytes);
            }
            frame->payloadLength = (NSUInteger)payloadLength;
            frame->payloadRemainingLength = (NSUInteger)payloadLength;
            
            if(frame->masked) {
                memcpy(frame->maskKey, (uint8_t *)bytes + (frame->headerExtraLength - sizeof(uint32_t)), sizeof(uint32_t));
                frame->maskOffset = 0;
            }
            
            if(frame->payloadLength > 0) {
                _state = PSWebSocketDriverStateFramePayload;
            } else {
                _state = PSWebSocketDriverStateFrameHeader;
                if(![self processFramesAndDelegate:outError]) {
                    return -1;
                }
            }
            return frame->headerExtraLength;
        }
        //
        // FRAME PAYLOAD
        //
        case PSWebSocketDriverStateFramePayload: {
            NSAssert(maxLength > 0, @"Must have 1 or more bytes");
            
            // get current frame
            PSWebSocketFrame *frame = [_frames lastObject];
            
            NSUInteger consumeLength = MIN(frame->payloadRemainingLength, maxLength);
            NSUInteger offset = frame->buffer.length;
            
            // unmask bytes if client -> server
            if(_mode == PSWebSocketModeServer) {
                uint8_t *unmaskedBytes = (uint8_t *)bytes;
                uint8_t *maskKey = frame->maskKey;
                for(NSInteger i = 0; i < consumeLength; ++i) {
                    unmaskedBytes[i] = unmaskedBytes[i] ^ maskKey[frame->maskOffset++ % sizeof(uint32_t)];
                }
            }
            
            // inflate if necessary
            if(_pmdEnabled && !frame->control && (frame->rsv1 || _initialFrame->rsv1)) {
                // reset inflater if we need to
                if((_pmdClientNoContextTakeover && _mode == PSWebSocketModeServer) ||
                   (_pmdServerNoContextTakeover && _mode == PSWebSocketModeClient)) {
                    [_inflater reset];
                }
                
                // begin the inflater
                if(frame->payloadLength == frame->payloadRemainingLength) {
                    if(![_inflater begin:frame->buffer error:outError]) {
                        return -1;
                    }
                }
                
                // inflate bytes
                if(![_inflater appendBytes:bytes length:consumeLength error:outError]) {
                    return -1;
                }
                
                // end inflater
                if(frame->fin && frame->payloadRemainingLength == consumeLength) {
                    if(![_inflater end:outError]) {
                        return -1;
                    }
                }
            }
            // otherwise append
            else {
                [frame->buffer appendBytes:bytes length:consumeLength];
            }
            
            // validate utf-8 if necessary
            if(frame->opcode == PSWebSocketOpCodeText) {
                uint8_t *bytes = (uint8_t *)(frame->buffer.bytes + offset);
                for(NSUInteger i = 0; i < frame->buffer.length - offset; ++i) {
                    // get validation result
                    PSWebSocketUTF8DecoderDecode(&_utf8DecoderState, &_utf8DecoderCodePoint, *(bytes + i));
                    
                    // read bad code point
                    if(_utf8DecoderState == PSWebSocketUTF8DecoderReject) {
                        PSWebSocketSetOutError(outError, PSWebSocketStatusCodeInvalidUTF8, @"Invalid UTF-8");
                        return -1;
                    }
                }
                
                // need more bytes & no data will be left
                if(_utf8DecoderState > 1 && frame->fin && frame->payloadRemainingLength - consumeLength == 0) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeInvalidUTF8, @"Invalid UTF-8");
                    return -1;
                }
            }
            
            // remove consumed length from remaining payload length
            frame->payloadRemainingLength -= consumeLength;
            
            if(frame->payloadRemainingLength == 0) {
                _state = PSWebSocketDriverStateFrameHeader;
                if(![self processFramesAndDelegate:outError]) {
                    return -1;
                }
            }
            return consumeLength;
        }
        default:
            return 0;
    }
    return 0;
}

- (BOOL)processFramesAndDelegate:(NSError *__autoreleasing *)outError {
    // get current frame
    PSWebSocketFrame *frame = [_frames lastObject];
    
    // skip if not final
    if(!frame->fin) {
        return YES;
    }
    
    // remove frames
    if(frame->control) {
        [_frames removeLastObject];
    } else {
        [_frames removeAllObjects];
        _initialFrame = nil;
        _utf8DecoderState = 0;
        _utf8DecoderCodePoint = 0;
    }
    
    switch(frame->opcode) {
        case PSWebSocketOpCodeBinary:
            [_delegate driver:self didReceiveMessage:frame->buffer];
            break;
        case PSWebSocketOpCodePong:
            [_delegate driver:self didReceivePong:frame->buffer];
            break;
        case PSWebSocketOpCodePing: {
            [_delegate driver:self didReceivePing:frame->buffer];
            break;
        }
        case PSWebSocketOpCodeText: {
            NSString *utf8 = [[NSString alloc] initWithData:frame->buffer encoding:NSUTF8StringEncoding];
            if(!utf8) {
                PSWebSocketSetOutError(outError, PSWebSocketStatusCodeInvalidUTF8, @"Invalid UTF-8");
                return NO;
            }
            [_delegate driver:self didReceiveMessage:utf8];
            break;
        }
        case PSWebSocketOpCodeClose:
            if(frame->buffer.length >= 2) {
                uint16_t closeCode = 0;
                [frame->buffer getBytes:&closeCode length:sizeof(closeCode)];
                closeCode = EndianU16_BtoN(closeCode);
                if(!PSWebSocketCloseCodeIsValid(closeCode)) {
                    PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Invalid close code");
                    return NO;
                }
                NSString *reason = nil;
                if(frame->buffer.length > 2) {
                    reason = [[NSString alloc] initWithBytes:frame->buffer.mutableBytes + sizeof(uint16_t)
                                                      length:frame->buffer.length - sizeof(uint16_t)
                                                    encoding:NSUTF8StringEncoding];
                    if(!reason) {
                        PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Invalid close reason; must be UTF-8");
                        return NO;
                    }
                }
                [_delegate driver:self didCloseWithCode:closeCode reason:reason];
            } else if(frame->buffer.length >= 1) {
                PSWebSocketSetOutError(outError, PSWebSocketStatusCodeProtocolError, @"Invalid close payload");
                return NO;
            } else {
                [_delegate driver:self didCloseWithCode:PSWebSocketStatusCodeNoStatusReceived reason:nil];
            }
            break;
        case PSWebSocketOpCodeContinuation:
            return YES;
    }
    
    return YES;
}

#pragma mark - Erroring

- (void)failWithErrorCode:(NSInteger)code reason:(NSString *)reason {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: reason};
    NSError *error = [NSError errorWithDomain:PSWebSocketErrorDomain code:code userInfo:userInfo];
    [self failWithError:error];
}
- (void)failWithError:(NSError *)error {
    NSParameterAssert(error);
    _failed = YES;
    [_delegate driver:self didFailWithError:error];
}

#pragma mark - permessage-deflate

- (NSArray *)pmdExtensionsHeaderComponents {
    if(_pmdEnabled) {
        NSMutableArray *components = [NSMutableArray arrayWithObject:@"permessage-deflate"];
        
        // client mode
        if(_mode == PSWebSocketModeClient) {
            // say we'll take whatever window bits the server gives us
            [components addObject:@"client_max_window_bits"];
        }
        // server mode
        else if(_mode == PSWebSocketModeServer) {
            // set the window bits the client must use
            [components addObject:[NSString stringWithFormat:@"client_max_window_bits=%@", @(-_pmdClientWindowBits)]];
            
            // set the window bits the server will use
            [components addObject:[NSString stringWithFormat:@"server_max_window_bits=%@", @(-_pmdServerWindowBits)]];
        }
        return components;
    }
    return @[];
}
- (BOOL)pmdConfigureWithExtensionsHeaderComponents:(NSArray *)components {
    _pmdEnabled = NO;
    _pmdClientWindowBits = -11;
    _pmdClientNoContextTakeover = NO;
    _pmdServerWindowBits = -11;
    _pmdServerNoContextTakeover = NO;
    
    for(NSString *component in components) {
        // split to key & value
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        
        if([component isEqualToString:@"permessage-deflate"]) {
            _pmdEnabled = YES;
        } else if([component isEqualToString:@"client_max_window_bits"] && subcomponents.count > 1) {
            _pmdClientWindowBits = -[subcomponents[0] integerValue];
        } else if([component isEqualToString:@"server_max_window_bits"] && subcomponents.count > 1) {
            _pmdServerWindowBits = -[subcomponents[0] integerValue];
        } else if([component isEqualToString:@"client_no_context_takeover"] && _mode == PSWebSocketModeClient) {
            _pmdClientNoContextTakeover = YES;
        } else if([component isEqualToString:@"server_no_context_takeover"] && _mode == PSWebSocketModeClient) {
            _pmdServerNoContextTakeover = YES;
        }
    }
    
    if(_pmdClientWindowBits > -8 || _pmdClientWindowBits < -15) {
        return NO;
    }
    if(_pmdServerWindowBits > -8 || _pmdServerWindowBits < -15) {
        return NO;
    }
    
    if(_mode == PSWebSocketModeClient) {
        _inflater = [[PSWebSocketInflater alloc] initWithWindowBits:_pmdClientWindowBits];
        _deflater = [[PSWebSocketDeflater alloc] initWithWindowBits:_pmdServerWindowBits memoryLevel:8];
    } else {
        _inflater = [[PSWebSocketInflater alloc] initWithWindowBits:_pmdServerWindowBits];
        _deflater = [[PSWebSocketDeflater alloc] initWithWindowBits:_pmdClientWindowBits memoryLevel:8];
    }
    
    return YES;
}

#pragma mark - Utilities

- (NSString *)acceptHeaderForKey:(NSString *)key {
    NSParameterAssert(key);
    NSString *combined = [key stringByAppendingString:PSWebSocketGUID];
    NSData *data = [combined dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char sha1[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, sha1);
    data = [NSData dataWithBytes:sha1 length:CC_SHA1_DIGEST_LENGTH];
    return [data base64EncodedStringWithOptions:0];
}

@end
