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
//  ESLocalNetworking.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESLocalNetworking.h"
#import "ESBoxManager.h"
#import "ESGlobalMacro.h"
#import "ESHomeCoordinator.h"
#import "ESLocalNetworkingPrompt.h"
#import "ESPlatformClient.h"
#import "ESWebContainerViewController.h"
#import "ESDeviceApi.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESLanTransferManager.h"
#import "ESBoxIPModel.h"
#import "ESNetworkRequestManager.h"
#import "ESServiceNameHeader.h"
#import "NSError+ESTool.h"
#import "ESNetServiceBrowser.h"
#import "ESLocalizableDefine.h"
#import "NSString+ESTool.h"
#import "ESCommonToolManager.h"
#import "ESNewPersonGuidanceWeb.h"

@interface ESLocalNetworking ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;

@property (nonatomic, strong) ESBoxItem *reachableBox;

@property (nonatomic, strong) ESLocalNetworkingPrompt *prompt;

@property (nonatomic, strong) NSString * lastLocalNetHost;

@property (nonatomic, strong) NSHashTable *localNetWorkStatusChangedObservers;

@property (nonatomic, strong) dispatch_semaphore_t checkingSemaphore;

@property (nonatomic, strong) ESNetServiceBrowser * serviceBrowser;
@property (nonatomic, assign) NSTimeInterval lastCheckTimestamp;
@property (nonatomic, assign) ESConnectionType connectionType;
@property (nonatomic, assign) ESConnectionType lastConnectionType;
@property (nonatomic, assign) BOOL appActive;
@end

@implementation ESLocalNetworking

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _serviceBrowser = [ESNetServiceBrowser new];
        self.lastConnectionType = ESConnectionTypeUnknown;
        self.checkingSemaphore = dispatch_semaphore_create(1);
        [self monitorNetworkReachability];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)monitorNetworkReachability {
    self.reachabilityManager = [AFNetworkReachabilityManager manager];
    self.reachabilityStatus = AFNetworkReachabilityStatusUnknown;
    weakfy(self);
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        strongfy(self);
        self.reachabilityStatus = status;
        ESDLog(@"[IPConnect] Current network Status: %@", AFStringFromNetworkReachabilityStatus(status));
        if (self.reachabilityStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
            [self reset];
        }
        [self checkIpConnected];
    }];
}

- (void)onBecomeActiveNotification {
    ESDLog(@"[IPConnect] Become Active");
    self.appActive = YES;
    [self.reachabilityManager startMonitoring];
}

- (void)onEnterBackgroundNotification {
    ESDLog(@"[IPConnect] Enter Background");
    self.appActive = NO;
    [self.reachabilityManager stopMonitoring];
    [self reset];
}

- (void)restartMonitor {
    ESDLog(@"[IPConnect] restartMonitor");
    [self stopMonitor];
    [self.reachabilityManager startMonitoring];
}

- (void)stopMonitor {
    ESDLog(@"[IPConnect] stopMonitor");
    [self.reachabilityManager stopMonitoring];
    [self reset];
}

- (void)reset {
    ESDLog(@"[IPConnect] reset");
    if (self.reachableBox) {
        ///恢复到默认盒子，实际上是重置了请求的host
        [ESBoxManager.manager markBoxActive:ESBoxManager.activeBox];
        self.reachableBox = nil;
        self.lastCheckTimestamp = 0;
    } else {
        _lastCheckTimestamp = 0;
    }
    self.lastConnectionType = ESConnectionTypeUnknown;
}

- (NSString *)getLanHost {
    return self.lastLocalNetHost;
}

/**
 @param model if it is nil, mean ip not connect
 */
- (void)updateBoxIpConnectState:(ESBoxIPModel *)model box:(ESBoxItem *)box {
    ESDLog(@"[IPConnect] %s:%@",__func__, model ? @"Connected" : @"Not Connected");
    [self notifyIPConnectStateChange:model];
    if (!model) {
        [self reset];
        return;
    }
    
    NSString * ipDomain = [model getIPDomain];
    ESDLog(@"[IPConnect] %s, reachableBox:%@, lastLocalNetHost:%@, ipDomain:%@",__func__, self.reachableBox, self.lastLocalNetHost, ipDomain);

    if (self.reachableBox == nil || self.lastLocalNetHost == nil || ![ipDomain isEqualToString:self.lastLocalNetHost]) {
        self.reachableBox = box;
        if (self.lastLocalNetHost == nil || ![self.lastLocalNetHost isEqualToString:ipDomain]) {
            ESPerformBlockOnMainThread(^{
                [self.prompt show:ESHomeCoordinator.sharedInstance.window];
            });
            self.lastLocalNetHost = ipDomain;
        }

        [ESBoxManager.manager setBoxIPConnect:ipDomain];
        [ESLanTransferManager.shared reqCertIfNot];
    }
}

