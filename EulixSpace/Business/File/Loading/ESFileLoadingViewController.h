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
//  ESFileLoadingViewController.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/8/30.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <YCBase/YCBase.h>

@class ESFileInfoPub;

@interface ESFileLoadingViewController : YCViewController

+ (instancetype)asEmbed:(ESFileInfoPub *)file completion:(void (^)(void))completion;

@end

extern void ESFileShowLoading(UIViewController *from, ESFileInfoPub *info, BOOL preview, void (^completion)(void));
