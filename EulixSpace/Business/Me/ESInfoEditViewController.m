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
//  ESInfoEditViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESInfoEditViewController.h"
#import "ESAccountManager.h"
#import "ESApiCode.h"
#import "ESFamilyCache.h"
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

@interface ESInfoEditViewController () <UITextFieldDelegate>

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

@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation ESInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.naviTitle;
    self.input.placeholder = self.placeholder;
    if (self.type == ESInfoEditTypeDomin) {
        [self.view es_addline:0];
        UIView *line = [UIView new];
        line.backgroundColor = ESColor.separatorColor;
        [self.view addSubview:line];
        
        [self.dominLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_right).offset(-26);
            make.top.mas_equalTo(self.view);
            make.height.mas_equalTo(76);
        }];
    
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(26);
            make.right.mas_equalTo(self.view).offset(-26);
            make.top.mas_equalTo(self.input.mas_bottom).offset(-1);
            make.height.mas_equalTo(1);
        }];

    }else{
        [self.input es_addline:0];
        self.input.text = self.value;
    }
    
    if (self.type == ESInfoEditTypeV2Domin) {
        self.prompt.text = NSLocalizedString(@"ok", @"确定");
        self.prompt.hidden = YES;
    }else{
        self.prompt.hidden = NO;
    }
   
    if (self.type == ESInfoEditTypeName) {
        self.prompt.text = TEXT_ME_NICKNAME_PROMPT;
    }
  
    if (self.type == ESInfoEditTypeDomin) {
        self.prompt.text = NSLocalizedString(@"Start with a letter, 6-20 digits in length, supporting letters and numbers", @"以字母开头，长度6～20位，支持字母、数字"); 
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.input becomeFirstResponder];
}

- (void)setType:(ESInfoEditType)type {
    _type = type;
    
    if (type == ESInfoEditTypeName) {
        self.limit = 24;
        self.naviTitle = NSLocalizedString(@"me_spaceidentification", @"空间标识");
        //请输入您的空间标识，长度为 1-24 位字符
        self.placeholder = NSLocalizedString(@"me_spaceidentification_placeholder", nil);// TEXT_ME_NICKNAME_PLACEHOLDER;
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
        self.placeholder = NSLocalizedString(@"Start with http, https", @"请以http、https开头");;

        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"ok", @"确定");
        [_submitBtn setTitle:NSLocalizedString(@"ok", @"确定") forState:UIControlStateNormal];
    }
    else if(type == ESInfoEditTypeSign){
        
        self.limit = 120;
        self.naviTitle = TEXT_ME_PERSONAL_SIGN;
        self.placeholder = TEXT_ME_SIGN_PLACEHOLDER;
        
        //个性签名修改    mine.changeSignature
    }

    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.submitBtn];
    self.navigationItem.rightBarButtonItem = confirmItem;

}


