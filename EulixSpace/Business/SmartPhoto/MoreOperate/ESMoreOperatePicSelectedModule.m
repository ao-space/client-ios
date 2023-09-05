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
//  ESMoreOperatePicSelectedModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/10.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMoreOperatePicSelectedModule.h"
#import "ESPicModel.h"

@implementation ESMoreOperatePicSelectedModule

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    self.selectedInfoArray = selectedList;
    NSMutableArray *uuidList = [NSMutableArray array];
    [selectedList enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uuidList addObject:ESSafeString(obj.uuid)];
    }];
    self.isSelectUUIDSArray = uuidList;
}

- (NSArray *)validSelectedInfoArray {
    if (self.isSelectUUIDSArray.count == 1) {
        return self.selectedInfoArray;
    } else if (self.isSelectUUIDSArray.count > 1) {
        NSMutableArray *selectedInfoList = [NSMutableArray array];

        [self.selectedInfoArray enumerateObjectsUsingBlock:^(ESPicModel * _Nonnull pic, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([pic isKindOfClass:[ESPicModel class]] && ![pic.uuid hasPrefix:@"mock"]) {
                [selectedInfoList addObject:pic];
            }
        }];
        return [selectedInfoList copy];
    }
    return @[];
   
}

- (NSArray *)validSelectedUUIDArray {
    if (self.isSelectUUIDSArray.count == 1) {
        return self.isSelectUUIDSArray;
    } else if (self.isSelectUUIDSArray.count > 1) {
        NSMutableArray *selectedUUIDList = [NSMutableArray array];
        [self.isSelectUUIDSArray enumerateObjectsUsingBlock:^(NSString * _Nonnull uuid, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([uuid isKindOfClass:[NSString class]] && ![uuid hasPrefix:@"mock"]) {
                [selectedUUIDList addObject:uuid];
            }
        }];
        return [selectedUUIDList copy];
    }
    return @[];
}

@end
