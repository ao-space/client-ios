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
//  ESBoxManager.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/6/23.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxManager.h"
#import "ESAccountManager.h"
#import "ESDatabaseManager.h"
#import "ESGatewayClient.h"
#import "ESGlobalMacro.h"
#import "ESHomeCoordinator.h"
#import "ESLocalNetworking.h"
#import "ESNetworking.h"
#import "ESRSACenter.h"
#import "ESSafeCache.h"
#import "ESSessionClient.h"
#import "ESTableFileManager.h"
#import "ESUploadMetadata.h"
#import "ESVersionManager.h"
#import "ESFamilyCache.h"
#import "ESPlatformClient.h"
#import "ESNetworkRequestManager.h"
#import "ESAccountServiceApi.h"
#import "ESDefaultConfiguration.h"
#import "ESPlatformServiceStatusApi.h"
#import <YCEasyTool/YCProperty.h>
#import <YYModel/YYModel.h>
#import "ESServiceNameHeader.h"
#import "ESServiceManager.h"
#import "ESTrailOnLineManager.h"
#import "ESAccountInfoStorage.h"
#import "ESCache.h"
#import "ESRedirectManage.h"


@interface ESBoxItem ()

@property (nonatomic, assign) BOOL offline;

@property (nonatomic, copy, readwrite) NSString *aoid;

@end

@interface ESDatabaseManager ()

- (void)setupDatabase:(NSString *)boxUUID onCreate:(void (^)(void))onCreate;

@end

@interface AFHTTPSessionManager ()

@property (readwrite, nonatomic, strong) NSURL *baseURL;

@end

static NSString *const kESBoxManagerInfoKey = @"_kESBoxManagerInfoKey";

static NSString *const kESBoxManagerBoxListKey = @"_kESBoxManagerBoxListKey";

@interface ESSafeCache ()

@property (class, nonatomic, copy, readonly) NSString *deviceId;

@property (class, nonatomic, copy, readonly) NSString *clientUUID;

@end

@interface ESBoxManager ()

@property (nonatomic, copy) NSString *deviceToken;

@property (nonatomic, strong) ESBoxItem *activeBox;

@property (nonatomic, copy) NSString *clientUUID;

@property (nonatomic, copy) NSString *administratorUserDomain;

@property (nonatomic, strong) NSMutableArray<ESBoxItem *> *boxList;


@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> * boxReqDict;
@end

@implementation ESBoxManager

+ (instancetype)manager {
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
        self.boxReqDict = [NSMutableDictionary dictionary];
        self.justLaunch = YES;
        ///从缓存中取出当前使用的盒子
        NSString *json = [ESSafeCache.safeCache objectForKey:kESBoxManagerInfoKey];
        if (json.length > 0) {
            self.activeBox = [ESBoxItem yy_modelWithJSON:json];
            ESDLog(@"[ESBoxManager][init] [kESBoxManagerInfoKey] %@", json);
        }
        [self reqDeviceAbility];
        ///设置为真实的clientUUID
        self.clientUUID = ESSafeCache.clientUUID;
        ///取出盒子列表
        self.boxList = [NSArray yy_modelArrayWithClass:[ESBoxItem class] json:[ESSafeCache.safeCache objectForKey:kESBoxManagerBoxListKey]].mutableCopy;
        if (self.boxList.count == 0) {
            ///初始化时, 如果有在使用的盒子,则存储到列表中
            self.boxList = [NSMutableArray array];
            if (self.activeBox) {
                [self.boxList addObject:self.activeBox];
            }
            [self saveBoxList];
        }
        ///授权的盒子, token 失效了, 直接删除
        if (self.activeBox.boxType == ESBoxTypeAuth && !self.activeBox.authToken.valid) {
            [self.boxList removeObject:self.activeBox];
            [self saveBoxList];
            self.activeBox = self.boxList.firstObject;
        }
        ///激活当前盒子
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onActive:self.activeBox];
        });
    }
    return self;
}

- (void)reqDeviceAbility {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.activeBox != nil) {
            //可以刷新support配置
            [self reqDeviceAbility:^(ESDeviceAbilityModel *model) {
                ESDLog(@"[ESBoxManager][reqDeviceAbility] %@", model);
                if (model != nil) {
                    [self saveBox:self.activeBox];
                }
                if ([ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox]) {
                    [[ESTrailOnLineManager shareInstance] startService];
                }
            } fail:^(NSError *error) {
                //重启账号已失效，也需启动服务
                ESDLog(@"[ESBoxManager][reqDeviceAbility] fail %@", error);
                [[ESTrailOnLineManager shareInstance] startService];
            }];
        }
    });
}