- (void)checkIpConnected {
    ESDLog(@"[IPConnect] %s start, thread:%@", __func__, [NSThread currentThread]);

    if (self.appActive == NO) {
        ESDLog(@"[IPConnect] %s, APP is Background state", __func__);
        return;
    }
    
    if (ESBoxManager.activeBox == nil) {
        ESDLog(@"[IPConnect] %s 当前盒子为nil",__func__);
        return;
    }
    
    if (self.reachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        // 即使连接了 WiFi，也不表示能访问互联网
        ESDLog(@"[IPConnect] %s 网络不能访问",__func__);
        [self notifyIPConnectStateChange:nil];
        return;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    ESDLog(@"[IPConnect] %s 查询间隔:%f", __func__, now - self.lastCheckTimestamp);
    if (now - self.lastCheckTimestamp < 30) {
        ESDLog(@"[IPConnect] %s 查询太频繁",__func__);
        return;
    }
    
    _lastCheckTimestamp = now;
    ESPerformBlockAsyn(^{
        [self doCheckProcess];
    });
}

- (void)doCheckProcess {
    dispatch_semaphore_wait(self.checkingSemaphore, DISPATCH_TIME_FOREVER);
    ESDLog(@"[IPConnect] %s start", __func__);
    if (ESBoxManager.activeBox.btid == nil) {
        ESDLog(@"[IPConnect] %s req btid", __func__);
        [ESBoxManager.manager reqBtid:ESBoxManager.activeBox];
    }
    if (self.reachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self doCheckViaWifi];
    } else if (self.reachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        [self doCheckViaWWAN];
    } else {
        self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)doCheckViaWWAN {
    ESDLog(@"[IPConnect] %s start", __func__);
    [self checkBoxStateByDomain];
}

- (void)checkBoxStateByDomain {
    ESDLog(@"[IPConnect] %s start", __func__);
    [ESBoxManager checkBoxStateByDomain:^(BOOL offline) {
        [ESBoxManager.activeBox setOffline:offline];
        [self notifyIPConnectStateChange:nil];
        self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
    }];
}

- (void)doCheckViaWifi {
    ESDLog(@"[IPConnect] %s start", __func__);

    ESBoxItem * curBox = ESBoxManager.activeBox.copy;
    NSString * localHost = curBox.localHost;
    ESBoxIPResp * localBoxIpResp = [[ESBoxManager manager] getBoxIpResp];
    // 若没有 IP，拿 localHost 试一下
    if (![localBoxIpResp hasBoxIp] && localHost.length > 0) {
        if (localBoxIpResp == nil) {
            localBoxIpResp = [ESBoxIPResp new];
        }
        NSURL * url = [NSURL URLWithString:localHost];
        if (url) {
            ESBoxIPModel * ipModel = [[ESBoxIPModel alloc] init];
            ipModel.ip = url.host;
            ipModel.port = url.port.integerValue;
            localBoxIpResp.results = [NSMutableArray arrayWithObject:ipModel];
        }
    }
    
    // 1. If has local Ip info
    if ([localBoxIpResp hasBoxIp]) {
        ESDLog(@"[IPConnect] has local IP");
        [self hasLocalIPAndCheck:localBoxIpResp box:curBox completion:^(bool connected) {
            ESDLog(@"[IPConnect] has local IP, and connecte state is:%d", connected);
            if (!connected) {
                [self reqIPAndCheck:curBox completion:^(bool needMdns) {
                    if (needMdns) {
                        ESPerformBlockAsyn(^{
                            [self startMdns:curBox];
                        });
                    }
                }];
            }
        }];
        return;
    }
    
    // 2. Req IP from Service, and check.
    ESDLog(@"[IPConnect] Req IP from Service");
    [self reqIPAndCheck:curBox completion:^(bool needMdns) {
        if (needMdns) {
            // 3. If can not get IP, then MDNS
            ESPerformBlockAsyn(^{
                [self startMdns:curBox];
            });
        }
    }];
}

- (void)hasLocalIPAndCheck:(ESBoxIPResp *)boxIPResp box:(ESBoxItem *)box completion:(void (^)(bool connected))completion {
    // 1.1 Check IP connect state
    [self reqIPConnectStatus:boxIPResp completion:^{
        ESBoxIPModel * ipModel = [boxIPResp getConnectedBoxIP];
        
        if (ipModel) {
            // 1.1.1 IP Connected
            [self updateBoxIpConnectState:ipModel box:box];
            self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
        } else if (completion) {
            // 1.1.2 Old IP cannot connect
            completion(NO);
        }
    }];
}

- (void)reqIPAndCheck:(ESBoxItem *)box completion:(void (^)(bool needMdns))completion {
    [self reqBoxIpInfo:box callback:^(ESBoxIPResp *boxIpResp) {
        // 2.1 get IP by http
        if (boxIpResp && [boxIpResp hasBoxIp]) {
            [self reqIPConnectStatus:boxIpResp completion:^{
                ESBoxIPModel * ipModel = [boxIpResp getConnectedBoxIP];
                [self updateBoxIpConnectState:ipModel box:box];
                self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
                return;
            }];
        } else if (completion) {
            completion(YES);
        }
    }];
}

- (void)setLastCheckTimestamp:(NSTimeInterval)lastCheckTimestamp {
    ESDLog(@"[IPConnect] %s, value:%f", __func__, lastCheckTimestamp);
    _lastCheckTimestamp = lastCheckTimestamp;
    dispatch_semaphore_signal(self.checkingSemaphore);
    
    ESPerformBlockAfterDelay(30, ^{
        [self checkIpConnected];
    });
}

// get box ip info by http
- (void)reqBoxIpInfo:(ESBoxItem *)box callback:(void (^)(ESBoxIPResp * boxIpResp))callback {
    ESDLog(@"[IPConnect] 请求远端IP信息:%@", ESBoxManager.activeBox.info.userDomain);
    [self reset];
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:@"localips" queryParams:nil header:nil body:nil modelName:@"ESBoxIPResp" successBlock:^(NSInteger requestId, ESBoxIPResp * response) {
        
        [box setOffline:NO];
        box.boxIPResp = response;
        ESDLog(@"[IPConnect] http请求box ip的域名:%@; 返回的信息:%@", box.info.userDomain, [response toString]);
        [[ESBoxManager manager] saveBoxIp:box boxIP:response];
        
        ESPerformBlockAsyn(^{
            if (callback) {
                callback(response);
            }
        });
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[IPConnect] localips error, code:%@, msg:%@", error.codeString, error.errorMessage);
        ESPerformBlockAsyn(^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

// check ip connect state
- (void)reqIPConnectStatus:(ESBoxIPResp *)boxIPResp completion:(void (^)(void))completion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [boxIPResp resetCheckState];
    __block BOOL hasBack = NO;
    [boxIPResp.results enumerateObjectsUsingBlock:^(ESBoxIPModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * ipDomain = [obj getIPDomain];
        ESDLog(@"[IPConnect] ip connect state start check, ipDomain:%@", ipDomain);
        [ESBoxManager checkBoxStateByIP:ipDomain completion:^(BOOL offline) {
            ESPerformBlockAsyn(^{
                hasBack = YES;
                obj.ipConnected = !offline;
                obj.ipChecked = YES;
                ESDLog(@"[IPConnect] ip connect state, ip:%@, online:%d", obj.ip, obj.ipConnected);

                ESPerformBlockAfterDelay(1, ^{
                    dispatch_semaphore_signal(semaphore);
                });
            });
        }];
    }];
    // 10s 没连通就认为是非局域网
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_semaphore_wait(semaphore, time);
    ESDLog(@"[IPConnect] ip connect state end check, hasBack:%d", hasBack);
    if (completion) {
        completion();
    }
}

// get box ip info by mdns
- (void)startMdns:(ESBoxItem *)box {
    ESDLog(@"[IPConnect] startMdns:%@", box.info.userDomain);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString * btid = box.btid;
    [self checkBoxStateByDomain];
    if (btid.length == 0) {
        ESDLog(@"[IPConnect] startMdns bitd is nil");
        self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
        return;
    }
    
    __block ESBoxIPResp * resp = nil;
    NSString *localName = [NSString stringWithFormat:TEXT_BOX_BLUETOOTH_NAME_FORMAT, btid];
    NSString *btidHash = [NSString stringWithFormat:TEXT_BOX_MDNS_NAME_FORMAT, [localName.SHA256 substringToIndex:6]];
    [self.serviceBrowser startSearch:kESBoxServiceType inDomain:@"" target:btidHash];
    self.serviceBrowser.didFindService = ^(NSArray<ESNetServiceItem *> *serviceList) {
        ESNetServiceItem * item = serviceList.firstObject;
        ESBoxIPModel * model = [[ESBoxIPModel alloc] init];
        model.ip = item.ipv4;
        model.port = item.webport;
        
        resp = [[ESBoxIPResp alloc] init];
        resp.results = [NSMutableArray arrayWithObject:model];
        dispatch_semaphore_signal(semaphore);
    };
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_semaphore_wait(semaphore, time);
    [self.serviceBrowser stopSearch];
    
    ESBoxIPModel * model = resp.results.firstObject;
    ESDLog(@"[IPConnect] startMdns result :%@", model ? model.ip : @"nil");
    if (!resp || model.port <= 0) {
        self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
        return;
    }
    
    box.boxIPResp = resp;
    [[ESBoxManager manager] saveBoxIp:box boxIP:resp];

    [self reqIPConnectStatus:resp completion:^{
        ESBoxIPModel * ipModel = [resp getConnectedBoxIP];
        [self updateBoxIpConnectState:ipModel box:box];
        self.lastCheckTimestamp = [[NSDate date] timeIntervalSince1970];
    }];
}

- (ESLocalNetworkingPrompt *)prompt {
    if (!_prompt) {
        _prompt = [[ESLocalNetworkingPrompt alloc] initWithFrame:CGRectMake(10, kStatusBarHeight + 8, ScreenWidth - 20, 54)];
        _prompt.actionBlock = ^(id action) {
            ESWebContainerViewController *next = [ESWebContainerViewController new];
            next.insets = UIEdgeInsetsMake(-kTopHeight, 0, 0, 0);
            UITabBarController *tabbarVc = (UITabBarController *)ESHomeCoordinator.sharedInstance.window.rootViewController;
            if ([tabbarVc isKindOfClass:[UITabBarController class]]) {
                ESNewPersonGuidanceWeb *guidanceWeb = [ESNewPersonGuidanceWeb new];
                guidanceWeb.index = 1;
                [tabbarVc.selectedViewController pushViewController:guidanceWeb animated:YES];
            }
        };
    }
    return _prompt;
}

- (void)notifyIPConnectStateChange:(ESBoxIPModel *)model {
    NSString * stateDesc = [ESLocalNetworking getConnectedDescribe];
    ESDLog(@"[IPConnect] %s , state: %@", __func__, stateDesc);
    if (self.connectionType == self.lastConnectionType) {
        ESDLog(@"[IPConnect] %s , state unchange: %@", __func__, stateDesc);
        return;
    }
    ESDLog(@"[IPConnect] %s , state change: %@", __func__, stateDesc);
    self.lastConnectionType = self.connectionType;
    
    if (model && model.ipConnected) {
        [[self.localNetWorkStatusChangedObservers allObjects] enumerateObjectsUsingBlock:^(id<ESLocalNetworkingStatusProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(localNetworkReachableWithBoxInfo:)]) {
                [obj localNetworkReachableWithBoxInfo:self.reachableBox];
            }
        }];
    } else {
        [[self.localNetWorkStatusChangedObservers allObjects] enumerateObjectsUsingBlock:^(id<ESLocalNetworkingStatusProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(localNetworkUnreachableWithBoxInfo:)]) {
                [obj localNetworkUnreachableWithBoxInfo:self.reachableBox];
            }
        }];
    }
}

