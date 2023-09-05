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
//  ESMeSettingCell2.m
//  EulixSpace
//
//  Created by qu on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMeSettingCell2.h"
#import "ESCommonToolManager.h"

@interface ESMeSettingCell2()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView * errIcon;

@property (nonatomic, strong) UIButton * errorBtn;

@property (nonatomic, strong) UILabel * error;

@property (nonatomic, strong) UIImageView * popErrorView;


@end

@implementation ESMeSettingCell2

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setInfo:(ESDeveloInfo *)Info {
    _Info = Info;
    self.mTitleLabel.text = Info.title;
    self.arrowIv.hidden = !Info.hasArrow;
    self.lineView.hidden = Info.lastCell;
    self.mContentLabel.text = Info.value;
    if(Info.isSelected){
        self.sedArrow.hidden = NO;
    }else{
        self.sedArrow.hidden = YES;
    }
    
    if(Info.type == 2){
        self.lineView.hidden = YES;
        self.mTitleLabel.hidden = NO;
        self.mContentLabel.textColor = ESColor.labelColor;
    }
}

- (void)setModel:(ESCellMoelKFZ *)model {
    _model = model;
    self.mTitleLabel.text = model.title;
    self.arrowIv.hidden = !model.hasArrow;
    self.lineView.hidden = model.lastCell;
    
    self.mContentLabel.text = nil;
    self.mTextField.placeholder = nil;
    
    if (model.valueType == ESCellModelValueType_Label) {
        self.mTextField.hidden = YES;
        if (model.value) {
            self.mContentLabel.text = model.value;
            self.mContentLabel.textColor = model.valueColor;
        } else if (model.placeholderValue) {
            self.mContentLabel.text = model.placeholderValue;
            self.mContentLabel.textColor = model.placeholderValueColor;
        }
    } else if (model.valueType == ESCellModelValueType_TextField) {
        self.mTextField.hidden = NO;
        self.mTextField.text = model.value;
        self.mTextField.secureTextEntry = model.isCipher;
        if (model.attributedPlaceholder) {
            self.mTextField.attributedPlaceholder = model.attributedPlaceholder;
        } else if (model.placeholderValue) {
            self.mTextField.placeholder = model.placeholderValue;
        }
        self.mTextField.textColor = model.valueColor;
    }
    
    if(model.isSelected){
        self.sedArrow.hidden = NO;
    }else{
        self.sedArrow.hidden = YES;
    }
    
 
    if(model.type == 1001){
        if(model.error1 > 0 && model.error2 > 0){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = [NSString stringWithFormat:@"%@;\n%@",NSLocalizedString(@"service_name_exception_duplicate", @"服务名称重复，请重新输入"),NSLocalizedString(@"service_name_exception_illegal", @"服务名称不合法，请重新输入")];
        }else if(model.error1 > 0){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = NSLocalizedString(@"service_name_exception_duplicate", @"服务名称重复，请重新输入");
        }else if(model.error2 > 0){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = NSLocalizedString(@"service_name_exception_illegal", @"服务名称不合法，请重新输入");

        }else{
            self.errorBtn.hidden = YES;
            self.errIcon.hidden = YES;
        }
    }else if(model.type == 1002){
        if(model.error1 > 0 && model.error2 > 0){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = [NSString stringWithFormat:@"%@;\n%@",NSLocalizedString(@"domain_name_prefix_exception_duplicate", @"域名前缀重复，请重新输入"),NSLocalizedString(@"domain_name_prefix_exception_illegal", @"域名前缀不合法，请重新输入")];
            
        }else if(model.error1 > 0 ){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = NSLocalizedString(@"domain_name_prefix_exception_duplicate", @"域名前缀重复，请重新输入");
        }else if(model.error2 == 80014){
            self.errorBtn.hidden = NO;
            self.errIcon.hidden = NO;
            self.popErrorView.hidden = YES;
            self.error.text = NSLocalizedString(@"domain_name_prefix_exception_illegal", @"域名前缀不合法，请重新输入");
        }else{
            self.errorBtn.hidden = YES;
            self.popErrorView.hidden = YES;
            self.errIcon.hidden = YES;
        }
    }else{
        self.errorBtn.hidden = YES;
        self.errIcon.hidden = YES;
    }
    if (model.type == 1003) {
        self.mContentLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void)setTitleColor:(UIColor *)color {
    self.mTitleLabel.textColor = color;
}

- (void)initViews {
    UILabel * label = [[UILabel alloc] init];
    label.font = ESFontPingFangRegular(16);
    label.textColor = [UIColor es_colorWithHexString:@"#333333"];
    [self.contentView addSubview:label];
    self.mTitleLabel = label;
    
    label = [[UILabel alloc] init];

    label.font = ESFontPingFangRegular(16);
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 2;
    label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    [self.contentView addSubview:label];
    self.mContentLabel = label;
    
    UIImageView * imageview = [[UIImageView alloc] init];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageview];
    self.arrowIv = imageview;
    
    self.arrowIv.image = [UIImage imageNamed:@"me_arrow"];
    
    UIImageView * sedArrow = [[UIImageView alloc] init];
    sedArrow.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:sedArrow];
    self.sedArrow = sedArrow;

    self.sedArrow.image = [UIImage imageNamed:@"v2_xuanze"];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.contentView addSubview:lineView];
    self.lineView = lineView;
    [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26);
        make.top.mas_equalTo(self.contentView).offset(19);
        make.bottom.mas_equalTo(self.contentView).offset(-19);
        make.width.mas_equalTo(200);
    }];
    
    [self.errIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mTitleLabel.mas_right).offset(5);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.mTitleLabel.mas_centerY);
    }];
    
    [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mTitleLabel.mas_right).offset(8);
        make.width.height.mas_equalTo(44);
        make.top.mas_equalTo(self.contentView).offset(15);
    }];
    
    [self.arrowIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.sedArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.mContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.mTitleLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.arrowIv.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
      
    }];
    
    [self.mTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.mTitleLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.arrowIv.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26);
        make.right.mas_equalTo(self.contentView).offset(-26);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFieldDidChangeValue:(NSNotification *)notification {
    UITextField * tf = notification.object;
    self.model.inputValue = tf.text;
}

