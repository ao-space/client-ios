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
//  ESTransferCellItem.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YCBase/YCItemDefine.h>
#import "ESTransferTask.h"
#import "ESUploadMetadata.h"


@interface ESTransferCellItem : NSObject <YCItemProtocol>

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSAttributedString *attributedTitle;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *state;

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) ESTransferTask *data;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) ESUploadMetadata *metadata;

///
@property (nonatomic, assign) BOOL inSelectionMode;

@property (nonatomic, copy) void (^notifyListener)(void);

@end
