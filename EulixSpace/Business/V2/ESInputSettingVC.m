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
//  ESInputSettingVC.m
//  EulixSpace
//
//  Created by Ye qu on 2023/01/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESInputSettingVC.h"
#import "ESAccountManager.h"
#import "ESApiCode.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "NSString+ESTool.h"
#import "UIView+ESTool.h"
#import "ESBoxManager.h"
#import "ESCommonToolManager.h"
#import "ESBoxItem.h"
#import "ESCommentCachePlistData.h"
#import <Masonry/Masonry.h>
#import "ESAccountServiceApi.h"
#import "ESPersonalInfoResult.h"
#import "ESDefaultConfiguration.h"
#import "ESApiClient.h"

@interface ESInputSettingVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *input;

@property (nonatomic, strong) UILabel *prompt;

@property (nonatomic, strong) UILabel *dominLabel;

@property (nonatomic, strong) UILabel *pointOutLabel;

@property (nonatomic, strong) UILabel *recommendLabel;

@property (nonatomic, copy) NSString *naviTitle;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *dominStr;

@property (nonatomic, assign) NSUInteger limit;

@property (nonatomic, strong) NSArray *dominArray;

@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation ESInputSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.input.text = self.model.value;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.input becomeFirstResponder];
}

- (void)setType:(ESInputSettingVCType)type {
    _type = type;

    if (type == ESInfoEditTypeName) {
        self.limit = 24;
        self.naviTitle = TEXT_ME_PERSONAL_NICKNAME;
        self.placeholder = TEXT_ME_NICKNAME_PLACEHOLDER;
        //昵称编辑    mine.changeNickName

    } else if (type == ESInfoEditTypeDomin) {
        self.limit = 24;
        self.naviTitle = TEXT_ME_DOMAIN_NAME;

    }else if (type == ESInfoEditTypeV2Domin) {
        self.limit = 120;
        self.navigationItem.rightBarButtonItem = [self barItemWithTitle:NSLocalizedString(@"ok", @"确定") selector:@selector(submit)];
        if(self.isAuthority){
            self.naviTitle = NSLocalizedString(@"Private Platform Address", @"私有平台地址");
        }else{
            self.naviTitle = NSLocalizedString(@"Official Platform Address", @"官方平台地址");
        }
        
        self.navigationItem.rightBarButtonItem.tintColor = ESColor.primaryColor;
        self.placeholder = NSLocalizedString(@"Start with http, https", @"请以http、https开头");
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"ok", @"确定");
    }
    else {
        self.limit = 120;
        self.naviTitle = TEXT_ME_PERSONAL_SIGN;
        self.placeholder = TEXT_ME_SIGN_PLACEHOLDER;

        //个性签名修改    mine.changeSignature
    }
    //self.navigationItem.rightBarButtonItem = [self barItemWithTitle:@"完成" selector:@selector(submit)];
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
    self.navigationItem.rightBarButtonItem = confirmItem;
}

- (void)submit {
    
    if(self.type == 0){
        if ([self convertToInt:self.input.text] > 15) {
            [ESToast toastError:NSLocalizedString(@"The name dont meet the specification", @"名称不符合规范")];
            return;
        }
    }else if(self.type == 1){
        if ([self convertToInt:self.input.text] > 20) {
           [ESToast toastError:NSLocalizedString(@"The name dont meet the specification", @"名称不符合规范")];
            return;
        }
        if(![self isOnlyAlphaNumeric:self.input.text]){
           [ESToast toastError:NSLocalizedString(@"The name dont meet the specification", @"名称不符合规范")];
            return;
        }
    }else if(self.type == 2){
        if(![self isOnlyAlphaNumeric:self.input.text]){
           [ESToast toastError:NSLocalizedString(@"The name dont meet the specification", @"名称不符合规范")];
            return;
        }
        if (self.input.text.length < 3 || self.input.text.length > 20) {
           [ESToast toastError:NSLocalizedString(@"The name dont meet the specification", @"名称不符合规范")];
            return;
        }
    }
    
    if (self.updateName) {
        self.updateName(self.input.text);
    }
    [self.navigationController popViewControllerAnimated:YES];

}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
 
    [self.selectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.selectBtn.enabled = NO;
    self.selectBtn.userInteractionEnabled = NO;
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
    self.navigationItem.rightBarButtonItem = confirmItem;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length < 1) {
        [self.selectBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.selectBtn.enabled = NO;
        self.selectBtn.userInteractionEnabled = NO;
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.navigationItem.rightBarButtonItem = confirmItem;
  
    }else if(textField.text.length > 0){
        [self.selectBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        self.selectBtn.userInteractionEnabled = YES;
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.navigationItem.rightBarButtonItem = confirmItem;
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.pointOutLabel.hidden = YES;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return YES;
        }
    }
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.limit > 0 && result.length > self.limit) {
        return NO;
    }

    return YES;
}