- (void)submit {

    if (self.type == ESInfoEditTypeName ||self.type ==ESInfoEditTypeDomin) {
        if(self.input.text.length > self.limit){
            [ESToast toastError:NSLocalizedString(@"over_maxcount", @"超过最大字符")];
            return;
        }
    } else if (self.type == ESInfoEditTypeV2Domin || self.type == ESInfoEditTypeSign) {
        if(self.input.text.length > self.limit){
            [ESToast toastError:NSLocalizedString(@"over_maxcount", @"超过最大字符")];
            return;
        }
    }
    
    [ESCommonToolManager isBackupInComple];
    if (self.type == ESInfoEditTypeV2Domin) {
        if([self.input.text containsString:@"https://"]||[self.input.text containsString:@"http://"]){
                if (self.updateName) {
                    [self goBack];
                    self.updateName(self.input.text);
                }
        }else{
            [ESToast toastError:NSLocalizedString(@"URL don't conform to specifications", @"URL地址不符合规范")];
        }
    }
    
    if (self.type == ESInfoEditTypeDomin) {
        if ([self.input.text isEqual:self.dominStr]) {
            [self goBack];
            return;
        }
        
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"backupInProgress"];
        if([str isEqual:@"YES"]){
            [ESToast toastSuccess:NSLocalizedString(@"Executing backup task", @"正在执行备份任务，暂不支持此操作")];
            return;
        }
        NSString *reStoreInProgress = [[NSUserDefaults standardUserDefaults] objectForKey:@"reStoreInProgress"];
        if([reStoreInProgress isEqual:@"YES"]){
//            [ESToast toastSuccess:@"正在执行恢复任务，暂不支持此操作"];
            [ESToast toastSuccess:NSLocalizedString(@"Performing recovery task, this operation is not currently supported", @"正在执行恢复任务，暂不支持此操作")];
            return;
        }
        
        BOOL isSava = [self checkDomin:self.input.text];
        if(!isSava){
            [ESToast toastError:NSLocalizedString(@"domain_format_error", @"域名不符合规范")];
            return;
        }
    }
    if (self.type == ESInfoEditTypeName) {
        if (self.input.text.length == 0) {
            [self goBack];
            return;
        }
        //200-299 都行
        if (self.aoid.length < 1) {
            [ESAccountManager.manager updateName:self.input.text
                                      completion:^(ESResponseBaseArrayListAccountInfoResult *output) {
                                          if (output.code.justErrorCode >= ESApiCodeOk && output.code.justErrorCode <= ESApiCodeOKMax) {
                                              [[ESFamilyCache sharedInstance] getFamilyListFirstCache];
                                              [self goBack];
                                              if (self.updateName) {
                                                  self.updateName(self.input.text);
                                              }
                                          } else if (output.code.justErrorCode == 403 || output.code.justErrorCode == 400) {
                                              [ESToast toastWarning:NSLocalizedString(@"me_duplicatespaceidentify", @"空间标识重复，请重新输入")];
                                          }
                                      }];
        }else {
            [ESAccountManager.manager updateMemberName:self.input.text
                                                  aoId:self.aoid
                                            completion:^(ESResponseBaseMemberNameUpdateInfo *output) {
                                                if (output.code.justErrorCode >= ESApiCodeOk && output.code.justErrorCode <= ESApiCodeOKMax) {
                                                    [[ESFamilyCache sharedInstance] getFamilyListFirstCache];
                                                    if (self.updateName) {
                                                        self.updateName(output.results.nickName);
                                                    }
                                                    
                                                    [self goBack];
                                                } else if (output.code.justErrorCode == 403 || output.code.justErrorCode == 400) {
                                                    [ESToast toastError:NSLocalizedString(@"me_duplicatespaceidentify", @"空间标识重复，请重新输入")];                                                
                                                } else{
                                                    [ESToast toastError:TEXT_ME_NICKNAME_INVALID_PROMPT];
                                                }
                                            }];
        }
        
    }
    if (self.type == ESInfoEditTypeDomin) {
        
        ESAccountServiceApi *api = [ESAccountServiceApi new];
        ESPersonalInfo *body = [ESPersonalInfo new];
        body.aoId = self.aoid;
        body.userDomain = self.input.text;
        ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
        [api spaceV1ApiPersonalDomainUpdatePostWithBody:body completionHandler:^(ESResponseBasePersonalInfoResult *output, NSError *error) {
            [ESToast dismiss];
            if (error) {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                [self goBack];
                return;
            }

            if ([output.code isEqualToString:@"GW-5005"]) {
                [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
                return;
            }
            if ([output.code isEqual:@"ACC-4001"]) {
                [ESToast toastError:NSLocalizedString(@"Modify Fail", @"修改失败")];
                [self goBack];
                return;
            }
            if ([output.code isEqual:@"ACC-4022"]) {
                [ESToast toastError:NSLocalizedString(@"Modify only once a year", @"一年仅可修改一次")];
            }
            if ([output.code isEqual:@"ACC-201"]) {
                ESBoxItem *box = ESBoxManager.activeBox;
                ESBoxItem *matchBoxItem = [ESBoxManager.manager getBoxItemWithBoxUuid:box.boxUUID boxType:box.boxType aoid:box.aoid];
                if (matchBoxItem == nil) {
                    return;
                }
                matchBoxItem.info.userDomain = [NSString stringWithFormat:@"%@%@",self.input.text,self.dominLabel.text];
                [ESBoxManager.manager saveBox:matchBoxItem];
               
                [ESToast toastSuccess:NSLocalizedString(@"Modified successfully", @"修改成功")];
                [[ESFamilyCache sharedInstance] getFamilyListFirstCache];
                ESDefaultConfiguration.sharedConfig.host = [NSString stringWithFormat:@"%@%@",self.input.text,self.dominLabel.text];
                [self goBack];
             };

            if([output.code isEqual:@"ACC-2018"] || [output.code isEqual:@"ACC-400"]) {
                [ESToast toastError:NSLocalizedString(@"The domain name is already in use", @"域名已被使用")];
                self.pointOutLabel.hidden = NO;
                self.pointOutLabel.text = NSLocalizedString(@"The domain name has already been registered or is not available;", @"此域名已被注册或不可用");

                self.recommendLabel.text = NSLocalizedString(@"Domain name dont conform to specifications", @"您可以选择我们推荐的域名前缀");
                [self.pointOutLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.view).offset(26);
                    make.right.mas_equalTo(self.view).offset(-26);
                    make.top.mas_equalTo(self.prompt.mas_bottom).inset(10);
                    make.height.mas_equalTo(20);
                }];

                [self.recommendLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.view).offset(26);
                    make.right.mas_equalTo(self.view).offset(-26);
                    make.top.mas_equalTo(self.pointOutLabel.mas_bottom).offset(10);
                    make.height.mas_equalTo(20);
                }];

                [self.view updateConstraintsIfNeeded];
                [self.view layoutIfNeeded];

                NSArray * dmoinArray = output.results.domainList;
                [self createDomireCommendLabel:dmoinArray];
            }
        }];
    }
    if (self.type == ESInfoEditTypeSign) {
        [ESAccountManager.manager updateSign:self.input.text aoid:self.aoid completion:^(ESPersonalInfoResult *info) {
            [[ESFamilyCache sharedInstance] getFamilyListFirstCache];
            [self goBack];
        }];
    }

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.pointOutLabel.hidden = YES;
    if (self.type == ESInfoEditTypeName && [string containsString:@""]) {
        return NO;
    }
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return YES;
        }
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

    }
    return _dominLabel;
}

