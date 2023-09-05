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
//  ESSessionClientDefine.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/8.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#ifndef ESSessionClientDefine_h
#define ESSessionClientDefine_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ESSessionEventType) {
    ESSessionEventTypeClientUnkown = 0,
    ESSessionEventTypeClientConnect,
    ESSessionEventTypeClientDisconnect,
    ESSessionEventTypeClientLogin,
    ESSessionEventTypeClientAllEvent,
    ESSessionEventTypeReceiveMessage,
    ESSessionEventTypeOriginData,
    ESSessionEventTypeClientLoginFailed,
};

typedef NS_ENUM(NSUInteger, ESSessionClientConnectionStatus) {
    ESSessionClientConnectionStatusUnkown,
    ESSessionClientConnectionStatusConnecting,
    ESSessionClientConnectionStatusConnected,
    ESSessionClientConnectionStatusDisconnect,
};

static const NSUInteger kESSessionReconnectTimeInterval = 5;

static const NSUInteger kESSessionHeartbeatTimeInterval = 20;

@class ESSessionClient;

@class ESSessionMessage;
@protocol ESChatEventProtocol <NSObject>

@optional

- (void)chatClient:(ESSessionClient *)client triggerredEvent:(ESSessionEventType)event;

- (void)chatClient:(ESSessionClient *)client receiveMessage:(ESSessionMessage *)message;

- (BOOL)canHandleMessage:(ESSessionMessage *)message;

- (BOOL)requireRealTime;

- (void)onOriginBinData:(NSData *)data;

@end

typedef void (^ESSocketAsyncRequestHandler)(BOOL result, id model);

#endif /* ESSessionClientDefine_h */
