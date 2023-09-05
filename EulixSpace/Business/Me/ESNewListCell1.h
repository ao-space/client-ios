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
//  ESNewListCell1.h
//  EulixSpace
//
//  Created by dazhou on 2022/9/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESNotificationPageInfoModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface ESNewsModel : NSObject

@property (nonatomic, strong) NSString * timeStr;
@property (nonatomic, strong) NSString * typeTitle;
@property (nonatomic, strong) NSString * desTitle;
@property (nonatomic, strong) NSString * content;
// onClick 不为nil，则表示有 查看详情 功能
@property (nonatomic, copy) void (^onClick)(ESNotificationEntityModel * data);

@property (nonatomic, strong) ESNotificationEntityModel * data;

@end

@interface ESNewListCell1 : UITableViewCell

@property (nonatomic, strong) ESNewsModel * model1;

@end

NS_ASSUME_NONNULL_END