#pragma mark - Lazy Load

- (UITextField *)input {
    if (!_input) {
        _input = [UITextField new];
        _input.textColor = ESColor.labelColor;
        _input.font = [UIFont systemFontOfSize:14];
        _input.delegate = self;
        _input.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.view addSubview:_input];
        if (self.type == ESInfoEditTypeDomin) {
            [_input mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).inset(26);
                make.right.mas_equalTo(self.view.mas_right).offset(-115);
                make.top.mas_equalTo(self.view);
                make.height.mas_equalTo(76);
            }];
        }else{
            [_input mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.view).inset(26);
                make.top.mas_equalTo(self.view);
                make.height.mas_equalTo(76);
            }];
        }
    }
    return _input;
}

- (UILabel *)dominLabel {
    if (!_dominLabel) {
        _dominLabel = [UILabel new];
        _dominLabel.textColor = ESColor.secondaryLabelColor;
        _dominLabel.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_dominLabel];
        [_dominLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_right).offset(-26);
            make.left.mas_equalTo(self.input.mas_right).offset(10);
            make.top.mas_equalTo(self.view);
            make.height.mas_equalTo(76);
        }];
    }
    return _dominLabel;
}

- (UILabel *)prompt {
    if (!_prompt) {
        _prompt = [UILabel new];
        _prompt.textColor = ESColor.secondaryLabelColor;
        _prompt.font = [UIFont systemFontOfSize:10];
        _prompt.numberOfLines = 0;
        [self.view addSubview:_prompt];
        [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view).inset(26);
            make.top.mas_equalTo(self.input.mas_bottom).inset(10);
        }];
    }
    return _prompt;
}


//- (UILabel *)prompt {
//    if (!_prompt) {
//        _prompt = [UILabel new];
//        _prompt.textColor = ESColor.secondaryLabelColor;
//        _prompt.font = [UIFont systemFontOfSize:12];
//        [self.view addSubview:_prompt];
//        [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.mas_equalTo(self.view).inset(26);
//            make.top.mas_equalTo(self.input.mas_bottom).inset(10);
//            make.height.mas_equalTo(20);
//        }];
//    }
//    return _prompt;
//}


- (UILabel *)pointOutLabel {
    if (!_pointOutLabel) {
        _pointOutLabel = [UILabel new];
        _pointOutLabel.textColor = ESColor.redColor;
        _pointOutLabel.font = [UIFont systemFontOfSize:10];
        [self.view addSubview:_pointOutLabel];
        [_pointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(26);
            make.right.mas_equalTo(self.view).offset(-26);
            make.top.mas_equalTo(self.prompt.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
    }
    return _pointOutLabel;
}

- (UILabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel = [UILabel new];
        _recommendLabel.textColor = ESColor.labelColor;
        _recommendLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_recommendLabel];
        if(self.pointOutLabel.hidden){
            [_recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(26);
                make.right.mas_equalTo(self.view).offset(-26);
                make.top.mas_equalTo(self.prompt.mas_bottom).offset(10);
                make.height.mas_equalTo(20);
            }];
        }else{
            [_recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).offset(26);
                make.right.mas_equalTo(self.view).offset(-26);
                make.top.mas_equalTo(self.pointOutLabel.mas_bottom).inset(10);
                make.height.mas_equalTo(20);
            }];
        }
    }
    return _recommendLabel;
}


