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
//  ESSessionClient.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSessionClient.h"
#import "ESSocketClient.h"
#import "ESThemeDefine.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import <YCEasyTool/YCPollingEntity.h>

@interface ESChatMessageUnit : NSObject

@property (nonatomic, copy) ESSocketAsyncRequestHandler handler;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, assign) NSUInteger timestamp;

@property (nonatomic, strong) YCPollingEntity *loop;

@property (nonatomic, copy) ESSessionMessage *message;

@property (nonatomic, copy) ESSessionMessage *origin;

@property (nonatomic, assign) BOOL clearOnConnected;

@property (nonatomic, copy) void (^timeoutBlock)(void);

@property (nonatomic, assign) BOOL autoRetry;

@property (nonatomic, assign) NSUInteger retryTimes;

@end

@implementation ESChatMessageUnit

- (void)retry {
    self.retryTimes++;
    self.timeout = kESSessionReconnectTimeInterval;
    [self start];
}

- (void)start {
    if (!_loop) {
        _loop = [YCPollingEntity pollingEntityWithTimeInterval:0.1];
    }
    weakfy(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        strongfy(self);
        [self.loop startRunningWithBlock:^(NSTimeInterval current) {
            if (fabs(current - self.timeout) <= DBL_EPSILON || current > self.timeout) {
                if (self.timeoutBlock) {
                    self.timeoutBlock();
                }
                if (!self.autoRetry) {
                    [self finish];
                }
            }
        }];
    });
}

- (void)finish {
    [_loop stopRunning];
    _loop = nil;
    self.timeoutBlock = nil;
}

@end

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

#define IDLock() dispatch_semaphore_wait(self->_idLock, DISPATCH_TIME_FOREVER)
#define IDUnlock() dispatch_semaphore_signal(self->_idLock)

@interface ESSessionClient (Private)

- (void)notifyObserverWithEvent:(ESSessionEventType)event;

@end

@interface ESSessionClient ()

@property (nonatomic, assign) BOOL connecting;

@property (nonatomic, copy) NSString *host;

@property (nonatomic, assign) NSUInteger port;

@property (nonatomic, strong) ESSocketClient *client;

@property (nonatomic, strong) YCPollingEntity *heartBeatLoop;

@property (nonatomic, strong) NSArray *possible;

@property (nonatomic, strong) NSMutableDictionary *eventCache;

@property (nonatomic, strong) NSMutableDictionary *messageCache;

@property (nonatomic, assign) NSUInteger retryTimes;

@property (nonatomic, copy) void (^onConnection)(BOOL connected);

@property (nonatomic, assign) ESSessionClientConnectionStatus connectionStatus;

@property (nonatomic, copy) dispatch_block_t checkCallbackBlock;

//Connection
@property (nonatomic, assign) NSUInteger connectionTimeout; //连接超时,默认5

@property (nonatomic, assign) NSTimeInterval lastTryTimestamp;

@end

static dispatch_semaphore_t _globalInstancesLock;

@implementation ESSessionClient {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;
    dispatch_once(&once, ^{
        _globalInstancesLock = dispatch_semaphore_create(1);
        dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(_globalInstancesLock);
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[ESSessionClient sharedInstance]
                                             selector:@selector(_appActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)_appActive:(NSNotification *)sender {
    [self start];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _connectionTimeout = kESSessionReconnectTimeInterval;
        _lock = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("xyz.eulix.space.client", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - Connection

- (void)restart {
    [self stop];
    [self start];
}

- (void)start {
    if (self.connecting == YES || !self.deviceId) {
        return;
    }
    self.connecting = YES;
    self.connectionStatus = ESSessionClientConnectionStatusConnecting;
    self.lastTryTimestamp = NSDate.date.timeIntervalSinceReferenceDate;
    [self.client connectToUri:self.baseUri withTimeout:self.connectionTimeout];
}

- (void)stop {
    self.connecting = NO;
    [self stopHeartBeating];
    [self.client disconnect];
    self.connectionStatus = ESSessionClientConnectionStatusDisconnect;
}

#pragma mark - Ping

- (void)connectionCheck {
    if (self.connecting) { //正在连接,取消
        if (self.onConnection) {
            self.onConnection(NO);
        }
        self.onConnection = nil;
        [self start];
        return;
    }
    [self beating];
}

- (void)connectionCheck:(void (^)(BOOL))block {
    self.onConnection = block;
    [self connectionCheck];
}

- (void)startHeartBeating {
    weakfy(self);
    [self.heartBeatLoop startRunningWithBlock:^(NSTimeInterval current) {
        strongfy(self);
        [self connectionCheck];
    }];
    [self connectionCheck];
}

- (void)stopHeartBeating {
    if (_heartBeatLoop && !self.heartBeatLoop.running) {
        return;
    }
    [self.heartBeatLoop stopRunning];
}

- (void)beating {
    ESSessionMessage *message = [ESSessionMessage fromDict:@{@"method": @"ping"}];
    [self sendMessage:message];
}

#pragma mark - Login Status

- (void)clearOutDateUnit {
    [self.messageCache.allKeys enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        ESChatMessageUnit *unit = self.messageCache[obj];
        if (unit.clearOnConnected) {
            [unit finish];
            self.messageCache[obj] = nil;
        }
    }];
}

- (void)retryConnect {
    //距离上次重试连接超过 `5`s kESSessionReconnectTimeInterval, 直接重试
    NSTimeInterval interval = NSDate.date.timeIntervalSinceReferenceDate - self.lastTryTimestamp;
    if (interval >= kESSessionReconnectTimeInterval) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self restart];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kESSessionReconnectTimeInterval - interval) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self restart];
        });
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)eventHandler:(ESSocketClientEventType)event error:(NSError *)error {
    switch (event) {
        case ESSocketClientEventTypeConnect: {
            ESDLog(@"Socket Connect");
            [self clearOutDateUnit];
            self.connectionTimeout = kESSessionReconnectTimeInterval;
            self.retryTimes = 0;
            [self login];
        } break;
        case ESSocketClientEventTypeDisconnect: {
            ESDLog(@"Socket Disconnect");
            self.connectionStatus = ESSessionClientConnectionStatusDisconnect;
            self.connecting = NO;
            [self stop];
            self.retryTimes++;
            [self retryConnect];
        } break;
        default:
            break;
    }
    [self notifyObserverWithEvent:(ESSessionEventType)event];
}

