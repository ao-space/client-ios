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
//  ESTitleTagLeftCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/9.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@class ESTagItem;
@protocol ESTitleTagItemProtocol

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<ESTagItem *> *tagList;
@property (nonatomic, assign) BOOL hasNextStep;
@property (nonatomic, assign) NSInteger actionTag;

@end

@interface ESTitleTagItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<ESTagItem *> *tagList;
@property (nonatomic, assign) NSInteger actionTag;
@property (nonatomic, assign) BOOL hasNextStep;

@end

@interface ESTagItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *backgroudColor;

@end

typedef void (^ESActionCellBlock)(ESBaseCell *cell, NSInteger actionTag);

@interface ESTitleTagLeftCell : ESBaseCell

@property (nonatomic, copy) ESActionCellBlock actionBlock;

@end

NS_ASSUME_NONNULL_END
