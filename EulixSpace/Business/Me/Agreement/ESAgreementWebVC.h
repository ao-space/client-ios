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
//  ESAgreementWebVC.h
//  EulixSpace
//
//  Created by qu on 2021/11/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YCBase/YCViewController.h>
#import "ESAppletInfoModel.h"
#import "ESFormItem.h"

typedef NS_ENUM(NSUInteger, ESAgreementWebType) {
    ESUserAgreement,
    ESAppOpen,
    ESConcealtAgreement,
};

NS_ASSUME_NONNULL_BEGIN

@interface ESAgreementWebVC : YCViewController

@property (nonatomic, assign) ESAgreementWebType agreementType;

@property (nonatomic, assign) NSString *source;

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) ESAppletInfoModel* appletInfo;

@property (nonatomic, strong) ESFormItem* item;
@end

NS_ASSUME_NONNULL_END
