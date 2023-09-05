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
//  ESSetingViewController.m
//  EulixSpace
//
//  Created by qu on 2021/5/21.
//

#import "ESSetingViewController.h"
#import "EBDropdownListView.h"
#import "ESHomeCoordinator.h"
#import "ESThemeDefine.h"
#import <CoreTelephony/CTCellularData.h>
#import <Masonry/Masonry.h>

@interface ESSetingViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLable;

/// UUID
@property (nonatomic, strong) UITextField *uuidInputField;
@property (nonatomic, strong) UILabel *uuidInputTitle;
@property (nonatomic, strong) UILabel *uuidInputNoteLable;

/// 国家
@property (nonatomic, strong) EBDropdownListView *countryDownListView;
@property (nonatomic, strong) UILabel *countryInputTitle;
@property (nonatomic, strong) UILabel *countryInputNoteLable;

/// 语言
@property (nonatomic, strong) EBDropdownListView *languageDownListView;
@property (nonatomic, strong) UILabel *languageInputTitle;
@property (nonatomic, strong) UILabel *languageInputNoteLable;

/// 配置完成
@property (nonatomic, strong) UIButton *completeBtn;
@end

@implementation ESSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self updateConstraints];
    [self networkAuthStatus];
    //[self notificatAlert];
}

- (void)updateConstraints {
    [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(84.0f);
        make.height.width.equalTo(@(128.0f));
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    [self.titleLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(45.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
        make.height.equalTo(@(33.0f));
    }];

    [self.uuidInputField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLable.mas_bottom).offset(10.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(43.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.uuidInputTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLable.mas_bottom).offset(10.0f);
        make.left.equalTo(self.uuidInputField.mas_right).offset(4.0f);
        make.height.equalTo(@(43.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.uuidInputNoteLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uuidInputField.mas_bottom).offset(9.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(18.0f));
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
    }];

    [self.uuidInputNoteLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uuidInputField.mas_bottom).offset(9.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(18.0f));
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
    }];

    [self.uuidInputNoteLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uuidInputField.mas_bottom).offset(9.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(18.0f));
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
    }];

    [self.countryDownListView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uuidInputNoteLable.mas_bottom).offset(kESViewDefaultMargin);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(42.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.countryInputTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.uuidInputNoteLable.mas_bottom).offset(kESViewDefaultMargin);
        make.left.equalTo(self.countryDownListView.mas_right).offset(9.0f);
        make.height.equalTo(@(43.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.countryInputNoteLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countryDownListView.mas_bottom).offset(10.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(18.0f));
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
    }];

    [self.languageDownListView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countryInputNoteLable.mas_bottom).offset(kESViewDefaultMargin);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(42.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.languageInputTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countryInputNoteLable.mas_bottom).offset(kESViewDefaultMargin);
        make.left.equalTo(self.countryDownListView.mas_right).offset(9.0f);
        make.height.equalTo(@(43.0f));
        make.width.equalTo(@(146.0f));
    }];

    [self.languageInputNoteLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.languageDownListView.mas_bottom).offset(10.0f);
        make.left.equalTo(self.view.mas_left).offset(32.0f);
        make.height.equalTo(@(18.0f));
        make.right.equalTo(self.view.mas_right).offset(-32.0f);
    }];

    [self.completeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).inset(32.0f + kBottomHeight);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@(45.0f));
        make.width.equalTo(@(320.0f));
    }];
}

