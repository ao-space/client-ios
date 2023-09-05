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
//  ESPostSettingCell.m
//  EulixSpace
//
//  Created by qu on 20212/1/09.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPostSettingCell.h"
#import "ESFormItem.h"
#import "ESLongTextInputView.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "UIColor+ESHEXTransform.h"
#import "ESCommonToolManager.h"

#import <Masonry/Masonry.h>

@interface ESPostSettingCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *title1;

@property (nonatomic, strong) UILabel *title2;

@property (nonatomic, strong) UILabel *title3;

@property (nonatomic, strong) UITextField *content;

@property (nonatomic, strong) UIImageView * icon;

@property (nonatomic, strong) UITextField *textInput;

@property (nonatomic, strong) UIView *line1;

@property (nonatomic, strong) UIView *line2;

@property (nonatomic, strong) UIView *line3;

@property (nonatomic, strong) UIView *line4;

@property (nonatomic, strong) UIImageView *popErrorView;

@property (nonatomic, strong) UIImageView * arrowImageView;

@property (nonatomic, strong) UIImageView * arrowImageView1;

@property (nonatomic, strong) UIImageView * delIcon;

@property (nonatomic, strong) UIImageView * errIcon;

@property (nonatomic, strong) UIButton * errorBtn;

@property (nonatomic, strong) UILabel * error;

@property (nonatomic, strong) UILabel *titleEor;

@end

@implementation ESPostSettingCell

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
    self.errorBtn.hidden = YES;

    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(0);
        make.left.mas_equalTo(self.contentView.mas_left).offset(155);
        make.height.mas_equalTo(186);
        make.width.mas_equalTo(1);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(61);
        make.left.mas_equalTo(self.contentView).offset(155);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
    }];
    
    [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(123);
        make.left.mas_equalTo(self.contentView).offset(155);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
    }];
    
    
    [self.line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(-1);
        make.left.mas_equalTo(self.contentView.mas_left).offset(26);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
    }];
    

    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(82);
        make.left.mas_equalTo(self.contentView).offset(26);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(82);
        make.left.mas_equalTo(self.icon.mas_right).offset(6);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
 
    [self.title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-35);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(22);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(82);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    
    
    self.title2.text = NSLocalizedString(@"internal_port", @"内部端口");
    [self.title2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(82);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-45);
        make.height.mas_equalTo(22);
    }];

    self.title3.text = NSLocalizedString(@"http_request_forward", @"http请求转发");
    [self.title3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(144);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-45);
        make.height.mas_equalTo(22);
    }];

    [self.arrowImageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(144);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-26);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];
    

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(21);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-35);
        make.height.mas_equalTo(30);
    }];
    
    self.popErrorView.hidden = YES;
    self.titleEor.hidden = YES;
    
    [self.titleEor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(77);
        make.left.mas_equalTo(self.icon.mas_right).offset(6);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(50);
    }];
}


#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.numberOfLines = 0;
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        _title.text = NSLocalizedString(@"container_publish_port", @"容器发布端口");
        [self.contentView addSubview:_title];
        _title.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
        // 允许用户交互
        [_title addGestureRecognizer:tap];
        
    }
    return _title;
}

- (UILabel *)titleEor{
    if (!_titleEor) {
        _titleEor = [[UILabel alloc] init];
        _titleEor.textColor = ESColor.labelColor;
        _titleEor.textAlignment = NSTextAlignmentLeft;
        _titleEor.numberOfLines = 0;
        _titleEor.hidden = YES;
        _titleEor.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        _titleEor.text = NSLocalizedString(@"container_publish_port", @"容器发布端口");
        _titleEor.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
        // 允许用户交互
        [_titleEor addGestureRecognizer:tap];
        [self.contentView addSubview:_titleEor];
    }
    return _titleEor;
}

- (UILabel *)title1 {
    if (!_title1) {
        _title1 = [[UILabel alloc] init];
        _title1.textColor = ESColor.labelColor;
        _title1.textAlignment = NSTextAlignmentRight;
        _title1.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title1];
       
    }
    return _title1;
}

