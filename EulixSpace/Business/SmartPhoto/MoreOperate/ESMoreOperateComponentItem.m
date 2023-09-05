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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMoreOperateComponentItem.h"
#import "UIButton+ESStyle.h"

@interface ESMoreOperateComponentItem ()

@property (nonatomic, strong) UIButton *operateBt;
@property (nonatomic, copy) NSArray *selectedList;

@end

@implementation ESMoreOperateComponentItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
    if (self = [super init]) {
        _moreOperateVC = moreOperateVC;
    }
    return self;
}

- (UIButton *)operateBt {
    if (!_operateBt) {
        _operateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_operateBt.titleLabel setFont:ESFontPingFangMedium(10)];
        [_operateBt setTitleColor: ESColor.labelColor forState:UIControlStateNormal];
        [_operateBt setTitle:[self title]  forState:UIControlStateNormal];
        [_operateBt setImage:[UIImage imageNamed:[self iconName]] forState:UIControlStateNormal];
        [_operateBt addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _operateBt.frame = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
        [_operateBt setBottomTextTopImageStyleOffset:4.0f];

    }
    return _operateBt;
}

- (void)clickAction:(id)sender {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (NSString *)title {
    return @"title";
}

- (void)updateSelectedList:(NSArray *)selectedList {
    _selectedList = selectedList;
}

- (NSString *)iconName {
    return @"device_more_info";
}
- (UIView *)menuView {
    return self.operateBt;
}
- (CGSize)viewSize {
    return CGSizeMake(40, 58.0f);
}

@end
