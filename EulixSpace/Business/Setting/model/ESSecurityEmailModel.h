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
//  ESSecurityEmailModel.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESSecurityEmailModel : NSObject
@property (nonatomic, strong) NSString * emailAccount;
// smtp service
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * port;
@property (nonatomic, assign) BOOL sslEnable;
@end


@interface ESSecurityEmailInfosModel : NSObject
@property (nonatomic, strong) NSString * provider;
@end

@interface ESSecurityEmailServersModel : NSObject
@property (nonatomic, strong) NSString * host;
@property (nonatomic, strong) NSString * port;
@property (nonatomic, assign) BOOL sslEnable;

@end

@interface ESSecurityEmailConfigItemModel : NSObject
@property (nonatomic, strong) ESSecurityEmailInfosModel * infos;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ESSecurityEmailServersModel *> * servers;
@end

@interface ESSecurityEmailConfigModel : NSObject
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) NSMutableDictionary<NSString *, ESSecurityEmailConfigItemModel *> * configurations;

- (ESSecurityEmailServersModel *)getServers:(NSString *)emailType smtp:(BOOL)isSMTP;

@end

NS_ASSUME_NONNULL_END
