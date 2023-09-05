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
//  ESFeedbackImagItem.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface ESFeedbackImagItem : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *localPath;

@property (nonatomic, copy) NSString *name;

///上传到服务器才有的, 不需要初始化
@property (nonatomic, copy, readonly) NSString *url;

@end
