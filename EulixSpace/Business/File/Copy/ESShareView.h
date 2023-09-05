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
//  ESShareView.h
//  EulixSpace
//
//  Created by qu on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ESShareView;

@protocol ESShareViewDelegate <NSObject>

@optional

- (void)shareView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button;

- (void)shareViewShareOther:(ESShareView *)shareView;

- (void)otherShareLinkBtnTap:(NSString *)linkStr;

@end

@interface ESShareView : UIView

@property (nonatomic, strong) NSArray<NSString*>* fileIds;

@property (nonatomic, weak) id<ESShareViewDelegate> delegate;

@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) UILabel *autoCode;

@property (nonatomic, strong) UILabel *pNum;

@property (nonatomic, strong) NSString *autuCodeStr;

@property (nonatomic, strong) NSString *linkAutuCodeStr;

@property (nonatomic, strong) NSString *linkShareUrl;

@property (nonatomic, strong) NSString *linkName;

@property (nonatomic, strong) NSString *lineClass;

@property (nonatomic, strong) NSString *shareId;

- (void)didClicknShareVXWithShareUrl:(NSString *)shareUrl name:(NSString *)name;

-(void)didClickQQShareBtn:(NSString *)shareUrl name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END