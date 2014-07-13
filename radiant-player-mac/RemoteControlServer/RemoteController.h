//
//  RemoteController.h
//  radiant-player-mac
//
//  Created by Jan-Henrik Bruhn on 13.07.14.
//  Copyright (c) 2014 Sajid Anwar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSWebSocketServer.h>

@interface RemoteController : NSObject <PSWebSocketServerDelegate>

@property (nonatomic, strong) PSWebSocketServer *server;

- (void)startServerOnPort:(int)port;

@end