/// 清除所有盒子信息
+ (void)reset {
    [ESBoxManager.manager reset];
    exit(0);
}

- (void)reset {
    ESDLog(@"[ESBoxManager][reset]");

    ///删除当前盒子
    self.activeBox = nil;
    [ESSafeCache.safeCache setObject:@"" forKey:kESBoxManagerInfoKey];

    //删除盒子列表
    self.boxList = NSMutableArray.array;
    [self saveBoxList];

    //重置uuid & deviceId
    [ESSafeCache.safeCache reset];
}

- (void)cleanBoxsInfo {
    ESDLog(@"[ESBoxManager][cleanBoxsInfo]");

    ///删除当前盒子
    self.activeBox = nil;
    [ESSafeCache.safeCache setObject:@"" forKey:kESBoxManagerInfoKey];

    //删除盒子列表
    self.boxList = NSMutableArray.array;
    [self saveBoxList];
}

+ (NSArray<ESBoxItem *> *)bindBoxArray {
    return ESBoxManager.manager.boxList;
}

+ (void)onParing:(ESPairingBoxInfo *)info {
    ESBoxItem *box = [ESBoxItem fromPairing:info];
    [ESBoxManager.manager onParing:box];
    [ESBoxManager onActive:box];
}

+ (ESBoxItem *)onJustParing:(ESPairingBoxInfo *)info
                  spaceName:(NSString *)spaceName
       enableInternetAccess:(BOOL)enableInternetAccess
                  localHost:(NSString * _Nullable)localHost
            btid:(NSString *)btid
      diskStatus:(ESDiskInitStatus)diskInitStatus
            init:(ESBindInitResultModel *)initResult {
    ESBoxItem *box = [ESBoxItem fromPairing:info];
    box.enableInternetAccess = enableInternetAccess;
    box.localHost = localHost;

    box.supportNewBindProcess = YES;
    box.spaceName = spaceName;
    box.info.boxName = spaceName;
    box.btid = btid;
    box.diskInitStatus = diskInitStatus;
    box.bindInitResultModel = initResult;
    [ESBoxManager.manager onParing:box];
    return box;
}

+ (void)onParing:(ESPairingBoxInfo *)info
            btid:(NSString *)btid
      diskStatus:(ESDiskInitStatus)diskInitStatus
            init:(ESBindInitResultModel *)initResult {
    ESBoxItem *box = [ESBoxItem fromPairing:info];
    box.btid = btid;
    box.diskInitStatus = diskInitStatus;
    box.bindInitResultModel = initResult;
    [ESBoxManager.manager onParing:box];
    [ESBoxManager onActive:box];
}

+ (void)onAuth:(ESBoxItem *)info {
    NSParameterAssert(info.boxUUID && info.info.userDomain && info.boxType == ESBoxTypeAuth);
    ESDLog(@"[ESBoxManager][onAuth] %@", info);
    [ESBoxManager.manager onParing:info];
    [ESBoxManager onActive:info];
}

+ (void)onInviteMember:(ESBoxItem *)info {
    ESDLog(@"[ESBoxManager][onInviteMember] %@", info);
    NSParameterAssert(info.boxUUID && info.info.userDomain && info.boxType == ESBoxTypeMember);
    [ESBoxManager.manager onParing:info];
    [ESBoxManager onActive:info];
}


+ (ESBoxItem *)newOnInviteMember:(ESBoxItem *)info {
    ESDLog(@"[ESBoxManager][onInviteMember] %@", info);
    NSParameterAssert(info.boxUUID && info.info.userDomain && info.boxType == ESBoxTypeMember);
    [ESBoxManager.manager newOnParing:info];
    return info;
}

+ (ESBoxItem *)onJustInviteMember:(ESBoxItem *)info {
    ESDLog(@"[ESBoxManager][onInviteMember] %@", info);
    NSParameterAssert(info.boxUUID && info.info.userDomain && info.boxType == ESBoxTypeMember);
    [ESBoxManager.manager onParing:info];
    return info;
}

