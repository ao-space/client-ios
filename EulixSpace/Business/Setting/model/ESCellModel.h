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
//  ESCellModel.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESCellModelValueType) {
    ESCellModelValueType_Label,
    ESCellModelValueType_TextField,
};

@interface ESCellModel : NSObject

@property (nonatomic, assign) ESCellModelValueType valueType;

@property (nonatomic, strong) NSString * imageName;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * describeContent;
@property (nonatomic, strong) NSString * value;

@property (nonatomic, strong) NSArray * er;

@property (nonatomic, strong) UIColor * valueColor;
// value是否为密文显示，默认 NO
@property (nonatomic, assign) BOOL isCipher;

@property (nonatomic, strong) NSString * placeholderValue;
@property (nonatomic, strong) NSAttributedString * attributedPlaceholder;
@property (nonatomic, strong) UIColor * placeholderValueColor;
@property (nonatomic, strong) NSString * inputValue;

@property (nonatomic, assign) BOOL hasArrow;

@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL isSelected;
// 已选中，但不能修改的选中
@property (nonatomic, assign) BOOL isSelectedNotChange;

@property (nonatomic, copy) void (^onClick)(void);

@property (nonatomic, weak) id srcModel;


@end


@interface ESAuthenticationTypeModel : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * imageName;

@property (nonatomic, copy) void (^onClick)(void);

@end

NS_ASSUME_NONNULL_END
