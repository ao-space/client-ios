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
//  ESActionSheetController.h
//  EulixSpace
//
//  Created by dazhou on 2023/5/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "YCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESActionSheetModel : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL hiddenLineView;
@property (nonatomic, assign) long tag;
@property (nonatomic, weak) id originalData;
@end

@interface ESActionSheetController : YCViewController

+ (void)showActionSheetView:(UIViewController *)srcCtl
                      title:(NSString *)title
                       data:(NSMutableArray *)dataArr
                      block:(void(^)(long index))selectBlock;

@end

NS_ASSUME_NONNULL_END
