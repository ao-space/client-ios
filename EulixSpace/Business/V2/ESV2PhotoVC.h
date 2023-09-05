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
//  ESV2PhotoVC.h
//  EulixSpace
//
//  Created by qu on 2022/12/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//
#import <YCBase/YCViewController.h>
#import "ESPhotoModel.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ESV2PhotoVC : YCViewController

@property (nonatomic, strong) ESPhotoModel *albumModel;

@property (nonatomic, strong) NSMutableArray *assetCollectionList;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *dir;

@property (nonatomic, copy) NSString *recordid;

@property (nonatomic, copy) NSString *uploadDir;

@property (nonatomic, strong) NSNumber *photoNumer;

@property (strong, nonatomic) NSMutableArray *dataList;

@property (nonatomic, strong) NSString *name;

@end

NS_ASSUME_NONNULL_END
