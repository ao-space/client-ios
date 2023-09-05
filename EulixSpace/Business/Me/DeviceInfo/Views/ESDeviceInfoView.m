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
//  ESDeviceInfoView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESDeviceInfoView.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESTransferProgressView.h"
#import <Masonry/Masonry.h>
#import "ESDeviceBaseInfoView.h"
#import "ESDeviceStorageInfoView.h"

@interface ESDeviceInfoView ()

@end

@implementation ESDeviceInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self setupViews];
    return self;
}

- (void)setupViews {
   // [self addSubview:self.deviceBaseInfoView];
//    [self.deviceBaseInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.mas_equalTo(self);
//        make.height.mas_equalTo(170);
//    }];

   // [self addSubview:self.deviceStorageInfoView];
//    [self.deviceStorageInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.deviceBaseInfoView.mas_bottom);
//        make.height.mas_equalTo(110.0f);
//        make.left.right.mas_equalTo(self);
//    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    [self loadWithDeviceInfo:nil];
}

- (void)loadWithDeviceInfo:(ESDeviceInfoModel *)deviceInfo {
    [self.deviceBaseInfoView loadWithDeviceInfo:deviceInfo];
    [self.deviceStorageInfoView loadWithDeviceInfo:deviceInfo];
}

#pragma mark - Lazy Load

- (ESDeviceBaseInfoView *)deviceBaseInfoView {
    if (!_deviceBaseInfoView) {
        _deviceBaseInfoView = [[ESDeviceBaseInfoView alloc] init];
        _deviceBaseInfoView.backgroundColor = ESColor.tertiarySystemBackgroundColor;
        __weak typeof(self) weakSelf = self;
        _deviceBaseInfoView.moreInfoActionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            if (self.actionBlock) {
                self.actionBlock(nil);
            }
        };
    }
    return _deviceBaseInfoView;
}

- (ESDeviceStorageInfoView *)deviceStorageInfoView {
    if (!_deviceStorageInfoView) {
        _deviceStorageInfoView = [[ESDeviceStorageInfoView alloc] init];
        _deviceStorageInfoView.backgroundColor = [ESColor colorWithHex:0xF8FAFF];
    }
    return _deviceStorageInfoView;
}

@end
