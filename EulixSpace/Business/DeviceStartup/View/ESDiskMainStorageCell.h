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
//  ESDiskMainStorageCell.h
//  EulixSpace
//
//  Created by dazhou on 2022/10/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+ESSize.h"
#import "UIColor+ESHEXTransform.h"
#import "ESDiskRecognitionResp.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESDiskMainStorageModel : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL isRecommend;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, copy) void (^onClick)(void);

// 1: normal; 2: raid1。
@property (nonatomic, assign) ESDiskStorageModeType raidType;
@property (nonatomic, strong) NSMutableArray<ESDiskInfoModel *> * diskInfoList;
@end

@interface ESDiskMainStorageCell : UITableViewCell
@property (nonatomic, strong) ESDiskMainStorageModel * model;
@end

NS_ASSUME_NONNULL_END
