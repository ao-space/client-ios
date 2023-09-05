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
//  ESV2PowerVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESV2PowerVC.h"
#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESCellModel.h"
#import "ESPowerCell.h"
#import "ESWebTryPageVC.h"
#import "ESV2PowerBulletVC.h"
#import "YCNavigationController.h"
#import "ESPushNewsSettingVC.h"

#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import <Masonry/Masonry.h>

@interface ESV2PowerVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIButton *settingButton;

@property (nonatomic, strong) ESV2PowerBulletVC *moreView;

@property (strong, nonatomic) NSMutableArray *dataArr;

@property (nonatomic, strong) ESCellModel *model;


@property (assign, nonatomic) int num;
@end

@implementation ESV2PowerVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
    self.num = 0;
    
}


- (void)initData {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.dataArr = [NSMutableArray array];
    
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"photo_access", @"照片");
        model.hasArrow = YES;
        model.imageName = @"zp";
        model.placeholderValue = NSLocalizedString(@"me_imageDes", @"允许App读取和写入照片库，用于照片、视频的上传和保存到本地，相册同步功能。");
        [self.dataArr addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title =  NSLocalizedString(@"camera", @"相机");
        model.hasArrow = YES;
        model.placeholderValue = NSLocalizedString(@"camera_content", @"允许App使用摄像头，用于拍摄后上传图片。");
        model.imageName = @"xj";
        [self.dataArr addObject:model];
    }
    
    [self initUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =NSLocalizedString(@"android_permission_manager", @"iOS权限管理");
}

- (void)initUI {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0.0f);
        make.left.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight);
        make.right.mas_equalTo(self.view).offset(0);
    }];
    
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight - 50);
        
    }];
    
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 84) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor =ESColor.systemBackgroundColor;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model = self.dataArr[indexPath.row];

    //设置字符串的字体
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    //设置字符串需要的空间大小，其中宽度是固定的，高度设置一个足够大的值，这里使用MAXFLOAT表示无穷大
    CGSize size = CGSizeMake(ScreenWidth-52-50, MAXFLOAT);
    //计算字符串需要的高度
    CGRect rect = [model.placeholderValue boundingRectWithSize:size
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil];
    //获取计算出来的高度值
    CGFloat height = CGRectGetHeight(rect);

    return 16 + 22 + height + 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESPowerCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESPowerCellID"];
    if (cell == nil) {
        cell = [[ESPowerCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESPowerCellID"];
    }
    if (self.dataArr.count > indexPath.row) {
        cell.model = self.dataArr[indexPath.row];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model = self.dataArr[indexPath.row];
    self.model = model;
    self.moreView.titleLabel.text = model.title;
    self.moreView.pointOutLabel.text = model.placeholderValue;
    self.moreView.powerTitle =  model.title;
    self.moreView.type = indexPath.row;
    self.moreView.pointOutLabel2.text = [NSString stringWithFormat:NSLocalizedString(@"Allow_hint", @"允许使用「%@」") ,model.title];
    self.moreView.hidden = NO;
    
}

- (ESV2PowerBulletVC *)moreView {
    if (!_moreView) {
        _moreView = [[ESV2PowerBulletVC alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _moreView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _moreView.hidden =YES;
        weakfy(self);
        _moreView.actionBlock = ^(id action) {
            strongfy(self);
            self.moreView.hidden = YES;
        };
        UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroudAction:)];
        [_moreView addGestureRecognizer:delectActionTapGesture];
        [self.view addSubview:_moreView];
    }
    return _moreView;
}

- (void)tapBackgroudAction:(UITapGestureRecognizer *)tapGes {
    _moreView.hidden =YES;
}


- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(0, 0, 50, 50);
        [_settingButton setTitle:NSLocalizedString(@"go_to_system_settings", @"前往系统设置") forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_settingButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_settingButton];
    }
    return _settingButton;
}

-(void)backAction{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
}

-(void)didBecomeActive{
    self.moreView.powerTitle = self.model.title;
}


@end

