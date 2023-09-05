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
//  ESSessionClient.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESSessionClientDefine.h"
#import "ESSessionMessage.h"
#import <Foundation/Foundation.h>

@interface ESSessionClient : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, copy) NSString *clientUUID;

@property (nonatomic, copy) NSString *baseUri;

@property (nonatomic, assign) NSTimeInterval keepAliveInterval;

@property (nonatomic, readonly) ESSessionClientConnectionStatus connectionStatus;

@property (nonatomic, readonly) BOOL connected;


- (void)connectionCheck;

- (void)connectionCheck:(void (^)(BOOL connected))block;

#pragma mark - Life Cycle

- (void)start;

- (void)stop;

- (void)restart;

- (NSString *)generateRequestId;

@property (nonatomic, copy) void (^loggerHandler)(NSDictionary *data);

@end

#pragma mark - Request

@interface ESSessionClient (Request)

- (void)sendMessage:(ESSessionMessage *)message;

@end

#pragma mark - Observer

@interface ESSessionClient (Observer)

- (void)addObserver:(id<ESChatEventProtocol>)observer forEvent:(ESSessionEventType)event;

- (void)removeObserver:(id<ESChatEventProtocol>)observer;

@end