- (UILabel *)title2 {
    if (!_title2) {
        _title2 = [[UILabel alloc] init];
        _title2.textColor = ESColor.labelColor;
        _title2.textAlignment = NSTextAlignmentRight;
        _title2.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title2];
        _title2.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(title2TapImgView:)];
        [_title2 addGestureRecognizer:tap];
    }
    return _title2;
}
- (UILabel *)title3 {
    if (!_title3) {
        _title3 = [[UILabel alloc] init];
        _title3.textColor = ESColor.labelColor;
        _title3.textAlignment = NSTextAlignmentRight;
        _title3.userInteractionEnabled = YES;
        _title3.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(title3TapImgView:)];
        [_title3 addGestureRecognizer:tap];
    }
    return _title3;
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)title2TapImgView:(UITapGestureRecognizer *)tap {
    self.actionBlockPort(self.title2.text);
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)title3TapImgView:(UITapGestureRecognizer *)tap {
    self.actionBlockHttp( self.title3.text);
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"kfz_del"];
        _icon.layer.cornerRadius = 4.0;
        _icon.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
        // 允许用户交互
        _icon.userInteractionEnabled = YES;
     
        [_icon addGestureRecognizer:tap];

        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"me_arrow"];
        _arrowImageView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap:)];
        // 允许用户交互
        _arrowImageView.userInteractionEnabled = YES;
     
        [_arrowImageView addGestureRecognizer:tap];
        [self.contentView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIImageView *)arrowImageView1 {
    if (!_arrowImageView1) {
        _arrowImageView1 = [[UIImageView alloc] init];
        _arrowImageView1.image = [UIImage imageNamed:@"me_arrow"];
        _arrowImageView1.layer.masksToBounds = YES;
        _arrowImageView1.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(arrowTap1:)];
        // 允许用户交互
        [_arrowImageView1 addGestureRecognizer:tap];
        [self.contentView addSubview:_arrowImageView1];
    }
    return _arrowImageView1;
}

- (UIImageView *)errIcon {
    if (!_errIcon) {
        _errIcon = [[UIImageView alloc] init];
        _errIcon.image = [UIImage imageNamed:@"error_check"];
        [self.contentView addSubview:_errIcon];
    }
    return _errIcon;
}


- (UITextField *)content {
    if (!_content) {
        _content = [[UITextField alloc] init];
        _content.textColor = ESColor.labelColor;
        _content.textAlignment = NSTextAlignmentRight;
        _content.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        _content.text = @"8000";
        _content.placeholder = NSLocalizedString(@"port_number", @"端口号");
        _content.tag = 123;
        _content.delegate = self;
        [self.contentView addSubview:_content];
    }
    return _content;
}

-(void)setModel:(ESDeveloInfo *)model{
    _model = model;
    self.popErrorView.hidden = YES;
    if(model.lastCell){
        self.title.text = NSLocalizedString(@"insert_port", @"添加端口");
        _icon.image = [UIImage imageNamed:@"kfz_add"];
        self.icon.hidden = NO;
        self.title1.hidden = YES;
        self.title2.hidden = YES;
        self.title3.hidden = YES;
        self.content.hidden = YES;
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        self.line3.hidden = YES;
        self.line4.hidden = YES;
        self.arrowImageView.hidden = YES;
        self.arrowImageView1.hidden = YES;

        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(20);
            make.left.mas_equalTo(self.icon.mas_right).offset(6);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(22);
        }];
    

        [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(20);
            make.left.mas_equalTo(self.contentView).offset(26);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(20);
        }];
        
    }else {
        [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(82);
            make.left.mas_equalTo(self.contentView).offset(26);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(20);
        }];
        if(model.isFirst){
            self.icon.hidden = YES;

        }else{
            self.icon.hidden = NO;
            [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(82);
                make.left.mas_equalTo(self.icon.mas_right).offset(6);
                make.width.mas_equalTo(100);
            }];
        }
  
        _icon.image = [UIImage imageNamed:@"kfz_del"];
        self.title.text = NSLocalizedString(@"container_publish_port", @"容器发布端口");;
        self.title2.text = model.value1;
        self.title3.text = model.value2;
        self.title1.hidden = NO;
        self.title2.hidden = NO;
        self.title3.hidden = NO;
        self.content.hidden =  NO;
        self.line1.hidden = NO;
        self.line2.hidden = NO;
        self.line3.hidden = NO;
        self.line4.hidden = NO;
        self.arrowImageView.hidden = NO;
        self.arrowImageView1.hidden = NO;
        self.content.text = model.value;
    }
    
    if(model.errorDic.count > 0 && ! self.isLast){
        self.title.hidden = YES;
    
        self.titleEor.hidden = NO;
        self.errIcon.hidden = NO;
        self.errorBtn.hidden = NO;
        self.title.text = NSLocalizedString(@"container_publish_port", @"容器发布端口");
        [self.errIcon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleEor.mas_centerY);
            make.left.mas_equalTo(self.titleEor.mas_right).offset(6);
            make.width.mas_equalTo(16);
            make.height.mas_equalTo(16);
        }];
        
        [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
            make.left.mas_equalTo(self.title.mas_right).offset(-50);
            make.height.mas_equalTo(50);
                 make.width.mas_equalTo(300);
        }];
    
        [self.errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleEor.mas_centerY);
            make.left.mas_equalTo(self.titleEor.mas_right).offset(6);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.title.mas_centerY);
            make.left.mas_equalTo(self.contentView).offset(26);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(20);
        }];