+ (void)onActive:(ESBoxItem *)info {
    ESDLog(@"[ESBoxManager][onActive] %@", info);
    [ESBoxManager.manager onActive:info];
    [[ESFamilyCache sharedInstance] getFamilyListFirstCache];
}

- (void)getFamilyList:(ESBoxItem *)info {
    ESDLog(@"[ESBoxManager][getFamilyList] %@", info);

    if (!self.activeBox) {
        return;
    }
    //查询接口是根据accessToken查询，对应的盒子是activeBox familyList
    if (![info.boxUUID isEqualToString: ESBoxManager.activeBox.boxUUID]) {
        return;
    }
    
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-account-service" apiName:@"member_list" queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        NSArray<ESAccountInfoResult *> * results = [NSArray yy_modelArrayWithClass:ESAccountInfoResult.class json:response];
        if (results.count <= 0) {
            return;
        }
        [results enumerateObjectsUsingBlock:^(ESAccountInfoResult  * _Nonnull accountModel, NSUInteger idx, BOOL * _Nonnull stop) {
            ESBoxItem *matchBoxItem = [ESBoxManager.manager getBoxItemWithBoxUuid:info.boxUUID boxType:info.boxType aoid:accountModel.aoId];
            if (matchBoxItem == nil) {
                //缓存原有数据错误， aoid对应不上，通过域名匹配，矫正数据
                matchBoxItem = [ESBoxManager.manager  getBoxItemWithUserDomain:accountModel.userDomain];
            }
           
            if (matchBoxItem == nil) {
                return;
            }

            if ( !([matchBoxItem.bindUserName isEqualToString: ESSafeString(accountModel.personalName)] &&
                 [matchBoxItem.aoid isEqualToString: ESSafeString(accountModel.aoId)] &&
                  [matchBoxItem.info.userDomain isEqualToString:ESSafeString(accountModel.userDomain)])) {
                matchBoxItem.bindUserName = accountModel.personalName;
                matchBoxItem.aoid = accountModel.aoId;
                matchBoxItem.info.userDomain = accountModel.userDomain;
                [self saveBox:matchBoxItem];
            }
            
            if ([ESBoxManager.activeBox.info.userDomain isEqualToString:ESSafeString(accountModel.userDomain)]) {
                self.activeBox.aoid = accountModel.aoId;
            }
        
            [self reqDeviceAbility];
            [[ESAccountManager manager] loadAvatar:accountModel.aoId
                                        completion:^(NSString *path) {
                                            strongfy(self)
                                            if (path.length > 0 && ![matchBoxItem.bindUserHeadImagePath isEqualToString:ESSafeString(path)]) {
                                                matchBoxItem.bindUserHeadImagePath = path;
                                                [self saveBox:matchBoxItem];
                                            }
                                        }];
        }];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

- (void)onParing:(ESBoxItem *)box {
    NSString *json = [box yy_modelToJSONString];
    ESDLog(@"[ESBoxManager][onParing] %@", json);
    [ESSafeCache.safeCache setObject:json forKey:kESBoxManagerInfoKey];
    [ESRSACenter.defaultCenter addBoxPublicPem:box.info.boxPubKey boxUUID:box.boxUUID];
    if ([self.boxList containsObject:box]) {
        return;
    }
    [self.boxList addObject:box];
    if (box.boxType == ESBoxTypePairing) {
        [self tryCleanAuthAndAdminBoxInfo:box];
    }
    [self saveBoxList];
}

//不配置activeBox
- (void)newOnParing:(ESBoxItem *)box {
    NSString *json = [box yy_modelToJSONString];
    ESDLog(@"[ESBoxManager][newOnParing] %@", json);
//    [ESSafeCache.safeCache setObject:json forKey:kESBoxManagerInfoKey];
    [ESRSACenter.defaultCenter addBoxPublicPem:box.info.boxPubKey boxUUID:box.boxUUID];
    if ([self.boxList containsObject:box]) {
        return;
    }
    [self.boxList addObject:box];
    [self saveBoxList];
}

- (void)saveBoxList {
    NSArray *result = [self.boxList valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [ESSafeCache.safeCache setObject:[result yy_modelToJSONString] forKey:kESBoxManagerBoxListKey];
    ESDLog(@"[ESBoxManager][saveBoxList] %@", result);
}

- (void)saveBox:(ESBoxItem *)box {
    ESDLog(@"[ESBoxManager][saveBox] %@", box);

    if (box == nil || box.boxUUID == nil) {
        return;
    }
        
    if ([box isEqual:self.activeBox]) {
        self.activeBox = box;
        NSString *json = [box yy_modelToJSONString];
        ESDLog(@"[ESBoxManager][kESBoxManagerInfoKey] %@", json);

        [ESSafeCache.safeCache setObject:json forKey:kESBoxManagerInfoKey];
    }
    
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([box isEqual:obj]) {
            [self.boxList replaceObjectAtIndex:idx withObject:box];
            *stop = YES;
        }
    }];
    [self saveBoxList];
}

