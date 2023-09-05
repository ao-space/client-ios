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
//  ESTransferUploadHeader.m
//  EulixSpace
//
//  Created by dazhou on 2022/8/11.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTransferUploadHeader.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESTransferListDefine.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ESTransferManager.h"

@interface ESTransferUploadHeader ()

@property (nonatomic, strong) UIButton *icon;

@property (nonatomic, strong) UIButton *title;

@property (nonatomic, strong) UIButton *button;

@end

@implementation ESTransferUploadHeader


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)reloadWithData:(ESFormItem *)model {
    [self.title setTitle:model.title forState:UIControlStateNormal];
    [self.button setTitle:model.content forState:UIControlStateNormal];
    self.button.tag = model.type;
    self.title.selected = model.selected;
    if (self.title.selected) {
        self.icon.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.icon.transform = CGAffineTransformIdentity;
    }
}

- (void)setButtonAction:(ESTransferHeaderAction)type {
    if (type == ESTransferHeaderActionResume || type == ESTransferHeaderActionPause) {
        self.allButtonPaues.tag = type;

        NSString * title;
        if (type == ESTransferHeaderActionPause) {
            title = NSLocalizedString(@"transfer_resume_all", @"全部继续");
        } else if (type == ESTransferHeaderActionResume) {
            title = NSLocalizedString(@"transfer_pause_all", @"全部暂停");
        }
        [self.allButtonPaues setTitle:title forState:UIControlStateNormal];
    }
}

- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

-(void)allAction:(UIButton *)btn {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
//    [SVProgressHUD showWithStatus:@"全部暂停/全部继续中"];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"waiting_operate", nil)];
    self.allButtonPaues.userInteractionEnabled = NO;

    
    if (btn.tag == ESTransferHeaderActionPause) {
        btn.tag = ESTransferHeaderActionResume;
        
        [self.allButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];

        [[ESTransferManager manager] resumeAllUploadTask];

    } else if (btn.tag == ESTransferHeaderActionResume) {
        btn.tag = ESTransferHeaderActionPause;
        
        [self.allButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];

        [[ESTransferManager manager] suspendAllUploadTask];

    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.allButtonPaues.userInteractionEnabled = YES;
    });
}


- (void)titleAction {
    self.title.selected = !self.title.selected;
    self.title.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
        delay:0
        options:(UIViewAnimationOptionCurveEaseInOut)animations:^{
            if (self.title.selected) {
                self.icon.transform = CGAffineTransformMakeRotation(M_PI);
            } else {
                self.icon.transform = CGAffineTransformIdentity;
            }
        }
        completion:^(BOOL finished) {
            self.title.userInteractionEnabled = YES;
        }];

    if (self.actionBlock) {
        self.actionBlock(@(self.title.selected ? ESTransferHeaderActionShrink : ESTransferHeaderActionExpand));
    }
}


- (void)initUI {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.title.mas_right).offset(1);
        make.width.mas_equalTo(8);
        make.top.bottom.mas_equalTo(self);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(kESViewDefaultMargin);
        make.top.bottom.mas_equalTo(self);
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(kESViewDefaultMargin - 12);
        make.top.bottom.mas_equalTo(self);
//        make.width.mas_equalTo(56 + 12 * 2);
    }];
    
    [self.allButtonPaues mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(kESViewDefaultMargin - 12);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(56 + 12 * 2);
    }];
}

#pragma mark - Lazy Load
- (UIButton *)icon {
    if (!_icon) {
        _icon = [UIButton new];
        [_icon setImage:IMAGE_FILE_HEADER_EXPAND forState:UIControlStateNormal];
        [_icon addTarget:self action:@selector(titleAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_icon];
    }
    return _icon;
}

- (UIButton *)title {
    if (!_title) {
        _title = [UIButton buttonWithType:UIButtonTypeCustom];
        _title.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [_title setTitleColor:ESColor.secondaryLabelColor forState:UIControlStateNormal];
        [_title addTarget:self action:@selector(titleAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_title];
    }
    return _title;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.selected = YES;
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return _button;
}

- (UIButton *)allButtonPaues {
    if (!_allButtonPaues) {
        _allButtonPaues = [UIButton buttonWithType:UIButtonTypeCustom];
        _allButtonPaues.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allButtonPaues setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];    
        [_allButtonPaues addTarget:self action:@selector(allAction:) forControlEvents:UIControlEventTouchUpInside];
        _allButtonPaues.hidden = YES;
        [self addSubview:_allButtonPaues];
    }
    return _allButtonPaues;
}

@end