//
        [self.error mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
            make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
        }];
        NSString *errorStr;
    
        NSString *error1 = model.errorDic[@"error1"];
        NSString *error2 = model.errorDic[@"error2"];
        NSString *error3 = model.errorDic[@"error3"];
        if(error1.length < 1){
            error1= @"";
        }
        if(error2.length < 1){
            error2= @"";
        }
        if(error3.length < 1){
            error3= @"";
        }
        
        if(error1.length > 1 && error2.length > 1 &&  error3.length > 1){
            errorStr = [NSString stringWithFormat:@"%@\n%@\n%@",error1,error2,error3];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(80);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }else if(error1.length > 1 && error2.length > 1){
            errorStr = [NSString stringWithFormat:@"%@\n%@",error1,error2];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(50);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }else if(error2.length > 1 && error3.length > 1){
            errorStr = [NSString stringWithFormat:@"%@\n%@",error2,error3];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(50);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }else if(error1.length > 1 && error3.length > 1){
            errorStr = [NSString stringWithFormat:@"%@\n%@",error1,error3];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(50);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }else if(error1.length > 0){
            errorStr = [NSString stringWithFormat:@"%@",error1];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(50);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(15);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(10);
            }];
        }else if(error2.length > 0){
            errorStr = [NSString stringWithFormat:@"%@",error2];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(50);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }else if(error3.length > 0){
            errorStr = [NSString stringWithFormat:@"%@",error3];
            [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
                make.left.mas_equalTo(self.title.mas_right).offset(-50);
                make.height.mas_equalTo(30);
                make.width.mas_equalTo(ScreenWidth- 52);
            }];
            [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
                make.top.mas_equalTo(self.popErrorView.mas_top).offset(5);
            }];
        }
      
        self.error.text = errorStr;
        
        [self.contentView layoutIfNeeded];
    }else{
        self.errIcon.hidden = YES;
        self.errorBtn.hidden = YES;
        self.title.hidden = NO;
        self.titleEor.hidden = YES;
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

- (UIView *)line3 {
    if (!_line3) {
        _line3 = [UIView new];
        _line3.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line3];
    }
    return _line3;
}

- (UIView *)line4 {
    if (!_line4) {
        _line4 = [UIView new];
        _line4.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line4];
        [self.contentView bringSubviewToFront:_line4];
    }
    return _line4;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.tag == 123){

    }
    self.actionBlock(textView.text);
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.actionBlock(textField.text);
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
    if (self.model.errorInt == 1) {
        self.error.text = NSLocalizedString(@"port_exception_settings_same", @"端口配置重复，请重新输入");
    }else if(self.model.errorInt == 2){
        self.error.text = NSLocalizedString(@"port_exception_purpose_http_multiple", @"不支持配置多个用途为“http请求转发”的端口");
    }else if(self.model.errorInt == 3){
        self.error.text = NSLocalizedString(@"port_exception_settings_same_more", @"端口配置重复，请重新输入不支持配置多个用途为”http请求转发“的端口");
    }
    
    if ([ESCommonToolManager isEnglish]) {
        [self.error mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.popErrorView.mas_left).offset(10);
            make.right.mas_equalTo(self.popErrorView.mas_right).offset(-10);
            make.top.mas_equalTo(self.popErrorView.mas_top).offset(10);
        }];
        [self layoutIfNeeded];
        [self.popErrorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.errIcon.mas_top).offset(-5);
            make.left.mas_equalTo(self.title.mas_right).offset(-50);
            make.height.mas_equalTo(self.error.frame.size.height + 20);
            make.width.mas_equalTo(ScreenWidth- 52);
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
        _popErrorView.image = [UIImage imageNamed:@"kfz_pop"];
        self.error = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 18)];
        self.error.numberOfLines = 0;
        self.error.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        [_popErrorView addSubview: self.error];
        self.error.textColor = [UIColor es_colorWithHexString:@"#F6222D"];
//        _popErrorView.layer.masksToBounds = YES;
        _popErrorView.backgroundColor = ESColor.systemBackgroundColor;
        [self.contentView addSubview:_popErrorView];

    }
    return _popErrorView;
}


- (void)doTap:(NSString *)str{
    self.actionDel(@"1");
}

- (void)arrowTap:(NSString *)str{
    self.actionBlockPort(self.title3.text);
}

- (void)arrowTap1:(NSString *)str{
    self.actionBlockHttp(self.title2.text);
}

@end