- (ESBoxItem *)getBoxItemWithBoxUuid:(NSString *)boxUuid boxType:(ESBoxType)boxType aoid:(NSString *)aoid {
    __block ESBoxItem *matchBox;
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (boxType == obj.boxType &&
            [boxUuid isEqualToString:obj.boxUUID ?: @"null"] &&
            (!aoid || [aoid isEqualToString:obj.aoid ?: @"null"])) {
            matchBox = obj;
            *stop = YES;
        }
    }];
    return matchBox;
}

- (ESBoxItem *)getBoxItemWithUserDomain:(NSString *)userDomain {
    __block ESBoxItem *matchBox;
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([userDomain  isEqualToString:obj.info.userDomain ?: @"null"]) {
            matchBox = obj;
            *stop = YES;
        }
    }];
    return matchBox;
}

- (void)onActive:(ESBoxItem *)box {
    ESDLog(@"[ESBoxManager][onActive] %@", box);

    if (self.activeBox.boxType == ESBoxTypeAuth && ![self.activeBox isEqual:box]) {
        int i = 0;
        for(ESBoxItem *item in self.boxList){
            if(item.boxType == ESBoxTypeAuth){
                i++;
                if(i > 1){
                    [self.boxList removeObject:self.activeBox];
                }
                break;
            }
        }
        [self saveBoxList];
    }
    self.activeBox = box;
    [ESLocalNetworking.shared stopMonitor];
    
    self.clientUUID = ESSafeCache.clientUUID;
    //保存当前盒子信息
    [ESSafeCache.safeCache setObject:[self.activeBox yy_modelToJSONString] ?: @"" forKey:kESBoxManagerInfoKey];
    //设置盒子的公钥
    [ESRSACenter.defaultCenter addBoxPublicPem:box.info.boxPubKey boxUUID:box.boxUUID];
    //设置访问域名
    [self markBoxActive:box];
    ///取消所有上传的任务
    [ESNetworking.shared cancelAllTransfer:^{
    }];
    if (!box) {
        [ESDatabaseManager.manager close:^{

        }];
        return;
    }
    //防止重复, 先删除,然后插入到第一个
    if ([self.boxList containsObject:box]) {
        [self.boxList removeObject:box];
        [self.boxList insertObject:box atIndex:0];
    }
    
    //尝试清理boxList 管理员 + 授权 box
    if (box.boxType == ESBoxTypePairing) {
        [self tryCleanAuthAndAdminBoxInfo:box];
    }
    [self saveBoxList];
    /// 创建数据库
    /// 设置
    [self getFamilyList:box];
    [ESDatabaseManager.manager setupDatabase:box.uniqueKey
                                    onCreate:^{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [ESLocalNetworking.shared restartMonitor];
                                            ///同步文件列表
                                            [ESTableFileManager.shared trySync];
                                            ///重置自动同步数据库
                                            [ESUploadMetadata resetToWaitUpload:kESUploadMetadataTypeAutoUpload];
                                            
                                            [ESServiceManager startOrResetAllServicesWithBox:box];

                                            //发送消息,
                                            [NSNotificationCenter.defaultCenter postNotificationName:kESBoxActiveMessage object:nil];
                                        
                                            ///检测盒子与app是否兼容
                                            
                                            [ESVersionManager checkCompatibleAfterLaunch];
                                        });
                                    }];
    ESDLog(@"userDomain : %@", ESDefaultConfiguration.sharedConfig.host);
    ESDLog(@"authKey : %@", box.info.authKey);
    
    [self setAllBoxCookie];
}

- (void)setAllBoxCookie {
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * domain = obj.info.userDomain;
        [self setClientUUIDCookie:domain];
    }];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        ESDLog(@"[All Cookie]:%@", cookie);
    }
}

