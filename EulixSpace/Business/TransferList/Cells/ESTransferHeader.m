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
//  ESTransferHeader.m
//  ESTransferHeader
//
//  Created by Ye Tao on 2021/8/16.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESTransferHeader.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESTransferListDefine.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ESTransferHeader ()

@property (nonatomic, strong) UIButton *icon;

@property (nonatomic, strong) UIButton *title;

@property (nonatomic, strong) UIButton *button;

@end

@implementation ESTransferHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
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
        make.width.mas_equalTo(56 + 12 * 2);
    }];
    
    [self.allButtonPaues mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(kESViewDefaultMargin - 12);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(56 + 12 * 2);
    }];
    
    [self.allDownButtonPaues mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).inset(kESViewDefaultMargin - 12);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(56 + 12 * 2);
    }];
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

- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
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



- (UIButton *)allDownButtonPaues {
    if (!_allDownButtonPaues) {
        _allDownButtonPaues = [UIButton buttonWithType:UIButtonTypeCustom];
        _allDownButtonPaues.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allDownButtonPaues setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        NSString *isPause = [[NSUserDefaults standardUserDefaults] objectForKey:@"isdownPause"];
        if(_allDownButtonPaues.titleLabel.text.length < 1){
            if ([isPause isEqual:@"YES"]) {
                [_allDownButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
           }else{
               [_allDownButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
           }
        }else{
            if ([isPause isEqual:@"YES"]) {
                [_allDownButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
            }else{
                [_allDownButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
            }
        }
    
        [_allDownButtonPaues addTarget:self action:@selector(allDownAction:) forControlEvents:UIControlEventTouchUpInside];
        _allDownButtonPaues.hidden = YES;
        [self addSubview:_allDownButtonPaues];
    }
    return _allDownButtonPaues;
}


//selected 全部暂停
-(void)allDownAction:(UIButton *)btn {
    [SVProgressHUD show];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD showWithStatus:@"全部暂停/全部继续中"];
  
    self.allDownButtonPaues.userInteractionEnabled = NO;

    if ([self.allDownButtonPaues.titleLabel.text isEqual:NSLocalizedString(@"transfer_resume_all", @"全部继续")]) {
        [self.allDownButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downingAllStartBtnNotification" object:@(0)];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isDownPause"];
    }else{
        // 全部继续
        [self.allDownButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downingAllStartBtnNotification" object:@(1)];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isDownPause"];
    }
  
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.allDownButtonPaues.userInteractionEnabled = YES;
    });
}

-(void)allAction:(UIButton *)btn {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD showWithStatus:@"全部暂停/全部继续中"];
    self.allButtonPaues.userInteractionEnabled = NO;

    if ([self.allButtonPaues.titleLabel.text isEqual:NSLocalizedString(@"transfer_resume_all", @"全部继续")]) {
        [self.allButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadingAllStartBtnNotification" object:@(0)];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isPause"];
    }else{
        // 全部继续
        [self.allButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadingAllStartBtnNotification" object:@(1)];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isPause"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.allButtonPaues.userInteractionEnabled = YES;
    });
}

- (UIButton *)allButtonPaues {
    if (!_allButtonPaues) {
        _allButtonPaues = [UIButton buttonWithType:UIButtonTypeCustom];
        _allButtonPaues.titleLabel.font = [UIFont systemFontOfSize:14];
        [_allButtonPaues setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        NSString *isPause = [[NSUserDefaults standardUserDefaults] objectForKey:@"isPause"];
        if(_allButtonPaues.titleLabel.text.length < 1){
            if ([isPause isEqual:@"YES"]) {
                [_allButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
           }else{
               [_allButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
           }
        }else{
            if ([isPause isEqual:@"YES"]) {
                [_allButtonPaues setTitle:NSLocalizedString(@"transfer_resume_all", @"全部继续") forState:UIControlStateNormal];
            }else{
                [_allButtonPaues setTitle:NSLocalizedString(@"transfer_pause_all", @"全部暂停") forState:UIControlStateNormal];
            }
        }
    
        [_allButtonPaues addTarget:self action:@selector(allAction:) forControlEvents:UIControlEventTouchUpInside];
        _allButtonPaues.hidden = YES;
        [self addSubview:_allButtonPaues];
    }
    return _allButtonPaues;
}

@end
