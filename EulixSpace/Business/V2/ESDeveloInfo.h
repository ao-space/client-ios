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
//  ESDeveloInfo.h
//  EulixSpace
//
//  Created by qu on 2022/1/9.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ESDeveloInfo : NSObject

@property (nonatomic, strong) NSString * imageName;
@property (nonatomic, strong) NSString * className;
@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) NSString * value;

@property (nonatomic, strong) NSMutableArray * volumes;

@property (nonatomic, strong) NSMutableArray * environments;

@property (nonatomic, strong) NSString * value1;

@property (nonatomic, strong) NSString * value2;

@property (nonatomic, strong) UIColor * valueColor;

@property (nonatomic, strong) NSDictionary * dicParameter;
// value是否为密文显示，默认 NO
@property (nonatomic, assign) BOOL isCipher;

@property (nonatomic, strong) NSString * placeholderValue;
@property (nonatomic, strong) NSAttributedString * attributedPlaceholder;
@property (nonatomic, strong) UIColor * placeholderValueColor;
@property (nonatomic, strong) NSString * inputValue;

@property (nonatomic, assign) BOOL hasArrow;

@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, copy) void (^onClick)(void);

@property (nonatomic, weak) id srcModel;


@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) BOOL isHaveError;

@property (nonatomic, copy) NSString *errorMsg;

@property (nonatomic, assign) int errorInt;

@property (nonatomic, strong) NSMutableDictionary *errorDic;


@property (nonatomic, copy) NSArray *errorArray;


@end


NS_ASSUME_NONNULL_END
