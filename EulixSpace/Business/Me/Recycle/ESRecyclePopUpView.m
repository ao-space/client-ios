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
//  ESRecyclePopUpView.m
//  EulixSpace
//
//  Created by qu on 2022/3/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESRecyclePopUpView.h"

@implementation ESRecyclePopUpView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
        if ([self.category isEqual:@"clear"]) {
         ///   self.pointOutLabel.text = @"是否确定清空所有文件？清空后将无法恢复";
            self.pointOutLabel.text = NSLocalizedString(@"Do you clear all files? It cannot be restored after emptying", @"是否确定清空所有文件？清空后将无法恢复");
            [self.delectCompleteBtn setTitle:NSLocalizedString(@"Confirm Clear", @"确认清空") forState:UIControlStateNormal];
        }else if ([self.category isEqual:@"del"]) {
            self.pointOutLabel.text = NSLocalizedString(@"Are you sure you want to delete the selected files? It cannot be recovered after deletion", @"是否确定删除选中的文件？删除后将无法恢复");
            [self.delectCompleteBtn setTitle:NSLocalizedString(@"Confirm Delete", @"确认删除") forState:UIControlStateNormal];
        }
        else{
            self.pointOutLabel.text = NSLocalizedString(@"Are you sure you want to restore the selected files?", @"是否确定还原选中的文件？") ;
            [self.delectCompleteBtn setTitle:NSLocalizedString(@"Restore", @"还原") forState:UIControlStateNormal];
        }
    }
    return self;
}

-(void)setCategory:(NSString *)category{
    _category = category;
    if ([self.category isEqual:@"clear"]) {
        self.pointOutLabel.text = NSLocalizedString(@"Do you clear all files? It cannot be restored after emptying", @"是否确定清空所有文件？清空后将无法恢复");
        [self.delectCompleteBtn setTitle:NSLocalizedString(@"Confirm Clear", @"确认清空")  forState:UIControlStateNormal];
    }else if ([self.category isEqual:@"del"]) {
        self.pointOutLabel.text = NSLocalizedString(@"Are you sure you want to delete the selected files? It cannot be recovered after deletion", @"是否确定删除选中的文件？删除后将无法恢复");
        [self.delectCompleteBtn setTitle:NSLocalizedString(@"Confirm Delete", @"确认删除") forState:UIControlStateNormal];
    }else{
        self.pointOutLabel.text = NSLocalizedString(@"Are you sure you want to restore the selected files?", @"是否确定还原选中的文件？");
        [self.delectCompleteBtn setTitle:NSLocalizedString(@"Restore", @"还原") forState:UIControlStateNormal];
    }
}


@end
