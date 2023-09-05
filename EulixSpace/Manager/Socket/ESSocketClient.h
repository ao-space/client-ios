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
//  ESSocketClient.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESSocketClientEventType) {
    ESSocketClientEventTypeUnknown,
    ESSocketClientEventTypeConnect,
    ESSocketClientEventTypeDisconnect,
};

FOUNDATION_EXPORT NSString *const kESSocketClientErrorDomain;

FOUNDATION_EXPORT NSString *const kESSocketClientErrorReason;

FOUNDATION_EXPORT NSString *const kESSocketClientErrorCode;

typedef void (^ESSocketClientResultBlock)(id data);

typedef void (^ESSocketClientEventBlock)(ESSocketClientEventType type, NSError *error);

typedef void (^ESSocketAsyncRequestHandler)(BOOL result, id model);

@interface ESSocketClient : NSObject

#pragma mark - Connection

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
          withTimeout:(NSTimeInterval)timeout;

- (BOOL)connectToUri:(NSString *)uri
         withTimeout:(NSTimeInterval)timeout;

@property (nonatomic, readonly) id client;

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy, readonly) NSString *host;

@property (nonatomic, readonly) uint16_t port;

@property (nonatomic, readonly) BOOL connected;

- (void)disconnect;

#pragma mark - Send Data

/**
 Send data

 @param data data will be sent
 */
- (void)sendData:(id)data;

#pragma mark - Receive Data & Event

- (void)setResultBlock:(ESSocketClientResultBlock)resultBlock;

- (void)setEventBlock:(ESSocketClientEventBlock)eventBlock;

#pragma mark - Verbose

@property (nonatomic, assign) BOOL verbose;

#pragma mark - Reconnect

- (void)reconnect;

@property (nonatomic, assign) NSUInteger retryInterval; //default is 3s

@end
