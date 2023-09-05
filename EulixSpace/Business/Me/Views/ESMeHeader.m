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
//  ESMeHeader.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMeHeader.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "ESBoxManager.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>

@interface ESMeHeader ()

@property (nonatomic, strong) UIImageView *bg;

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UIImageView *linkIcon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *domin;

@property (nonatomic, strong) UIButton *linkIconBtn;


@end

@implementation ESMeHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {

    [self.bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.top.mas_equalTo(self.mas_top).offset(0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
    }];
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).inset(26);
        make.top.mas_equalTo(self).offset(25 + 64);
        make.width.height.mas_equalTo(50);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(20);
        make.top.mas_equalTo(self).offset(25 + 64);
        make.right.mas_equalTo(self.mas_right).offset(-26);
        make.height.mas_equalTo(25);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(20);
        make.top.mas_equalTo(self.title.mas_bottom).inset(4);
        make.right.mas_equalTo(self.mas_right).offset(-26);
        make.height.mas_equalTo(25);
    }];
    
    [self.domin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(20);
        make.top.mas_equalTo(self.content.mas_bottom).offset(2);
        make.height.mas_equalTo(25);

    }];

    [self.linkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.domin.mas_right).offset(6);
        make.centerY.mas_equalTo(self.domin.mas_centerY);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    
    [self.linkIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.linkIcon.mas_centerX);
        make.centerY.mas_equalTo(self.linkIcon.mas_centerY);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(44);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.title.text = model.title;
    self.content.text = model.content;
//    if (self.content.text.length == 0) {
//        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(25 * 2 + 4);
//        }];
//    } else {
//        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(25);
//        }];
//    }
    if(self.content.text.length < 1){
        self.content.hidden = YES;
        [self.domin mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatar.mas_right).offset(20);
            make.top.mas_equalTo(self).offset(25 + 64 + 25 + 5);
            make.height.mas_equalTo(25);
        }];
    }else{
        self.content.hidden = NO;
        
        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatar.mas_right).offset(20);
            make.top.mas_equalTo(self).offset(25 + 64);
            make.right.mas_equalTo(self.mas_right).offset(-26);
            make.height.mas_equalTo(25);
        }];
        
        [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatar.mas_right).offset(20);
            make.top.mas_equalTo(self.title.mas_bottom).offset(4);
            make.right.mas_equalTo(self.mas_right).offset(-26);
            make.height.mas_equalTo(25);
        }];
        [self.domin mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatar.mas_right).offset(20);
            make.right.mas_equalTo(self.mas_right).offset(-26);
            make.top.mas_equalTo(self).offset(25 + 64 + 55);
            make.height.mas_equalTo(25);
        }];
        [self layoutIfNeeded];
    }
    if (model.avatar.length == 0) {
        self.avatar.image = IMAGE_ME_AVATAR_DEFAULT;
    } else {
        self.avatar.image = [UIImage imageWithContentsOfFile:model.avatar];
    }
    if ( ESBoxManager.activeBox.enableInternetAccess == NO && ESBoxManager.activeBox.localHost.length > 0) {
        self.domin.text = @"";
        self.linkIcon.hidden = YES;
        self.linkIconBtn.hidden = YES;
    } else {
        self.domin.text = ESBoxManager.activeBox.info.userDomain;
        if(![self.domin.text containsString:@"https"]){
            self.domin.text = [NSString stringWithFormat:@"https://%@",self.domin.text];
        }
        self.linkIcon.hidden = NO;
        self.linkIconBtn.hidden = NO;
    }
}

#pragma mark - Lazy Load



- (UIImageView *)bg {
    if (!_bg) {
        _bg = [UIImageView new];
        _bg.contentMode = UIViewContentModeScaleAspectFill;
        _bg.layer.masksToBounds = YES;
        _bg.image = [UIImage imageNamed:@"bg"];
        [self addSubview:_bg];
    }
    return _bg;
}


- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
        [self addSubview:_avatar];
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 25;
        _avatar.image = IMAGE_ME_AVATAR_DEFAULT;
    }
    return _avatar;
}



- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [self addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        [self addSubview:_content];
    }
    return _content;
}

- (UILabel *)domin {
    if (!_domin) {
        _domin = [[UILabel alloc] init];
        _domin.textColor = ESColor.secondaryLabelColor;
        _domin.textAlignment = NSTextAlignmentLeft;
        _domin.font = [UIFont systemFontOfSize:14];
        [self addSubview:_domin];
    }
    return _domin;
}


- (UIImageView *)linkIcon {
    if (!_linkIcon) {
        _linkIcon = [[UIImageView alloc] init];
        _linkIcon.image = [UIImage imageNamed:@"copy"];
        [self addSubview:_linkIcon];
    }
    return _linkIcon;
}

- (UIButton *)linkIconBtn {
    if (!_linkIconBtn) {
        _linkIconBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_linkIconBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        _linkIconBtn.backgroundColor = ESColor.clearColor;
        [_linkIconBtn addTarget:self action:@selector(refuseAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_linkIconBtn];
    }
    return _linkIconBtn;
}

-(void)refuseAction{
    UIPasteboard.generalPasteboard.string = self.domin.text;
    [ESToast toastSuccess:TEXT_ME_WEB_COPY];
}

@end
