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
//  ESSapceUpgradeInfoModel.h
//  EulixSpace
//
//  Created by KongBo on 2022/7/21.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESBoxUpgradeType) {
    ESBoxUpgradeTypeDefault,
    ESBoxUpgradeTypeForcexUpgrade,
};


@interface ESSapceUpgradeInfoModel : NSObject

@property (nonatomic, assign) ESBoxUpgradeType upgradeType;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *pkgSize;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *packName;
@property (nonatomic, copy) NSString *pckVersion;
@property (nonatomic, assign) BOOL haveNew;
@property (nonatomic, assign) BOOL isVarNewVersionExist;
@property (nonatomic, assign) BOOL needRestart;

@end

NS_ASSUME_NONNULL_END