- (UILabel *)prompt {
    if (!_prompt) {
        _prompt = [UILabel new];
        _prompt.textColor = ESColor.secondaryLabelColor;
        _prompt.font = [UIFont systemFontOfSize:10];
        _prompt.textAlignment = NSTextAlignmentLeft;
        _prompt.numberOfLines = 0;
        [self.view addSubview:_prompt];
        [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view).inset(26);
            make.top.mas_equalTo(self.input.mas_bottom).inset(10);
    
        }];
    }
    return _prompt;
}


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

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] init];
        _submitBtn.backgroundColor = ESColor.clearColor;
        _submitBtn.frame = CGRectMake(0, 0, 45, 45);
        [_submitBtn setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        [_submitBtn setTitleColor:ESColor.btnBuleColor forState:UIControlStateNormal];
        //[_selectBtn setImage:[UIImage imageNamed:@"xuanze"] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_submitBtn];
    }
    return _submitBtn;
}

-(void)setValue:(NSString *)value{
    _value = value;
    if (self.type == ESInfoEditTypeDomin) {
        NSArray *array = [self.value componentsSeparatedByString:@"."];
        if(array.count > 0){
            _input.text = array[0];
            _dominStr = array[0];
        }
        if(array.count > 0){
            NSString *str;
            for (int i = 0; i < array.count; i++) {
                if (i!=0) {
                    if(str.length == 0){
                        str = [NSString stringWithFormat:@".%@",array[i]];
                    }else{
                        str = [NSString stringWithFormat:@"%@.%@",str,array[i]];
                    }
                }
            }
            _dominLabel.text = str;
            // 自适应控件宽度
            CGSize size = [self.dominLabel.text sizeWithAttributes:@{NSFontAttributeName: self.dominLabel.font}];
            [_dominLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(size.width + 10);//增加10pt的额外宽度
            }];
        
            [_input mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view).inset(26);
                make.width.mas_equalTo(ScreenWidth -52- size.width - 10);
                make.top.mas_equalTo(self.view);
                make.height.mas_equalTo(76);
            }];
        }
    }else{
        [_input es_addline:0];
        _input.text = _value;
    }
}
@end
