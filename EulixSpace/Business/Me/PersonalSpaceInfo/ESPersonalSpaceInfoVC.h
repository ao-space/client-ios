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
//  ESPersonalSpaceInfoVC.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESConnectedNetworkModel : NSObject
@property(nonatomic, strong) NSString * ip;

@property(nonatomic, assign) long port;
@property(nonatomic, assign) long tlsPort;
@property(nonatomic, strong) NSString* wifiName;
@property(nonatomic, assign) BOOL wire;

@end

@interface ESInternetServiceConfigModel : NSObject

@property (nonatomic, assign) BOOL enableInternetAccess;
@property (nonatomic, assign) BOOL enableLAN;
@property (nonatomic, assign) BOOL enableP2P;
@property (nonatomic, copy) NSString *userDomain;
@property (nonatomic, copy) NSArray<ESConnectedNetworkModel *> *connectedNetwork;

@end

@interface ESPersonalSpaceInfoVC : ESBaseTableVC

- (void)changeAvatar;

@end

NS_ASSUME_NONNULL_END
