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
//      .m
//  EulixSpace
//
//  Created by qu on 2021/7/28.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESStartupHomepageVC.h"
#import "ESBoxManager.h"
#import "ESColor.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import <Masonry/Masonry.h>
@interface ESStartupHomepageVC ()

/// 启动页title
@property (nonatomic, strong) UIImageView *startupTitle;

/// 启动页logo
@property (nonatomic, strong) UIImageView *startupLogo;

@end

@implementation ESStartupHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self.startupTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).inset(236 + 44 + kStatusBarHeight);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(204.0f);
        make.height.mas_equalTo(56.0f);
    }];
    [self.startupLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(16 + kBottomHeight);
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(104.0f);
        make.height.mas_equalTo(38.0f);
    }];
    dispatch_time_t time_w = dispatch_walltime(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(time_w, dispatch_get_main_queue(), ^{
        [self controlSelect];
    });
}

- (UIImageView *)startupTitle {
    if (nil == _startupTitle) {
        _startupTitle = [[UIImageView alloc] init];
        _startupTitle.image = IMAGE_STARTUP_TITLE;
        [self.view addSubview:_startupTitle];
    }
    return _startupTitle;
}

- (UIImageView *)startupLogo {
    if (nil == _startupLogo) {
        _startupLogo = [[UIImageView alloc] init];
        _startupLogo.image = IMAGE_STARTUP_LOGO;
        [self.view addSubview:_startupLogo];
    }
    return _startupLogo;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self controlSelect];
}

- (void)controlSelect {
}

@end
