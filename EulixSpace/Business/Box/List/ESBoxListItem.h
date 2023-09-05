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
//  ESBoxListItem.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YCBase/YCItemDefine.h>

@class ESBoxItem;
@interface ESBoxListItem : NSObject <YCItemProtocol>

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) bool inuse;

//@property (nonatomic, assign) bool isUse;

@property (nonatomic, assign) bool online;

@property (nonatomic, copy, readonly) NSString *state;

@property (nonatomic, copy) NSString *actionTitle;

@property (nonatomic, strong) ESBoxItem *data;

@property (nonatomic, strong) NSString *category;

//@property (nonatomic, assign) bool isPushOnLine;

@end
