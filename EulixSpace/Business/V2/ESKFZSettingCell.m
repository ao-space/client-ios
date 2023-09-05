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
//  ESKFZSettingCell.m
//  EulixSpace
//
//  Created by Ye Tao on 20212/1/09.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESKFZSettingCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import "ESCommonToolManager.h"
#import "UIColor+ESHEXTransform.h"
#import <Masonry/Masonry.h>

@interface ESKFZSettingCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *title1;

@property (nonatomic, strong) UILabel *pointOut;

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) UIView * line1;

@property (nonatomic, strong) UIView * line2;

@property (nonatomic, strong) UIImageView * errIcon;

@property (nonatomic, strong) UIButton * errorBtn;

@property (nonatomic, strong) UILabel * error;

@property (nonatomic, strong) UIImageView *popErrorView;

@end

@implementation ESKFZSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(21);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY);
        make.left.mas_equalTo(self.icon.mas_right).offset(6);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(120);
    }];
    
    [self.title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY);
        make.left.mas_equalTo(self.icon.mas_right).offset(167.0);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(120);
    }];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.left.mas_equalTo(self.title.mas_right).offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.height.mas_equalTo(30);
    }];
    
    [self.pointOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.left.mas_equalTo(self.title.mas_right).offset(10);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(8);
    }];
    
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(0);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.height.mas_equalTo(1);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(21);
        make.left.mas_equalTo(self.title.mas_right).offset(5);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(1);
    }];
    
    [self.errIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY);
        make.right.mas_equalTo(self.title.mas_right).offset(5);
        make.height.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY);
        make.right.mas_equalTo(self.title.mas_right).offset(5);
        make.height.mas_equalTo(44);

    }];
}

- (void)reloadWithData:(ESDeveloInfo *)model {
    self.model = model;
    self.title.text = model.title;
}

-(void)setModel:(ESDeveloInfo *)model{
    _model = model;
 
        if(model.type == 3){
            if(model.lastCell){
                self.content.hidden = YES;
                self.line1.hidden = YES;
                self.title.text = NSLocalizedString(@"insert_environment_variable", @"添加环境变量");
                _icon.image = [UIImage imageNamed:@"kfz_add"];
                self.title1.hidden = YES;
            }else{
                self.content.hidden = NO;
                self.title.text = NSLocalizedString(@"variable_name", @"变量名");
                self.title1.hidden = NO;
                _icon.image = [UIImage imageNamed:@"kfz_del"];
            }
        }else{
            if(model.lastCell){
                self.content.hidden = YES;
                self.title.text = NSLocalizedString(@"insert_storage_path", @"添加存储路径");
                _icon.image = [UIImage imageNamed:@"kfz_add"];
                self.title1.hidden = YES;
                self.line1.hidden = YES;
                self.line2.hidden = YES;
                self.pointOut.hidden = YES;
                
            }else{
                self.content.hidden = NO;
                self.title.text = NSLocalizedString(@"container_internal_path", @"容器内部路径");
                self.title1.hidden = NO;
                self.pointOut.hidden = NO;
                _icon.image = [UIImage imageNamed:@"kfz_del"];
                self.line1.hidden = NO;
                self.line2.hidden = NO;
            }
        }
   
    self.errIcon.hidden = YES;
    self.errorBtn.hidden = YES;
    
    if(model.isHaveError){
        self.errIcon.hidden = NO;
        self.errorBtn.hidden = NO;
        self.popErrorView.hidden = YES;
        if ([ESCommonToolManager isEnglish]) {
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.title.mas_top).offset(-15);
                make.left.mas_equalTo(self.title.mas_right).offset(-30);
                make.height.mas_equalTo(60);
                make.width.mas_equalTo(200);
            }];
            
            [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.title.mas_centerY);
                make.left.mas_equalTo(self.title.mas_right).offset(6);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
            }];
            
            [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.title.mas_centerY);
                make.left.mas_equalTo(self.contentView).offset(26);
                make.height.mas_equalTo(20);
                make.width.mas_equalTo(20);
            }];
            
            [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.right.mas_equalTo(self.popErrorView.mas_right).offset(-10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        } else{
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.title.mas_top).offset(-15);
                make.left.mas_equalTo(self.title.mas_right).offset(-30);
                make.height.mas_equalTo(30);
                make.width.mas_equalTo(200);
            }];
            
            [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.title.mas_centerY);
                make.left.mas_equalTo(self.title.mas_right).offset(6);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
            }];
            
            [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.title.mas_centerY);
                make.left.mas_equalTo(self.contentView).offset(26);
                make.height.mas_equalTo(20);
                make.width.mas_equalTo(20);
            }];
            
            [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }
     
        
    }else{
        self.popErrorView.hidden = YES;
    }
    
    if(model.lastCell){
        self.popErrorView.hidden = YES;
        self.errIcon.hidden = YES;
    }
    
    self.content.text = model.value;
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        
        _title.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap)];
        // 允许用户交互
        [_title addGestureRecognizer:tap];
        
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)title1 {
    if (!_title1) {
        _title1 = [[UILabel alloc] init];
        _title1.textColor = ESColor.secondaryLabelColor;
        _title1.textAlignment = NSTextAlignmentLeft;
        _title1.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title1];
    }
    return _title1;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"kfz_del"];
        _icon.layer.cornerRadius = 4.0;
        _icon.layer.masksToBounds = YES;
        [self.contentView addSubview:_icon];
        _icon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap)];
        // 允许用户交互
        [_icon addGestureRecognizer:tap];
    }
    return _icon;
}

