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
//  ESV2PhotoCell.h
//  EulixSpace
//
//  Created by qu on 2022/12/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import "ESFileInfoPub.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ESCollectionViewCellAction)(ESFileInfoPub *info);

@class ESV2PhotoCell;

@protocol ESV2PhotoCell <NSObject>

@optional

- (void)vPhotoCell:(ESV2PhotoCell *_Nullable)photoCollectionCell didCellClickSelectedBtn:(UIButton *_Nullable)button;
@end

@interface ESV2PhotoCell : UICollectionViewCell

/// 行数
@property (nonatomic, assign) NSInteger row;

/// 选中事件
@property (nonatomic, copy) ESCollectionViewCellAction selectPhotoAction;
/// 是否被选中
@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) ESFileInfoPub *info;

@property (nonatomic, strong) UIImageView *selectIcon;
@end
NS_ASSUME_NONNULL_END