-(void)createDomireCommendLabel:(NSArray *)dominArray{
    if (dominArray.count >0) {
        for (int i = 0; i<dominArray.count; i++) {
            UIButton *dominBtn = [[UIButton alloc] init];
            dominBtn.backgroundColor = ESColor.secondarySystemBackgroundColor;
            [self.view addSubview:dominBtn];
            
            dominBtn.layer.cornerRadius = 10;
            dominBtn.layer.masksToBounds = YES;
            dominBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            dominBtn.contentEdgeInsets = UIEdgeInsetsMake(10,20, 10, 20);
            dominBtn.tag = 1000101 + i;
            [dominBtn addTarget:self action:@selector(dominBtn:) forControlEvents:UIControlEventTouchUpInside];
            [dominBtn setTitle:dominArray[i] forState:UIControlStateNormal];
            [dominBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
            if (i== 0) {
                [dominBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.view).offset(26);
                    make.top.mas_equalTo(self.recommendLabel.mas_bottom).offset(10);
                    make.height.mas_equalTo(36);
                }];
            }else{
                [dominBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.view).offset(26);
                    make.top.mas_equalTo(self.recommendLabel.mas_bottom).offset(10 +i*46);
                    make.height.mas_equalTo(36);
                }];
            }
        }
    }
}

-(void)dominBtn:(UIButton *)btn{
    self.input.text = btn.titleLabel.text;
    self.pointOutLabel.hidden = YES;
    [_recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(26);
        make.right.mas_equalTo(self.view).offset(-26);
        make.top.mas_equalTo(self.prompt.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
}

-(BOOL)checkDomin:(NSString *)dominTitle{
    NSString *regular = @"^[A-Za-z].+$";
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
     if ([predicate evaluateWithObject:dominTitle] == YES){
         if (self.input.text.length > 5 && self.input.text.length < 21) {
             NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
             NSInteger countNum = [numberRegular numberOfMatchesInString:self.input.text options:NSMatchingReportProgress range:NSMakeRange(0, self.input.text.length)];
             
             NSRegularExpression *numberRegularEn = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];

             NSInteger count = [numberRegularEn numberOfMatchesInString:self.input.text options:NSMatchingReportProgress range:NSMakeRange(0, self.input.text.length)];
             if((countNum + count) == self.input.text.length){
                 return YES;
             }else{
                 return NO;
             }

         }else{
             return NO;
         }
     }else{
         return NO;
     }
}

-(void)setModel:(ESCellModel *)model{
    _model = model;
    self.navigationItem.title = model.title;
    if(self.type == 0){
        self.input.placeholder = NSLocalizedString(@"applet_name_input_hint", @"请输入应用名称");
        self.prompt.text = NSLocalizedString(@"applet_name_common_hint", @"显示在快捷方式处的名称，支持中文、英文及特殊符号，最长30个字符");
    }else if(self.type == 1){
        self.input.placeholder = NSLocalizedString(@"service_name_input_hint", @"请输入服务名称");
        self.prompt.text = NSLocalizedString(@"service_name_common_hint", @"仅支持英文、数字，最长40个字符，不支持特殊符号");
    }else if(self.type == 2){
        self.input.placeholder = NSLocalizedString(@"domain_name_prefix_input_hint", @"请输入域名前缀");
        self.prompt.text = NSLocalizedString(@"domain_name_prefix_common_hint", @"域名前缀拼接用户域名形成应用的网页访问链接，限3~20个字符，支持字母、数字，不支持特殊符号");
    }
    [self.input es_addline:0];
    self.input.text = model.value;

}

- (int)convertToInt:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
     
    int result = (strlength+1)/2;
    return result;
}


- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.backgroundColor = ESColor.clearColor;
        _selectBtn.frame = CGRectMake(0, 0, 45, 45);
        [_selectBtn setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        [_selectBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        //[_selectBtn setImage:[UIImage imageNamed:@"xuanze"] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectBtn];
    }
    return _selectBtn;
}


- (BOOL)isOnlyAlphaNumeric:(NSString *)str {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-zA-Z0-9]*"] evaluateWithObject:str];
}

@end