- (UITextField *)content {
    if (!_content) {
        _content = [[UITextField alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.delegate = self;
        _content.textAlignment = NSTextAlignmentRight;
        _content.font = [UIFont systemFontOfSize:14];
        _content.placeholder = NSLocalizedString(@"please_re-enter", @"请输入");
        [self.contentView addSubview:_content];
    }
    return _content;
}


- (UILabel *)pointOut {
    if (!_pointOut) {
        _pointOut = [[UILabel alloc] init];
        _pointOut.textColor = [UIColor es_colorWithHexString:@"#85899C"];;
        _pointOut.textAlignment = NSTextAlignmentLeft;
        _pointOut.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        _pointOut.text = @"/";
        [self.contentView addSubview:_pointOut];
    }
    return _pointOut;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.actionBlock(textField.text);
}


- (UIView *)line1 {
    if (!_line1) {
        _line1 = [UIView new];
        _line1.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line1];
    }
    return _line1;
}

- (UIView *)line2 {
    if (!_line2) {
        _line2 = [UIView new];
        _line2.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line2];
    }
    return _line2;
}

- (UIImageView *)errIcon {
    if (!_errIcon) {
        _errIcon = [[UIImageView alloc] init];
        _errIcon.image = [UIImage imageNamed:@"error_check"];
        [self.contentView addSubview:_errIcon];
    }
    return _errIcon;
}


- (UIImageView *)popErrorView {
    if (!_popErrorView) {
        _popErrorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _popErrorView.image = [UIImage imageNamed:@"kfz_pop"];
        
        self.error = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 18)];
        self.error.numberOfLines = 0;
        self.error.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [_popErrorView addSubview: self.error];
        self.error.textColor = [UIColor es_colorWithHexString:@"#F6222D"];
        _popErrorView.backgroundColor = ESColor.systemBackgroundColor;
        [self.contentView addSubview:_popErrorView];
    }
    return _popErrorView;
}

- (UIButton *)errorBtn {
    if (nil == _errorBtn) {
        _errorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_errorBtn addTarget:self action:@selector(didClickErrorBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_errorBtn];
    }
    return _errorBtn;
}


-(void)didClickErrorBtn{
    self.popErrorView.hidden = NO;
    self.error.hidden = NO;
    self.popErrorView.hidden = NO;
    self.error.text = NSLocalizedString(@"storage_exception_settings_same", @"容器内部路径重复，请重新输入");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       self.error.hidden = YES;
       self.popErrorView.hidden = YES;
    });
}

-(void)arrowTap{
    self.actionDelBlock(@"1");
}

@end

