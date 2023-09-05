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
//  ESDeleteProcessStatusVC.h
//  EulixSpace
//
//  Created by KongBo on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESProcessStatusVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ESProcessStatusUpdateBlock)(BOOL success, BOOL isFinished, CGFloat process);

@interface ESCommonProcessStatusVC : ESProcessStatusVC

@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) ESProcessStatusUpdateBlock processUpdateBlock;
@property (nonatomic, copy) NSString *customProcessTitle; //自定义处理的title

- (void)showFrom:(UIViewController *)vc;
- (void)hidden:(BOOL)immediately;

@end

NS_ASSUME_NONNULL_END