- (void)setClientUUIDCookie:(NSString *)domain {
//    if (!domain) {
//        return;
//    }

    NSString * value = ESBoxManager.clientUUID;
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"client_uuid", NSHTTPCookieName,
                                value, NSHTTPCookieValue,
                                ESSafeString(domain) , NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath,
                                nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    ESDLog(@"[setClientUUIDCookie] domain : %@ properties: %@", domain, properties);
}

- (void)tryCleanAuthAndAdminBoxInfo:(ESBoxItem *)boxItem {
    __block ESBoxItem *matchItem;
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [ESAccountInfoStorage accountType:obj] == ESAccountTypeAdminAuth &&
            [boxItem.boxUUID isEqualToString:ESSafeString(obj.boxUUID)]) {
            matchItem = obj;
            *stop = YES;
        }
    }];
    if (matchItem != nil) {
        [self.boxList removeObject:matchItem];
    }
}

- (void)markBoxActive:(ESBoxItem *)box {
    if (!box) {
        return;
    }

    //当前盒子的apiClient设置为`默认的apiClient`
    box.apiClient = ESApiClient.sharedClient;
    ///存储盒子信息到apiClient 中
    ESApiClient.sharedClient.yc_store(@"box", box);
    ESDLog(@"[SetBaseURL] markBoxActive-%@", box.prettyDomain);

    ///修改`默认的apiClient`的 host
    ESDefaultConfiguration.sharedConfig.host = box.prettyDomain;
    ESApiClient.sharedClient.baseURL = [NSURL URLWithString:box.prettyDomain];
    ESApiClient.sharedClient.timeoutInterval = 60;
}

- (void)setBoxIPConnect:(NSString *)ipDomain {
    ESDLog(@"[SetBaseURL] setBoxIPConnect-%@", ipDomain);

    ESDefaultConfiguration.sharedConfig.host = ipDomain;
    ESApiClient.sharedClient.baseURL = [NSURL URLWithString:ipDomain];
}

+ (ESBoxItem *)activeBox {
    return ESBoxManager.manager.activeBox;
}

+ (NSString *)deviceId {
    return ESSafeCache.deviceId.lowercaseString;
}

+ (NSString *)clientUUID {
    return ESBoxManager.manager.clientUUID;
}

+ (NSString *)deviceToken {
    return ESBoxManager.manager.deviceToken;
}

+ (NSString *)realClientUUID {
    return ESSafeCache.clientUUID;
}
+ (NSString *)realdomain {
    return ESBoxManager.manager.activeBox.info.userDomain;
}

+ (void)onRegisterDeviceToken:(NSString *)deviceToken {
    //ESBoxManager.manager.deviceToken = deviceToken;
}

+ (void)revoke:(ESBoxItem *)info {
    [ESBoxManager.manager revoke:info];
}

- (void)justRevoke:(ESBoxItem *)info {
    if (!info) {
        return;
    }

    //盒子列表删除该盒子
    [self.boxList removeObject:info];
    [ESDatabaseManager.manager reset];
    [self saveBoxList];
    if ([self.activeBox isEqual:info] || self.boxList.count == 0) {
        self.activeBox = nil;
        [self onActive:self.activeBox];
    }
}

- (void)revoke:(ESBoxItem *)info {
    if (!info) {
        return;
    }

    //盒子列表删除该盒子
    [self.boxList removeObject:info];
    [ESDatabaseManager.manager reset];
    [self saveBoxList];
    //当前盒子被解绑, 则没有活跃的盒子了
    //则要跳到登录(盒子列表)页面
    if ([self.activeBox isEqual:info] || self.boxList.count == 0) {
        self.activeBox = nil;
        [self onActive:self.activeBox];
        ///显示盒子列表(登录)页面
        [ESHomeCoordinator showHome];
    }
}

