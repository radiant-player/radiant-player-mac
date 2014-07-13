//
//  RemoteController.m
//  radiant-player-mac
//
//  Created by Jan-Henrik Bruhn on 13.07.14.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import "RemoteController.h"

@implementation RemoteController

@synthesize connectedClients;

-(void)startServerOnPort:(int)port {
    self.server = [PSWebSocketServer serverWithHost:nil port:port];
    self.server.delegate = self;
    [self.server start];
    
    connectedClients = [[NSMutableArray alloc] init];
}

- (void)broadcastCurrentSongWithTitle:(NSString*)title andArtist:(NSString*)artist andAlbum:(NSString*)album andArtURL:(NSString*)art {
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
    
    [messageDic setObject:title forKey:@"title"];
    [messageDic setObject:artist forKey:@"artist"];
    [messageDic setObject:album forKey:@"album"];
    [messageDic setObject:art forKey:@"artUrl"];

    NSString* jsonMessage = [messageDic JSONString];
    
    for(id client in connectedClients) {
        [((PSWebSocket*) client) send:jsonMessage];
    }
    
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"RemoteControl server started.");
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"RemoteControl server stopped.");
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    return YES;
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *m = [((NSString*) message) objectFromJSONString];
    NSString *action = [m objectForKey: @"action"];
    
    if(action) {
        action = [@"socket." stringByAppendingString:action];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:action
         object:nil ];
    }
}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Connection opened.");

    [connectedClients addObject:webSocket];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"socket.connected"
     object:nil ];
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
    [connectedClients removeObject:webSocket];
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
    
    [connectedClients removeObject:webSocket];
}

@end