- (void)login {
    NSMutableDictionary *request = NSMutableDictionary.dictionary;
    request[@"method"] = @"login";
    request[@"messageId"] = self.generateRequestId;
    request[@"parameters"] = @{
        @"clientUUID": self.clientUUID ?: @"",
        @"platform": @"ios",
        @"deviceId": self.deviceId,
    };
    ESSessionMessage *message = [ESSessionMessage fromDict:request];
    [self sendMessage:message];
}

- (void)messageHandler:(ESSessionMessage *)message {
    ESDLog(@"messageHandler:\n%@", message.dict);
    if ([message.method isEqualToString:@"login"]) {
        NSNumber *code = message.result[@"code"];
        if (code && code.integerValue == 0) {
            [self onLogin:message];
        }
    } else if ([message.method isEqualToString:@"push"]) {
        [self onPush:message];
    } else if ([message.method isEqualToString:@"query"]) {
        [self onQuery:message];
    }
}

- (void)onLogin:(ESSessionMessage *)message {
    ESDLog(@"Socket onLogin");
    self.connectionStatus = ESSessionClientConnectionStatusConnected;
    self.connecting = NO;
    [self notify:(ESSessionEventTypeClientLogin) message:message];
    [self startHeartBeating];
    [self queryOfflineMessage];
}

- (void)queryOfflineMessage {
    ESSessionMessage *message = [ESSessionMessage fromDict:@{
        @"method": @"query",
        @"messageId": self.generateRequestId,
        @"parameters": @{
            @"page": @(0),
            @"pageSize": @(10),
        },
    }];
    [self sendMessage:message];
}

- (void)onQuery:(ESSessionMessage *)message {
    NSArray<NSDictionary *> *list = message.result[@"list"];
    NSArray<NSString *> *idList = [list yc_mapWithBlock:^id(NSUInteger idx, NSDictionary *obj) {
        return obj[@"messageId"];
    }];
    [self ackList:idList];
}

- (void)onPush:(ESSessionMessage *)message {
    [self notify:(ESSessionEventTypeReceiveMessage) message:message];
    [self ack:message.messageId];
}

- (void)ack:(NSString *)messageId {
    if (!messageId) {
        return;
    }
    ESSessionMessage *message = [ESSessionMessage fromDict:@{
        @"method": @"ack",
        @"messageId": messageId,
    }];
    [self sendMessage:message];
}

- (void)ackList:(NSArray<NSString *> *)idList {
    if (idList.count == 0) {
        return;
    }
    ESSessionMessage *message = [ESSessionMessage fromDict:@{
        @"method": @"ack",
        @"parameters": @{
            @"list": idList
        },
    }];
    [self sendMessage:message];
}

- (void)notify:(ESSessionEventType)event message:(ESSessionMessage *)message {
    NSPointerArray *observerArray = self.eventCache[@(event)];
    [observerArray.allObjects enumerateObjectsUsingBlock:^(id<ESChatEventProtocol> obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj respondsToSelector:@selector(canHandleMessage:)]) {
            if ([obj canHandleMessage:message] && [obj respondsToSelector:@selector(chatClient:receiveMessage:)]) {
                [obj chatClient:self receiveMessage:message];
            }
        }
    }];
}

