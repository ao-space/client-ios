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
//  ESSortSheetListModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESSortSheetListModule.h"
#import "ESActionSheetCell.h"
#import "ESActionSheetItem.h"
#import "ESSortSheetVC.h"

@implementation ESSortSheetListModule

- (CGFloat)defalutActionHeight {
    return 62.0f;
}

- (void)selectedIndex:(NSInteger)index {
    [self.listData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ESActionSheetItem class]]) {
            ESActionSheetItem *item = (ESActionSheetItem *)obj;
            item.isSelected = (idx == index && item.isSelectedTyple);
        }
    }];
    [self.listView reloadData];
}

@end
