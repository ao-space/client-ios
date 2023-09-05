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
//  ESMeSettingCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESMeSettingCell.h"

@interface ESMeSettingCell()<UITextFieldDelegate>

@end

@implementation ESMeSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setModel:(ESCellModel *)model {
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
    label.adjustsFontSizeToFitWidth = YES;
    label.font = ESFontPingFangRegular(16);
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    [self.contentView addSubview:label];
    self.mContentLabel = label;
    
    UIImageView * imageview = [[UIImageView alloc] init];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageview];
    self.arrowIv = imageview;
    self.arrowIv.image = [UIImage imageNamed:@"me_arrow"];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.contentView addSubview:lineView];
    self.lineView = lineView;
    
    [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26);
        make.top.mas_equalTo(self.contentView).offset(19);
        make.bottom.mas_equalTo(self.contentView).offset(-19);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    [self.arrowIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
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
//        make.width.mas_equalTo(150);
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
        tf.font = ESFontPingFangRegular(16);
        tf.delegate = self;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.textAlignment = NSTextAlignmentRight;
        tf.minimumFontSize = 0.5;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}


@end