- (UITextField *)mTextField {
    if (!_mTextField) {
        UITextField * tf = [[UITextField alloc] init];
        tf.delegate = self;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.textAlignment = NSTextAlignmentRight;
        tf.secureTextEntry = YES;
        tf.enabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeValue:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:tf];
        [self.contentView addSubview:tf];
        _mTextField = tf;
    }
    return _mTextField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


- (UIImageView *)errIcon {
    if (!_errIcon) {
        _errIcon = [[UIImageView alloc] init];
        _errIcon.image = [UIImage imageNamed:@"error_check"];
        [self.contentView addSubview:_errIcon];
    }
    return _errIcon;
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

    self.error.hidden = NO;
    self.popErrorView.hidden = NO;
    if ([ESCommonToolManager isEnglish]) {
        if(self.model.error1> 0 && self.model.error2> 0){
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(170);
                make.height.offset(80);
            }];
            
            [self.error mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.right.mas_equalTo(self.popErrorView.mas_right).offset(-10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(8);
                make.width.offset(180);
            }];
        }else if(self.model.error1 > 0  || self.model.error2 > 0 ){
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(179);
                make.height.offset(50);
            }];
            
            [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.right.mas_equalTo(self.popErrorView.mas_right).offset(-10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(10);
                make.width.offset(180);
            }];
        }
    }else{
        if(self.model.error1> 0 && self.model.error2> 0){
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(5);
                make.left.mas_equalTo(self.errIcon.mas_left).offset(-10);
                make.width.offset(170);
                make.height.offset(50);
            }];
            
            [self.error mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(8);
                make.width.offset(180);
            }];
        }else if(self.model.error1 > 0  || self.model.error2 > 0 ){
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(5);
                make.left.mas_equalTo(self.errIcon.mas_left).offset(-10);
                make.width.offset(179);
                make.height.offset(30);
            }];
            
            [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(10);
                make.width.offset(180);
            }];
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.error.hidden = YES;
        self.popErrorView.hidden = YES;
    });
  
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
@end