- (void)revokePush:(ESBoxItem *)info {
    if (!info) {
        return;
    }

    NSMutableArray *arrayData = [NSMutableArray new];
    NSMutableDictionary *dic = [NSMutableDictionary new];

    for (int i =0; i < self.boxList.count; i++) {
        ESBoxItem *item = ESBoxManager.bindBoxArray[i];
        NSString *key = [NSString stringWithFormat:@"%@%@",item.info.userDomain,item.info.boxName];
        if(item.info.userDomain.length > 0 && !dic[key] ){
            [arrayData addObject:item];
        }
        if(item.info.userDomain.length > 0){
            NSString *key = [NSString stringWithFormat:@"%@%@",item.info.userDomain,item.info.boxName];
            [dic setValue:@"1" forKey:key];
        }
    }
    
    //盒子列表删除该盒子
    for (int i = 0; i < arrayData.count ; i++) {
        ESBoxItem *data = arrayData[i];
        if([data.boxUUID isEqual:info.boxUUID] && data.boxType == info.boxType){
            [arrayData removeObjectAtIndex:i];
        }
    }
    self.boxList = arrayData;
    
    [ESDatabaseManager.manager reset];
    [self saveBoxList];
    //当前盒子被解绑, 则没有活跃的盒子了
    //则要跳到登录(盒子列表)页面
    if ([self.activeBox isEqual:info] || self.boxList.count == 0) {
        self.activeBox = nil;
        [self onActive:self.activeBox];
    }
}

+ (BOOL)boxExist:(NSString *)boxUUID {
    return [ESBoxManager.manager boxExist:boxUUID];
}

- (BOOL)boxExist:(NSString *)boxUUID {
    ESPairingBoxInfo *pair = [ESPairingBoxInfo new];
    pair.boxUuid = boxUUID;
    ESBoxItem *box = [ESBoxItem fromPairing:pair];
    NSUInteger index = [self.boxList indexOfObject:box];
    for (int i = 0; i<self.boxList.count ; i++) {
        ESBoxItem *memberBox = self.boxList[i];
        if (memberBox.boxType == ESBoxTypeMember) {
            if ([boxUUID isEqual:memberBox.boxUUID]) {
                return  YES;
            }
        }
    }

    if (index == NSNotFound) {
        return NO;
    }
    ///取出真正的盒子, 如果不是授权的, 才算是存在
    ESBoxItem *realBox = self.boxList[index];
    return realBox.boxType != ESBoxTypeAuth;
}

- (void)setupSocket {
    [ESSessionClient sharedInstance].deviceId = ESBoxManager.deviceId;
    [ESSessionClient sharedInstance].clientUUID = ESBoxManager.clientUUID;
    [[ESSessionClient sharedInstance] start];
}

+ (void)hello {
    if (!ESBoxManager.activeBox) {
        return;
    }
    [self loadOnlineState:ESBoxManager.activeBox completion:nil];
}
/// 刷新
+ (void)loadOnlineState:(ESBoxItem *)box completion:(void (^)(BOOL offline))completion {
     //1.确定请求路径

    [[ESRedirectManage manager] getRedirectWithBox:ESBoxManager.activeBox];
 
    ESApiClient *apiClient = [ESApiClient es_box:box];
    apiClient.timeoutInterval = 30;
    ESPlatformServiceStatusApi *api = [[ESPlatformServiceStatusApi alloc] initWithApiClient:apiClient];
    [api setDefaultHeaderValue:@"no-cache" forKey:@"Cache-Control"];
    
    [api spaceStatusGetWithCompletionHandler:^(ESStatusResult *output, NSError *error) {
        ESDLog(@"[盒子是否在线日志] 拿到可用的channel %@ %ld", output.message,(long)error.code);

        if (!error) {
            if(ESBoxManager.activeBox.boxType != ESBoxTypePairing){
                [ESBoxManager.manager getFamilyList:box];
            }
            box.offline = ![output.status isEqualToString:@"ok"];

            if (completion) {
                completion(box.offline);
            }
        }else{
            if(ESBoxManager.activeBox.boxType != ESBoxTypePairing){
                NSString *str = error.userInfo[@"NSLocalizedDescription"];
                if([str containsString:@"Request failed: client error (460)"]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"domainRewriteTimeout" object:nil];
                    return;
                }
            }
            NSString *str = error.userInfo[@"NSLocalizedDescription"];
            if([str containsString:@"Request failed: client error (461)"]){
                box.showTrailUnvalied = YES;
            }
            if (completion) {
                completion(YES);
            }
        }
    }];
    
}

+ (void)checkBoxStateByIP:(NSString *)ipDomain completion:(void (^)(BOOL offline))completion {
    NSDictionary * header = @{@"Cache-Control" : @"no-cache"};
    [ESNetworkRequestManager sendRequest:ipDomain path:@"/space/status" method:@"GET" queryParams:nil header:header body:nil modelName:@"ESStatusResult" successBlock:^(NSInteger requestId, ESStatusResult * response) {
        ESDLog(@"loadBoxState userDomain : [%@] - status : [%@]", ipDomain, response.status);
        BOOL offline = ![response.status isEqualToString:@"ok"];
        if (completion) {
            completion(offline);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"loadBoxState userDomain : [%@] - error:%@", ipDomain, error);
        if (completion) {
            completion(YES);
        }
    }];
}

