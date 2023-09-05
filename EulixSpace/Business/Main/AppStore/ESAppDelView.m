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
//  ESAppDelView.m
//  EulixSpace
//
//  Created by qu on 2023/2/22.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAppDelView.h"
#import "SDWebImageManager.h"
#import "ESToast.h"
#import "UIImageView+WebCache.h"

@interface ESAppDelView()
    


@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UIImageView *headImageView1;


@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *title2;


@property (nonatomic, strong) UIButton *compleBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIView *line;


@property (nonatomic, strong) UIView *line2;

@end

@implementation ESAppDelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsUpdateConstraints];
    }
    return self;
}


- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.numberOfLines = 0;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [self.programView addSubview:_title];
    }
    return _title;
}

- (UILabel *)title2 {
    if (!_title2) {
        _title2 = [[UILabel alloc] init];
        _title2.textColor = ESColor.labelColor;
        _title2.numberOfLines = 0;
        _title2.textAlignment = NSTextAlignmentCenter;
        _title2.font = [UIFont systemFontOfSize:14 weight:(UIFontWeightRegular)];
        [self.programView addSubview:_title2];
    }
    return _title2;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.backgroundColor = ESColor.iconBg;
        _iconImageView.layer.cornerRadius = 10.0;
        _iconImageView.layer.masksToBounds = YES;
        [self.programView addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [UIImageView new];
        _headImageView.image = [UIImage imageNamed:@"app_docker"];
        [self.iconImageView addSubview:_headImageView];
      
    }
    return _headImageView;
}

- (UIImageView *)headImageView1 {
    if (!_headImageView1) {
        _headImageView1 = [UIImageView new];
        _headImageView1.image = [UIImage imageNamed:@"app_xiezai"];
        [self.programView addSubview:_headImageView1];
    }
    return _headImageView1;
}


- (UIButton *)compleBtn {
    if (nil == _compleBtn) {
        _compleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _compleBtn.backgroundColor = [UIColor clearColor];
        [_compleBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_compleBtn addTarget:self action:@selector(didClickCompleBtn) forControlEvents:UIControlEventTouchUpInside];
        [_compleBtn setTitle:NSLocalizedString(@"uninstall_applet", @"卸载") forState:UIControlStateNormal];
//        _compleBtn.backgroundColor = [ESColor secondarySystemBackgroundColor];
        [self.programView addSubview:_compleBtn];
    }
    return _compleBtn;
}

- (UIButton *)cancelBtn {
    if (nil == _cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        _cancelBtn.backgroundColor = [UIColor clearColor];
//        _cancelBtn.backgroundColor = [ESColor secondarySystemBackgroundColor];
        [self.programView addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

-(void)didClickCancelBtn{
    [ESToast dismiss];
    self.hidden = YES;
}

-(void)didClickCompleBtn{
    self.hidden = YES;
    self.actionDel(@"1");
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(324.0f);
        make.width.mas_equalTo(270.0f);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(50);
        make.centerX.mas_equalTo(self.programView.mas_centerX);
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(60.0f);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_top);
        make.centerX.mas_equalTo(self.iconImageView.mas_centerX);
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(60.0f);
    }];
    
    [self.headImageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_top).offset(40);
        make.left.mas_equalTo(self.iconImageView.mas_left).offset(40);
        make.width.mas_equalTo(20.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(30);
//        make.centerX.mas_equalTo(self.programView.mas_centerX);
        make.right.mas_equalTo(self.programView.mas_right).offset(-30);
        make.left.mas_equalTo(self.programView.mas_left).offset(30);
    }];
    
    [self.title2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).offset(16);
        make.right.mas_equalTo(self.programView.mas_right).offset(-30);
        make.left.mas_equalTo(self.programView.mas_left).offset(30);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title2.mas_bottom).offset(39);
        make.centerX.mas_equalTo(self.programView.mas_centerX);
        make.width.mas_equalTo(1.0f);
        make.height.mas_equalTo(43.0f);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title2.mas_bottom).offset(39);
        make.left.mas_equalTo(self.programView.mas_left);
        make.width.mas_equalTo(270.0f);
        make.height.mas_equalTo(1.0f);
    }];
    
    [self.compleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-10);
        make.right.mas_equalTo(self.programView.mas_right);
        make.width.mas_equalTo(134.0f);
        make.height.mas_equalTo(46.0f);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-10);
        make.left.mas_equalTo(self.programView.mas_left);
        make.width.mas_equalTo(134.0f);
        make.height.mas_equalTo(46.0f);
    }];
    
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line];
    }
    return _line;
}


- (UIView *)line2 {
    if (!_line2) {
        _line2 = [UIView new];
        _line2.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line2];
    }
    return _line2;
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] init];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        _programView.layer.cornerRadius = 10.0;
        _programView.layer.masksToBounds = YES;
        [self addSubview:_programView];
    }
    return _programView;
}


-(void)setItem:(ESFormItem *)item{
    _item = item;
    self.title.text = [NSString stringWithFormat:NSLocalizedString(@"applet_uninstall_dialog_title", @"是否卸载%@？"),item.title];
    if(item.uninstallType.intValue == 0){
        self.title2.text = [NSString stringWithFormat:NSLocalizedString(@"applet_uninstall_dialog_des", @"卸载“%@”，其数据不会被清除"),item.title];
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.iconUrl]];
        UIImage* resultImage = [UIImage imageWithData: imageData];
        self.headImageView.image = resultImage;
    }else if(item.uninstallType.intValue == 1){
        self.title2.text = [NSString stringWithFormat:NSLocalizedString(@"applet_uninstall_content_keep_data_only", @"卸载“%@”，将删除其所有应用程序，但数据不会被清除"),item.title];
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.iconUrl]];
        UIImage* resultImage = [UIImage imageWithData: imageData];
        self.headImageView.image = resultImage;

    }else if(item.uninstallType.intValue == 2){
        self.title2.text = [NSString stringWithFormat:NSLocalizedString(@"applet_uninstall_dialog_des", @"卸载“%@”，其数据不会被清除"),item.title];
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.iconUrl]];
        UIImage* resultImage = [UIImage imageWithData: imageData];
        self.headImageView.image = resultImage;
    }else{
        self.title2.text = [NSString stringWithFormat:NSLocalizedString(@"applet_uninstall_dialog_des", @"卸载“%@”，其数据不会被清除"),item.title];
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.iconUrl]];
        UIImage* resultImage = [UIImage imageWithData: imageData];
        self.headImageView.image = resultImage;
    }
    
    if(!self.headImageView.image){
        self.headImageView.image = [UIImage imageNamed:@"app_docker"];
    }
    

}

@end