- (void)addLocalNetworkStatusObserver:(id)observer {
    if (self.localNetWorkStatusChangedObservers == nil) {
        self.localNetWorkStatusChangedObservers = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    [self.localNetWorkStatusChangedObservers addObject:observer];
}

+ (BOOL)isLANReachable {
    NSString * lanHost = [[ESLocalNetworking shared] getLanHost];
    ESDLog(@"[IPConnect] %s , lanHost: %@", __func__, lanHost);
    return [ESLocalNetworking.shared reachableBox] != nil && lanHost.length > 0;
}

+ (NSString *)getConnectedDescribe {
    if (ESLocalNetworking.shared.reachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        ESLocalNetworking.shared.connectionType = ESConnectionTypeOffline;
        return NSLocalizedString(@"LAN_Offline", @"离线");
    }
    if ([ESLocalNetworking isLANReachable]) {
        ESLocalNetworking.shared.connectionType = ESConnectionTypeLan;
        return NSLocalizedString(@"LAN_directconnection", @"局域网直连");
    }
    if (!ESBoxManager.activeBox.offline) {
        ESLocalNetworking.shared.connectionType = ESConnectionTypeInteret;
        return NSLocalizedString(@"LAN_internetforwarding", @"互联网转发");
    }
    
    ESLocalNetworking.shared.connectionType = ESConnectionTypeOffline;
    return NSLocalizedString(@"LAN_Offline", @"离线");
}

+ (NSString *)getConnectionImageName {
    ESDLog(@"[IPConnect] %s : type:%ld, des: %@", __func__, ESLocalNetworking.shared.connectionType, [ESLocalNetworking getConnectedDescribe]);
    [self getConnectedDescribe];
    
    switch (ESLocalNetworking.shared.connectionType) {
        case ESConnectionTypeLan:
            return @"main_transfer_lan";
        case ESConnectionTypeOffline:
            return @"main_transfer_offline";
        default:
            return @"main_transfer_Internet";
    }
}

@end