+ (void)checkBoxStateByDomain:(void (^)(BOOL offline))completion {
    NSDictionary * header = @{@"Cache-Control" : @"no-cache"};
    [ESNetworkRequestManager sendRequest:@"/space/status" method:@"GET" queryParams:nil header:header body:nil modelName:@"ESStatusResult" successBlock:^(NSInteger requestId, ESStatusResult * response) {
        ESDLog(@"loadBoxState userDomain : status : [%@]", response.status);
        BOOL offline = ![response.status isEqualToString:@"ok"];
        if (completion) {
            completion(offline);
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"loadBoxState userDomain : - error:%@", error);
        if (completion) {
            completion(YES);
        }
    }];
}

// 当前盒子更新平台地址 
- (void)loadCurrentBoxOnlineState:(void (^)(BOOL offline))completion {
    self.justLaunch = NO;

    ESPlatformServiceStatusApi *api = [[ESPlatformServiceStatusApi alloc] initWithApiClient:ESApiClient.sharedClient];
    ESDLog(@"[盒子是否在线日志] url: %@", api.apiClient.baseURL.absoluteString);

    [api setDefaultHeaderValue:@"no-cache" forKey:@"Cache-Control"];
    [api spaceStatusGetWithCompletionHandler:^(ESStatusResult *output, NSError *error) {
        ESDLog(@"[盒子是否在线日志] 拿到可用的channel %@ %ld", output.message,(long)error.code);
        if (!error) {
            if(output.platformInfo.count > 0){
                ESBoxManager.activeBox.platformUrl = output.platformInfo[@"platformUrl"];
                NSNumber *isBool = output.platformInfo[@"official"];
                if(isBool.boolValue){
                    [ESPlatformClient setHost:output.platformInfo[@"platformUrl"]];
                    NSString *str = output.platformInfo[@"platformUrl"];
                    if(str.length > 0){
                        [ESPlatformClient setHost:output.platformInfo[@"platformUrl"]];
                        NSURL *url = [NSURL URLWithString:output.platformInfo[@"platformUrl"]];
                        ESPlatformClient.platformClient.baseURL= url;
                        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"platformUrl"];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"official"];
                }else{
                    NSString *str = output.platformInfo[@"platformUrl"];
                    if(str.length > 0){
                        [ESPlatformClient setHost:output.platformInfo[@"platformUrl"]];
                        NSURL *url = [NSURL URLWithString:output.platformInfo[@"platformUrl"]];
                        ESPlatformClient.platformClient.baseURL= url;
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"official"];
                    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"platformUrl"];
                }
                [self setClientUUIDCookie:output.platformInfo[@"platformUrl"]];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"official"];
            }
            
            ESDLog(@"loadOnlineState userDomain : [%@] - status : [%@]", self.activeBox.info.userDomain, output.status);
            self.activeBox.offline = ![output.status isEqualToString:@"ok"];
//            apiClient.timeoutInterval = 10;
            if (completion) {
                completion(self.activeBox.offline);
            }
        }else{
            if(ESBoxManager.activeBox.boxType != ESBoxTypePairing){
                NSString *str = error.userInfo[@"NSLocalizedDescription"];
                if([str containsString:@"Request failed: client error (460)"]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"domainRewriteTimeout" object:nil];
                    return;
                }
            }
        }
    }];
}

+ (NSDictionary *)cacheInfoForBox:(ESBoxItem *)box {
   ESBoxItem *boxBindInfo = [ESBoxManager.manager getBoxItemWithBoxUuid:box.boxUUID boxType:box.boxType aoid:box.aoid];
    if (boxBindInfo == nil) {
        boxBindInfo = [ESBoxManager.manager getBoxItemWithUserDomain:box.info.userDomain];
    }
    if (boxBindInfo == nil) {
        return nil;
    }

    BOOL isAdmin = boxBindInfo.boxType == ESBoxTypePairing || (boxBindInfo.boxType == ESBoxTypeAuth && [box.aoid isEqualToString:@"aoid-1"]);
    return @{@"aoId" : ESSafeString(boxBindInfo.aoid),
             @"isAdmin" : @(isAdmin),
             @"userDomain" : ESSafeString(boxBindInfo.info.userDomain),
             @"personalName" : ESSafeString(boxBindInfo.bindUserName),
             @"imagePath" : ESSafeString(boxBindInfo.bindUserHeadImagePath),
             @"administratorUserDomain" : isAdmin ? ESSafeString(boxBindInfo.info.userDomain) : @"",
             
    };
}

