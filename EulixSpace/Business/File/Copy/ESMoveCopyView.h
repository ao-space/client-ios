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
//  ESMoveCopyView.h
//  EulixSpace
//
//  Created by qu on 2021/8/31.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESMoveCopyView;

@protocol ESMoveCopyViewDelegate <NSObject>

@optional

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClicCancelBtn:(UIButton *)button;

- (void)fileMoveCopyView:(ESMoveCopyView *)fileBottomToolView didClickCompleteBtnWithPath:(NSString *)pathName selectUUID:(NSString *)uuid category:(NSString *)category;

@end

@interface ESMoveCopyView : UIView

@property (nonatomic, weak) id<ESMoveCopyViewDelegate> delegate;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, strong) NSMutableArray *isSelectUUIDSArray;

@property (nonatomic, assign) NSUInteger selectNum;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *uuid;

@end
