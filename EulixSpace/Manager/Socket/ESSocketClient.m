/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESSocketClient.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSocketClient.h"
#import "ESThemeDefine.h"
#import <SocketRocket/SocketRocket.h>

NSString *const kESSocketClientErrorDomain = @"kESSocketClientErrorDomain";

NSString *const kESSocketClientErrorReason = @"kESSocketClientErrorReason";

NSString *const kESSocketClientErrorCode = @"kESSocketClientErrorCode";

#pragma mark - Client

@interface ESSocketClient () <SRWebSocketDelegate>

@property (nonatomic, copy) NSString *host;

@property (nonatomic, assign) uint16_t port;

@property (nonatomic, copy) ESSocketClientResultBlock resultBlock;

@property (nonatomic, copy) ESSocketClientEventBlock eventBlock;

@property (nonatomic, assign) BOOL connected;

@property (nonatomic, assign) dispatch_queue_t queue;

@property (nonatomic, strong) SRWebSocket *socket;

@property (nonatomic, assign) NSTimeInterval connectTimeout;

@end

@implementation ESSocketClient

- (instancetype)init {
    self = [super init];
    if (self) {
        _retryInterval = 5;
        _verbose = YES;
    }
    return self;
}

- (id)client {
    return self.socket;
}

- (BOOL)connected {
    return self.socket && self.socket.readyState == SR_OPEN;
}

#pragma mark - Connection

- (void)reconnect {
    __weak __typeof__(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.retryInterval * NSEC_PER_SEC)), self.queue, ^{
        __typeof__(self) self = weak_self;
        [self disconnect];
        if (self.verbose) {
            ESDLog(@"Reconnect now");
        }
        [self connectToHost:self.host onPort:self.port withTimeout:self.connectTimeout];
    });
}

- (BOOL)connect {
    if (self.connected) {
        return YES;
    }
    [self.socket open];
    return self.connected;
}

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
          withTimeout:(NSTimeInterval)timeout {
    self.host = host;
    self.port = port;
    NSString *urlString;
    if (self.port > 0) {
        urlString = [NSString stringWithFormat:@"wss://%@:%d/%@/", self.host, self.port, self.path];
    } else {
        urlString = [NSString stringWithFormat:@"wss://%@/%@/", self.host, self.path];
    }
    return [self connectToUri:urlString withTimeout:timeout];
}

- (BOOL)connectToUri:(NSString *)uri
         withTimeout:(NSTimeInterval)timeout {
    [self disconnect];
    _connectTimeout = timeout;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:uri] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.socket.delegate = self;
    return [self connect];
}

- (void)disconnect {
    if (self.socket) {
        if (self.verbose) {
            ESDLog(@"Disconnect by me");
        }
        self.socket.delegate = nil;
        [self.socket close];
        self.socket = nil;
    }
}

#pragma mark - Send Data

- (void)sendData:(id)data {
    if (self.socket.readyState != SR_CONNECTING) {
        [self.socket sendData:data error:nil];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (self.resultBlock) {
        self.resultBlock(message);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    if (self.eventBlock) {
        self.eventBlock(ESSocketClientEventTypeConnect, nil);
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self onConnectionFailed:error];
}

- (void)onConnectionFailed:(NSError *)error {
    self.socket = nil;
    if (self.eventBlock) {
        self.eventBlock(ESSocketClientEventTypeDisconnect, error);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean {
    [self onConnectionFailed:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
}

#pragma mark - Lazy Load

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_get_main_queue();
    }
    return _queue;
}

@end