-(void)removeBoxList:(ESBoxItem *)item{
    [self.boxList removeObject:item];
}

- (void)reqDeviceAbility:(void (^)(ESDeviceAbilityModel * model))successBlock fail:(void (^)(NSError * error))failBlock {
    if (!successBlock) {
        return;
    }
    
    NSString * key = [NSString stringWithFormat:@"%@_deviceAbility", self.activeBox.boxUUID];
    NSString * value = self.boxReqDict[key];
    if (value && value.length > 0 && self.activeBox.deviceAbilityModel) {
        successBlock(self.activeBox.deviceAbilityModel);
        return;
    }
    
    if (self.activeBox.offline && self.activeBox.bindInitResultModel.deviceAbility) {
        successBlock(self.activeBox.bindInitResultModel.deviceAbility);
        return;
    }
    
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:device_ability queryParams:nil header:nil body:nil modelName:@"ESDeviceAbilityModel" successBlock:^(NSInteger requestId, ESDeviceAbilityModel * response) {
        self.activeBox.deviceAbilityModel = response;
        self.boxReqDict[key] = @"yes";
        successBlock(response);
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
}

- (NSString *)getAoidValue {
    NSString * aoid = self.activeBox.aoid;
    NSArray * arr = [aoid componentsSeparatedByString:@"-"];
    if (arr.count == 2) {
        return arr.lastObject;
    }
    return @"";
}

- (ESBoxIPResp *)getBoxIpResp {
    return self.activeBox.boxIPResp;
}

- (void)saveBoxIp:(ESBoxItem *)box boxIP:(ESBoxIPResp *)boxIP {
    if (box == nil) {
        return;
    }
    
    if ([box isEqual:self.activeBox]) {
        // 1. 若是当前盒子，要对此数据更新后，再保存 activeBox，避免存在数据读写不一致问题
        self.activeBox.boxIPResp = boxIP;
        [self saveBox:box];
        return;
    }
    
    // 2. 更新盒子列表
    __block ESBoxItem * tmpBox;
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:box]) {
            obj.boxIPResp = boxIP;
            tmpBox = obj;
        }
    }];
    
    [self saveBox:tmpBox];
}

- (void)reqBtid:(ESBoxItem *)item {
    ESDLog(@"[ReqBtid] SendBox:%@", item.uniqueKey);
    [ESNetworkRequestManager sendCallRequest:@{ServiceName : eulixspaceAccountService,
                                               ApiName : device_hardware_info
                                             } queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id response) {
        if (response && response[@"btid"]) {
            ESDLog(@"[ReqBtid] SendBox:%@", item.uniqueKey);
            ESDLog(@"[ReqBtid] ActiveBox:%@", self.activeBox.uniqueKey);

            item.btid = response[@"btid"];
            [self saveBox:item];
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

- (BOOL)pairingBoxCachedWithUUID:(NSString *)boxUUID {
    __block ESBoxItem *matchBoxItem;
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.boxUUID isEqualToString:ESSafeString(boxUUID)] && item.boxType == ESBoxTypePairing) {
            matchBoxItem = item;
            *stop = YES;
        }
    }];
    if (matchBoxItem == nil) {
        return NO;
    }
    
    return YES;
}

- (void)saveBoxUserDomain:(ESBoxItem *)box{
    if (box == nil) {
        return;
    }

    // 1. 若是当前盒子，要对此数据更新后，再保存 activeBox，避免存在数据读写不一致问题
    if ([box isEqual:self.activeBox]) {
        self.activeBox.info.userDomain = box.info.userDomain;
        [self saveBox:box];
        return;
    }
    
    // 2. 更新盒子列表
    [self.boxList enumerateObjectsUsingBlock:^(ESBoxItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:box]) {
            obj.info.userDomain = box.info.userDomain;
        }
    }];

    [self saveBoxList];
}

@end

