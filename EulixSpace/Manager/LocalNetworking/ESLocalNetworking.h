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
//  ESLocalNetworking.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESConnectionType) {
    ESConnectionTypeInteret, // 互联网转发
    ESConnectionTypeLan, // 局域网直连
    ESConnectionTypeP2P, // P2P加速
    ESConnectionTypeOffline, // 离线
    
    ESConnectionTypeUnknown = 100 // 未知状态
};

@class ESBoxItem;

@protocol ESLocalNetworkingStatusProtocol <NSObject>

@optional
- (void)localNetworkReachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem;
- (void)localNetworkUnreachableWithBoxInfo:(ESBoxItem * _Nullable)boxItem;

@end


@interface ESLocalNetworking : NSObject

+ (instancetype)shared;

@property (nonatomic, strong, readonly) ESBoxItem *reachableBox;

/**
 return format: http://ip:port
 */
- (NSString *)getLanHost;

/// 会自动先 调一下 `stopMonitor`
- (void)restartMonitor;
- (void)stopMonitor;

- (void)addLocalNetworkStatusObserver:(id<ESLocalNetworkingStatusProtocol>)observer;

+ (BOOL)isLANReachable;
+ (NSString *)getConnectedDescribe;
// 获取网络类型时对应的图片资源名称
+ (NSString *)getConnectionImageName;

@end

NS_ASSUME_NONNULL_END