- (UIImageView *)logoImageView {
    if (nil == _logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"aoBoxLogo"];
        [self.view addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UILabel *)titleLable {
    if (nil == _titleLable) {
        _titleLable = [UILabel new];
        _titleLable.numberOfLines = 1;
        _titleLable.textColor = ESColor.labelColor;
        _titleLable.font = [UIFont systemFontOfSize:24];
        _titleLable.text = @"空间专属标识";
        [self.view addSubview:_titleLable];
    }
    return _titleLable;
}

- (UITextField *)uuidInputField {
    if (nil == _uuidInputField) {
        _uuidInputField = [UITextField new];
        _uuidInputField.borderStyle = UITextBorderStyleLine;
        _uuidInputField.layer.borderColor = [UIColor grayColor].CGColor;
        [_uuidInputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _uuidInputField.layer.borderWidth = 1.0f;
        _uuidInputField.placeholder = @"UUID";
        [self.view addSubview:_uuidInputField];
    }
    return _uuidInputField;
}

- (UILabel *)uuidInputTitle {
    if (nil == _uuidInputTitle) {
        _uuidInputTitle = [UILabel new];
        _uuidInputTitle.numberOfLines = 1;
        _uuidInputTitle.textColor = ESColor.labelColor;
        _uuidInputTitle.font = [UIFont systemFontOfSize:30];
        _uuidInputTitle.text = @".e.space";
        [self.view addSubview:_uuidInputTitle];
    }
    return _uuidInputTitle;
}

- (UILabel *)uuidInputNoteLable {
    if (nil == _uuidInputNoteLable) {
        _uuidInputNoteLable = [UILabel new];
        _uuidInputNoteLable.numberOfLines = 1;
        _uuidInputNoteLable.textColor = ESColor.labelColor;
        _uuidInputNoteLable.font = [UIFont systemFontOfSize:13];
        _uuidInputNoteLable.text = @"用户自定义名称后面再设置";
        [self.view addSubview:_uuidInputNoteLable];
    }
    return _uuidInputNoteLable;
}

- (EBDropdownListView *)countryDownListView {
    if (nil == _countryDownListView) {
        EBDropdownListItem *item1 = [[EBDropdownListItem alloc] initWithItem:@"中国" itemName:@"中国"];
        EBDropdownListItem *item2 = [[EBDropdownListItem alloc] initWithItem:@"日本" itemName:@"日本"];
        EBDropdownListItem *item3 = [[EBDropdownListItem alloc] initWithItem:@"新加坡" itemName:@"新加坡"];
        EBDropdownListItem *item4 = [[EBDropdownListItem alloc] initWithItem:@"美国" itemName:@"美国"];
        // 弹出框向下
        _countryDownListView = [EBDropdownListView new];
        _countryDownListView.textColor = ESColor.labelColor;
        _countryDownListView.dataSource = @[item1, item2, item3, item4];
        _countryDownListView.selectedIndex = 0;
        [_countryDownListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
        [self.view addSubview:_countryDownListView];
        [_countryDownListView setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView){
        }];
    }
    return _countryDownListView;
}

- (UILabel *)countryInputTitle {
    if (nil == _countryInputTitle) {
        _countryInputTitle = [UILabel new];
        _countryInputTitle.numberOfLines = 1;
        _countryInputTitle.textColor = ESColor.labelColor;
        _countryInputTitle.font = [UIFont systemFontOfSize:24];
        _countryInputTitle.text = @"所属国家";
        [self.view addSubview:_countryInputTitle];
    }
    return _countryInputTitle;
}

- (UILabel *)countryInputNoteLable {
    if (nil == _countryInputNoteLable) {
        _countryInputNoteLable = [UILabel new];
        _countryInputNoteLable.numberOfLines = 1;
        _countryInputNoteLable.textColor = ESColor.labelColor;
        _countryInputNoteLable.font = [UIFont systemFontOfSize:13];
        _countryInputNoteLable.text = @"与绑定的手机号所属国家对应";
        [self.view addSubview:_countryInputNoteLable];
    }
    return _countryInputNoteLable;
}

/// 语言
- (EBDropdownListView *)languageDownListView {
    if (nil == _languageDownListView) {
        EBDropdownListItem *item1 = [[EBDropdownListItem alloc] initWithItem:@"随系统设置" itemName:@"随系统设置"];
        EBDropdownListItem *item2 = [[EBDropdownListItem alloc] initWithItem:@"中文" itemName:@"中文"];
        EBDropdownListItem *item3 = [[EBDropdownListItem alloc] initWithItem:@"英文" itemName:@"英文"];
        // 弹出框向下
        _languageDownListView = [EBDropdownListView new];
        [self.view addSubview:_languageDownListView];
        _languageDownListView.dataSource = @[item1, item2, item3];
        _languageDownListView.selectedIndex = 0;
        _languageDownListView.textColor = ESColor.labelColor;
        //        _languageDownListView.layer.borderColor = ESColor.labelColor.CGColor;
        [_languageDownListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
        [_languageDownListView setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView){
        }];
    }
    return _languageDownListView;
}

- (UILabel *)languageInputTitle {
    if (nil == _languageInputTitle) {
        _languageInputTitle = [UILabel new];
        _languageInputTitle.numberOfLines = 1;
        _languageInputTitle.textColor = ESColor.labelColor;
        _languageInputTitle.font = [UIFont systemFontOfSize:24];
        _languageInputTitle.text = @"选择语言";
        [self.view addSubview:_languageInputTitle];
    }
    return _languageInputTitle;
}

- (UILabel *)languageInputNoteLable {
    if (nil == _languageInputNoteLable) {
        _languageInputNoteLable = [UILabel new];
        _languageInputNoteLable.numberOfLines = 1;
        _languageInputNoteLable.textColor = ESColor.labelColor;
        _languageInputNoteLable.font = [UIFont systemFontOfSize:13];
        _languageInputNoteLable.text = @"与所属国家对应";
        [self.view addSubview:_languageInputNoteLable];
    }
    return _languageInputNoteLable;
}

- (UIButton *)completeBtn {
    if (nil == _completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_completeBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(actionForComplete:) forControlEvents:UIControlEventTouchUpInside];
        [_completeBtn setTitle:@"完成设置，进入空间" forState:UIControlStateNormal];
        //关键语句
        _completeBtn.backgroundColor = ESColor.systemBackgroundColor;
        [_completeBtn.layer setCornerRadius:3.0]; //设置矩圆角半径
        _completeBtn.userInteractionEnabled = NO;
        _completeBtn.layer.borderColor = [UIColor grayColor].CGColor;
        //设置边框宽度
        _completeBtn.layer.borderWidth = 1.0f;
        [self.view addSubview:_completeBtn];
    }
    return _completeBtn;
}

- (void)actionForComplete:(UIButton *)btn {
    [ESHomeCoordinator showHome];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.completeBtn.userInteractionEnabled = YES;
        self.completeBtn.backgroundColor = [UIColor blueColor];
    } else {
        self.completeBtn.backgroundColor = ESColor.systemBackgroundColor;
        self.completeBtn.userInteractionEnabled = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Network auth status
- (void)networkAuthStatus {
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        if (state == kCTCellularDataRestricted) {
            //拒绝
            [self networkSettingAlert];
        } else if (state == kCTCellularDataNotRestricted) {
            //允许
        } else {
            //未知
            [self unknownNetwork];
        }
    };
}

- (void)networkSettingAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您尚未授权“app”访问网络的权限，请前往设置开启网络授权" preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *_Nonnull action){

                                                          }]];

        [alertController addAction:[UIAlertAction actionWithTitle:@"去设置"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                                                          }]];

        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)unknownNetwork {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"未知网络" preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"确定")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action){
                                                          }]];

        [self presentViewController:alertController animated:YES completion:nil];
    });
}


@end
