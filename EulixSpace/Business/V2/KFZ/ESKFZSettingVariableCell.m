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

#import "ESKFZSettingVariableCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"
#import "ESCommonToolManager.h"

@interface ESKFZSettingVariableCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *title;

//@property (nonatomic, strong) UILabel *title1;
//
//@property (nonatomic, strong) UILabel *title2;


@property (nonatomic, strong) UITextField *content;

@property (nonatomic, strong) UITextField *contentName;

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) UITextView *textInput;

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) UIView *line1;

@property (nonatomic, strong) UIView *line2;

@property (nonatomic, strong) UIImageView *popErrorView;


@property (nonatomic, strong) UIImageView * errIcon;

@property (nonatomic, strong) UIButton * errorBtn;

@property (nonatomic, strong) UILabel * error;

@property (nonatomic, assign) BOOL isError1;


@end

@implementation ESKFZSettingVariableCell

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
        make.right.mas_equalTo(self.contentView).offset(-26);
        make.left.mas_equalTo(self.icon.mas_right).offset(6);
        make.height.mas_equalTo(22);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.left.mas_equalTo(self.icon.mas_right).offset(2);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(100);
    }];
    
    [self.contentName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-26);
        make.left.mas_equalTo(self.content.mas_right).offset(6);
        make.height.mas_equalTo(30);
    }];
//    self.line1.backgroundColor = [UIColor redColor];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(-1);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.right.mas_equalTo(self.mas_right).offset(-26);
        make.height.mas_equalTo(1.0f);
    }];
//    self.line2.backgroundColor = [UIColor greenColor];
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.left.mas_equalTo(self.content.mas_right).offset(0);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(30.0f);
    }];

    [self.errIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-26-16-2);
        make.height.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-26-16-2);
        make.height.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    
    self.errIcon.hidden = YES;
    self.popErrorView.hidden = YES;
    self.error.hidden = YES;
    self.errorBtn.hidden = YES;
    
}

- (void)reloadWithData:(ESDeveloInfo *)model {
    self.model = model;
    self.title.text = model.title;
}