- (void)onOriginBinData:(id)data {
    NSPointerArray *observerArray = self.eventCache[@(ESSessionEventTypeOriginData)];
    [observerArray.allObjects enumerateObjectsUsingBlock:^(id<ESChatEventProtocol> obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj respondsToSelector:@selector(onOriginBinData:)]) {
            [obj onOriginBinData:data];
        }
    }];
}

#pragma mark - Lazy Load

- (YCPollingEntity *)heartBeatLoop {
    if (!_heartBeatLoop) {
        _heartBeatLoop = [YCPollingEntity pollingEntityWithTimeInterval:kESSessionHeartbeatTimeInterval];
    }
    return _heartBeatLoop;
}

- (ESSocketClient *)client {
    if (!_client) {
        _client = [[ESSocketClient alloc] init];
        weakfy(self);
        [_client setResultBlock:^(NSString *data) {
            strongfy(self);
            [self onOriginBinData:data];
            ESSessionMessage *message = [ESSessionMessage fromMessage:data];
            [self messageHandler:message];
        }];

        [_client setEventBlock:^(ESSocketClientEventType type, NSError *error) {
            strongfy(self);
            [self eventHandler:type error:error];
        }];

        _client.verbose = YES;
    }
    return _client;
}

- (NSMutableDictionary *)eventCache {
    if (!_eventCache) {
        _eventCache = [[NSMutableDictionary alloc] init];
    }
    return _eventCache;
}

- (NSMutableDictionary *)messageCache {
    if (!_messageCache) {
        _messageCache = [[NSMutableDictionary alloc] init];
    }
    return _messageCache;
}

- (BOOL)connected {
    return self.client.connected;
}

#pragma mark - Request Id

- (NSString *)generateRequestId {
    return [NSUUID UUID].UUIDString.lowercaseString;
}

@end

@implementation ESSessionClient (Private)

- (void)sendMessage:(ESSessionMessage *)message handler:(ESSocketAsyncRequestHandler)handler {
    Lock();
    dispatch_async(_queue, ^{
        [self enqueueHandler:handler message:message];
        ESDLog(@"Prepare to send message [%@]", message);
        [self.client sendData:message.message];
    });
    Unlock();
}

- (void)notifyObserverWithEvent:(ESSessionEventType)event {
    if (event == ESSessionEventTypeClientLogin) {
        if (self.onConnection) {
            self.onConnection(YES);
            self.onConnection = nil;
        }
    }
    NSPointerArray *observerPointerArray = self.eventCache[@(event)];
    NSArray *observerArray = observerPointerArray.allObjects;
    [observerArray enumerateObjectsUsingBlock:^(id<ESChatEventProtocol> _Nonnull obj,
                                                NSUInteger idx,
                                                BOOL *_Nonnull stop) {
        [obj chatClient:self triggerredEvent:(ESSessionEventType)event];
    }];

    NSPointerArray *allEventObserverArray = self.eventCache[@(ESSessionEventTypeClientAllEvent)];

    [allEventObserverArray.allObjects enumerateObjectsUsingBlock:^(id<ESChatEventProtocol> _Nonnull obj,
                                                                   NSUInteger idx,
                                                                   BOOL *_Nonnull stop) {
        if (![observerArray containsObject:obj]) {
            [obj chatClient:self triggerredEvent:(ESSessionEventType)event];
        }
    }];
}

#pragma mark - Handler Queue

- (void)enqueueHandler:(ESSocketAsyncRequestHandler)handler message:(ESSessionMessage *)message {
}

@end

@implementation ESSessionClient (Request)

- (void)sendMessage:(ESSessionMessage *)message {
    ESDLog(@"sendMessage:\n%@", message.dict);
    [self.client sendData:message.message];
}

@end

@implementation ESSessionClient (Observer)

#pragma mark - Observer

- (void)addObserver:(id<ESChatEventProtocol>)observer forEvent:(ESSessionEventType)event {
    if (!observer) {
        return;
    }
    NSPointerArray *observerArray = self.eventCache[@(event)];
    if (!observerArray) {
        observerArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
        self.eventCache[@(event)] = observerArray;
    }
    if (![observerArray.allObjects containsObject:observer]) {
        [observerArray addPointer:(__bridge void *_Nullable)observer];
    }
}

- (void)removeObserver:(id<ESChatEventProtocol>)observer {
    if (!observer) {
        return;
    }
    [self.eventCache enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                                         NSPointerArray *_Nonnull obj,
                                                         BOOL *_Nonnull stop) {
        [obj compact];
        for (int i = 0; i < obj.count; i++) {
            if (observer == [obj pointerAtIndex:i]) {
                [obj removePointerAtIndex:i];
                break;
            }
        }
    }];
}

@end
