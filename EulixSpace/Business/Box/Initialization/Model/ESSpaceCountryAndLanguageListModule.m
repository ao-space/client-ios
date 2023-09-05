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
//  ESSpaceCountryAndLanguageListModule.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/21.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceCountryAndLanguageListModule.h"
#import "ESTitleDetailCell.h"

@interface ESCountryAndLanguageListItem : NSObject <ESTitleDetailCellModelProtocol>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@end

@implementation ESCountryAndLanguageListItem

@end

@interface ESSpaceCountryAndLanguageListModule ()

@end

@implementation ESSpaceCountryAndLanguageListModule

-(NSArray *)listData {
    ESCountryAndLanguageListItem *item1 = [ESCountryAndLanguageListItem new];
    item1.title = NSLocalizedString(@"space_country", @"所属国家");
    item1.detail = NSLocalizedString(@"binding_country",@"中国");
    
    ESCountryAndLanguageListItem *item2 = [ESCountryAndLanguageListItem new];
    item2.title = NSLocalizedString(@"space_language", @"选择语言");
    item2.detail = NSLocalizedString(@"binding_language",@"简体中文");
    return @[item1, item2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0f;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ESTitleDetailCell class];
}

- (BOOL)showSeparatorStyleSingleLineWithIndex:(NSIndexPath *)indexPath {
    if (indexPath.row == self.listData.count - 1) {
        return NO;
    }
    return YES;
}
@end
