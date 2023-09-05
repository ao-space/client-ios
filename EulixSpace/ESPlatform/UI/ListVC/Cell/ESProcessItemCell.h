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
//  ESProcessItemCell.h
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESIconTitleCell.h"

NS_ASSUME_NONNULL_BEGIN



@interface ESProcessItem : NSObject <ESIconTitleCellModelProtocol>

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;

@end

@interface ESProcessItemCell : ESIconTitleCell

@end

NS_ASSUME_NONNULL_END