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
//  ESSpaceInitialZationProcessModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceInitialZationProcessModule.h"
#import "ESProcessLineItemCell.h"
#import "ESProcessItemCell.h"
#import "NSObject+YYModel.h"

@interface ESSpaceInitialZationProcessModule ()

@property (nonatomic, strong) NSArray *processList;

@end

@implementation ESSpaceInitialZationProcessModule

- (void)processedIndex:(ESSpaceInitialZationProcess)process {
    if (self.listData.count <= 0) {
        self.processList = [self processItems];
        [self reloadData:self.processList];
    }
    [self.processList enumerateObjectsUsingBlock:^(ESProcessItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((NSInteger)idx <= process) {
            item.iconName = @"processed";
        } else {
            item.iconName = @"unprocessed";
        }
    }];
    [self reloadData:self.processList];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0 ) {
        return 30.0f;
    }
    return 40.0f;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0 ) {
        return [ESProcessItemCell class];
    }
    return [ESProcessLineItemCell class];
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    return NO;
}

- (NSArray<ESProcessItem *> *)processItems {
    return [NSArray yy_modelArrayWithClass:ESProcessItem.class json:self.actionDataList];
}

- (NSArray *)actionDataList {
    return @[
        @{@"iconName" : @"unprocessed",
          @"title" : NSLocalizedString(@"binding_encryptedchannels", @"启动加密通道"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" : @"line",     //NSLocalizedString(@"Select", @"选择"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" : NSLocalizedString(@"binding_fileservice", @"启动文件服务"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" : @"line",     //NSLocalizedString(@"Select", @"选择"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" : NSLocalizedString(@"binding_encryptiongateway", @"启动加密网关"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" : @"line",     //NSLocalizedString(@"Select", @"选择"),
        },
        @{@"iconName" : @"unprocessed",
          @"title" :  NSLocalizedString(@"binding_corecomponents", @"启动核心组件"),
        },
    ];
}
@end