-(void)setModel:(ESDeveloInfo *)model{
    _model = model;
    self.contentName.hidden = NO;
    if(model.lastCell){
        self.content.hidden = YES;
        self.title.hidden = NO;
        self.title.text = NSLocalizedString(@"insert_environment_variable", @"添加环境变量");
        self.contentName.hidden = YES;
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        _icon.image = [UIImage imageNamed:@"kfz_add"];
       // self.title1.hidden = YES;
    }else{
//        self.title.text = model.title;
//        self.content.text = model.value;
        self.content.hidden = NO;
        self.title.hidden = YES;
      
        self.line1.hidden = NO;
        self.line2.hidden = NO;
        _icon.image = [UIImage imageNamed:@"kfz_del"];
    }
    
    if(model.errorArray.count > 0 ){
        self.errIcon.hidden = NO;
        self.errorBtn.hidden = NO;
        
    }else{
        self.errIcon.hidden = YES;
        self.popErrorView.hidden = YES;
        self.error.hidden = YES;
    }
    if(model.lastCell){
        self.errIcon.hidden = YES;
        self.errorBtn.hidden = YES;
    }

    self.content.text = model.dicParameter.allKeys[0];
    self.contentName.text = model.dicParameter.allValues[0];

    if([self.content.text isEqual:@"nil"]){
        self.content.text = @"";
    }
    
    NSString *error1 = self.model.dicParameter.allKeys[0];

    if([error1 isEqual:@"nil"] && !model.lastCell){
        self.isError1 = YES;
        self.errIcon.hidden = NO;
        self.errorBtn.hidden = NO;
    }else if(model.errorArray.count < 1){
        self.isError1 = NO;
        self.errIcon.hidden = YES;
        self.errorBtn.hidden = YES;
    }
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"kfz_del"];
        _icon.layer.cornerRadius = 4.0;
        _icon.layer.masksToBounds = YES;
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UITextField *)content {
    if (!_content) {
        _content = [[UITextField alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:14];
        _content.placeholder = NSLocalizedString(@"variable_name", @"变量名");
        _content.delegate = self;
        _content.tag = 1;
        [self.contentView addSubview:_content];
    }
    return _content;
}


- (UITextField *)contentName {
    if (!_contentName) {
        _contentName = [[UITextField alloc] init];
        _contentName.textColor = ESColor.labelColor;
        _contentName.tag = 2;
        _contentName.textAlignment = NSTextAlignmentLeft;
        _contentName.font = [UIFont systemFontOfSize:14];
        _contentName.placeholder = NSLocalizedString(@"variable_value", @"变量值");
        _contentName.delegate = self;
        [self.contentView addSubview:_contentName];
    }
    return _contentName;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.errIcon.hidden = YES;
    self.errorBtn.hidden = YES;
    self.popErrorView.hidden = YES;
    if(self.model.lastCell){
        return;
    }
    if(textField.tag == 1){
        if(textField.text.length > 0){
            NSMutableDictionary *dic =[NSMutableDictionary new];
            NSString *value = self.model.dicParameter.allValues[0];
            if(value.length > 0){
                [dic setValue:self.model.dicParameter.allValues[0] forKey:textField.text];
            }else{
                [dic setValue:@"" forKey:textField.text];
            }
            self.actionBlock(dic);
        }
    }else{
        NSMutableDictionary *dic =[NSMutableDictionary new];
        NSString *key = self.model.dicParameter.allKeys[0];
        if(key.length > 0){
            [dic setValue:textField.text forKey:self.model.dicParameter.allKeys[0]];
            self.actionBlock(dic);
        }else{
            NSString *key = @"nil";
            [dic setValue:textField.text forKey:key];
            self.actionBlock(dic);
        }
    }
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

- (void)textViewDidEndEditing:(UITextView *)textView{
 
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
  
    if (self.model.errorArray.count > 0 && self.isError1) {
        NSString *str1 = NSLocalizedString(@"environment_exception_settings_same", @"变量名重复，请重新输入");
        NSString *str2 = NSLocalizedString(@"environment_exception_variable_key_empty", @"变量名不能为空，请重新输入");
        self.error.text = [NSString stringWithFormat:@"%@\n%@",str1,str2];

        [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(0);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
            make.width.offset(200);
            make.height.offset(50);
        }];
        
        
       
        [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.popErrorView.mas_left).offset(15);
            make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
        }];
        
    }else if(self.model.errorArray.count > 0){
        self.error.text = NSLocalizedString(@"environment_exception_settings_same", @"变量名重复，请重新输入");
        
        if ([ESCommonToolManager isEnglish]) {
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(0);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(200);
                make.height.offset(40);
            }];
        }else{
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(0);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(200);
                make.height.offset(20);
            }];
        }

       
        [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
            make.top.mas_equalTo(self.popErrorView.mas_top).offset(0);
            make.width.offset(180);
        }];
    }else if(self.isError1){
        self.error.text = NSLocalizedString(@"environment_exception_variable_key_empty", @"变量名不能为空，请重新输入");
  
        if ([ESCommonToolManager isEnglish]) {
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(0);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(200);
                make.height.offset(40);
            }];
        }else{
            [self.popErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(0);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
                make.width.offset(200);
                make.height.offset(20);
            }];
        }
        [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
            make.top.mas_equalTo(self.popErrorView.mas_top).offset(0);
            make.width.offset(180);
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.error.hidden = YES;
        self.popErrorView.hidden = YES;
    });
    
}

- (UIImageView *)popErrorView {
    if (!_popErrorView) {
        _popErrorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.error = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 18)];
        self.error.numberOfLines = 2;
        self.error.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [_popErrorView addSubview: self.error];
        _popErrorView.image = [UIImage imageNamed:@"kfz_pop"];
        self.error.textColor = [UIColor es_colorWithHexString:@"#F6222D"];
        _popErrorView.backgroundColor = ESColor.systemBackgroundColor;
        [self.contentView addSubview:_popErrorView];
        [self.contentView bringSubviewToFront:_popErrorView];
    }
    return _popErrorView;
}


@end

