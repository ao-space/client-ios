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
//  ESAvatarCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/7/10.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ESAvatarItemProtocol

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL hasNextStep;
@property (nonatomic, assign) NSInteger actionTag;

@end

@interface ESAvatarlItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL hasNextStep;
@property (nonatomic, assign) NSInteger actionTag;

@end

@interface ESAvatarCell : ESBaseCell

@end

NS_ASSUME_NONNULL_END
