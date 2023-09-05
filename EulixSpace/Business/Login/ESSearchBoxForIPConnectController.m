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
//  ESSearchBoxForIPConnectController.m
//  EulixSpace
//
//  Created by dazhou on 2023/3/22.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSearchBoxForIPConnectController.h"
#import "ESNetServiceBrowser.h"
#import "ESBoxIPModel.h"
#import <Lottie/LOTAnimationView.h>
#import "ESGradientButton.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESBoxCell.h"
#import "NSArray+ESTool.h"
#import "UILabel+ESTool.h"
#import "ESToast.h"
#import "ESAuthorizedLoginForBoxVC.h"
#import "ESCommonToolManager.h"
#import "ESLanIPInputController.h"

@interface ESSearchBoxForIPConnectController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ESNetServiceBrowser * serviceBrowser;
@property (nonatomic, strong) NSArray * searchResultList;
@property (nonatomic, strong) LOTAnimationView * animation;
@property (nonatomic, strong) ESGradientButton * reSearchBtn;
@property (nonatomic, strong) UIButton * ipInputBtn;
@property (nonatomic, strong) UIView * searchingHintView;
@property (nonatomic, strong) UIView * searchFaildHintView;

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) int countValue;

@property (nonatomic, strong) UITableView * tableView;
@end

@implementation ESSearchBoxForIPConnectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"login_title", @"登录");
    [self startSearchBox];
}

- (void)startSearchBox {
    self.searchingHintView.hidden = NO;
    self.searchFaildHintView.hidden = YES;
    self.reSearchBtn.hidden = YES;
    self.ipInputBtn.hidden = YES;
    self.countValue = 10;
    [self.animation play];
    [self createTimer];
    weakfy(self);
    [self.serviceBrowser startSearchAvailableBox];
    self.serviceBrowser.didFindService = ^(NSArray<ESNetServiceItem *> *serviceList) {
        strongfy(self);
        self.searchResultList = serviceList;
        [self showBoxList];
        ESDLog(@"[局域网IP直连] 搜索结果数量:%ld", serviceList.count);
    };
}

- (void)showBoxList {
    self.searchingHintView.hidden = YES;
    self.searchFaildHintView.hidden = YES;
    self.reSearchBtn.hidden = YES;
    self.ipInputBtn.hidden = YES;
    self.animation.hidden = YES;
    [self.tableView reloadData];
}

- (void)onSearchAgainBtn {
    [self startSearchBox];
}

- (void)onIPInputBtn {
    ESLanIPInputController * ctl = [[ESLanIPInputController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)createTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    weakfy(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        strongfy(self);
        self.countValue --;
        if (self.countValue <= 0) {
            [self stopTimer];
            return;
        }
    }];
    [self.timer fire];
}

- (void)stopTimer {
    [self.serviceBrowser stopSearch];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.searchResultList.count == 0) {
        [self showSearchFailedView];
    }
}

- (void)onLoginBox:(ESNetServiceItem *)item {
    if (item.webport <= 0) {
        [ESToast toastError:NSLocalizedString(@"Box OS lower, cannot login", @"")];
        return;
    }
    [self.serviceBrowser stopSearch];
    
    weakfy(self);
    NSString * url  = [[NSString alloc] initWithFormat:@"http://%@:%d/space/index.html#/qrLogin?language=%@&isOpensource=1",
                       item.ipv4,
                       item.webport,
                       [ESCommonToolManager isEnglish] ? @"en-US" : @"zh-CN"];
    ESAuthorizedLoginForBoxVC * ctl = [[ESAuthorizedLoginForBoxVC alloc] init];
    ctl.url = url;
    ctl.actionBlock = ^(id  _Nonnull action) {
        strongfy(self);
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(viewModelJump)]) {
                [self.navigationController popToViewController:obj animated:NO];
                self.tabBarController.selectedIndex = 0;
                *stop = YES;
            }
        }];
    };
    [self.navigationController pushViewController:ctl animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    NSString * text = NSLocalizedString(@"Please select a device to log in:", @"请选择要登录的设备：");
    UILabel * label = [UILabel createLabel:text font:ESFontPingFangMedium(14) color:@"#333333"];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(view).offset(26);
        make.trailing.mas_equalTo(view).offset(-26);
        make.top.mas_equalTo(view).offset(25);
        make.bottom.mas_equalTo(view).offset(-10);
    }];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESBoxCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESBoxCell"];
    ESNetServiceItem * item = [self.searchResultList getObject:indexPath.row];
    cell.data = item;
    weakfy(self);
    cell.onLoginBlock = ^(ESNetServiceItem * _Nonnull data) {
        strongfy(self);
        [self onLoginBox:data];
    };
    return cell;
}

- (void)showSearchFailedView {
    [self.animation stop];
    self.searchFaildHintView.hidden = NO;
    self.searchingHintView.hidden = YES;
    self.reSearchBtn.hidden = NO;
    self.ipInputBtn.hidden = NO;
}

- (void)dealloc {
    [self.serviceBrowser stopSearch];
}

- (ESGradientButton *)reSearchBtn {
    if (!_reSearchBtn) {
        _reSearchBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        _reSearchBtn.hidden = YES;
        [_reSearchBtn setCornerRadius:10];
        [_reSearchBtn setTitle:NSLocalizedString(@"Search Again", @"重新搜索") forState:UIControlStateNormal];
        _reSearchBtn.titleLabel.font = ESFontPingFangMedium(16);
        [_reSearchBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_reSearchBtn];
        [_reSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.view).offset(-kBottomHeight - 70);
            make.centerX.mas_equalTo(self.view);
        }];
        [_reSearchBtn addTarget:self action:@selector(onSearchAgainBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reSearchBtn;
}

- (LOTAnimationView *)animation {
    if (!_animation) {
        _animation = [LOTAnimationView animationNamed:@"scaning"];
        _animation.loopAnimation = YES;
        [self.view addSubview:_animation];
        
        [_animation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).inset(64);
            make.size.mas_equalTo(CGSizeMake(196, 196));
            make.centerX.mas_equalTo(self.view);
        }];
    }
    return _animation;
}

- (ESNetServiceBrowser *)serviceBrowser {
    if (!_serviceBrowser) {
        _serviceBrowser = [ESNetServiceBrowser new];
    }
    return _serviceBrowser;
}

- (UIView *)searchingHintView {
    if (!_searchingHintView) {
        UIView * view = [UIView new];
        [self.view addSubview:view];
        NSString * text = NSLocalizedString(@"Searching Device", @"正在搜索设备…");
        UILabel * label = [UILabel createLabel:text font:ESFontPingFangRegular(14) color:@"#337AFF"];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(view).offset(20);
            make.trailing.mas_equalTo(view).offset(-20);
            make.top.mas_equalTo(view);
        }];
        
        text = NSLocalizedString(@"Please connect your phone and device to the same network", @"请将手机与设备连接到同一个网络");
        UILabel * label1 = [UILabel createLabel:text font:ESFontPingFangRegular(14) color:@"#85899C"];
        label1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(view).offset(20);
            make.trailing.mas_equalTo(view).offset(-20);
            make.top.mas_equalTo(label.mas_bottom).offset(20);
            make.bottom.mas_equalTo(view);
        }];
        
        _searchingHintView = view;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.animation.mas_bottom).offset(20);
        }];
    }
    return _searchingHintView;
}

- (UIView *)searchFaildHintView {
    if (!_searchFaildHintView) {
        UIView * view = [UIView new];
        [self.view addSubview:view];
        NSString * text = NSLocalizedString(@"box_bind_not_found", @"未发现设备");
        UILabel * label = [UILabel createLabel:text font:ESFontPingFangMedium(18) color:@"#333333"];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(view).offset(20);
            make.trailing.mas_equalTo(view).offset(-20);
            make.top.mas_equalTo(view);
        }];
        
        text = NSLocalizedString(@"Check please", @"请检查：");
        UILabel * label1 = [UILabel createLabel:text font:ESFontPingFangMedium(16) color:@"#333333"];
        [view addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(view).offset(36);
            make.trailing.mas_equalTo(view).offset(-36);
            make.top.mas_equalTo(label.mas_bottom).offset(40);
        }];
        
        UIView * dot = [[UIView alloc] init];
        dot.layer.masksToBounds = YES;
        dot.layer.cornerRadius = 3;
        dot.backgroundColor = [UIColor es_colorWithHexString:@"#337AFF"];
        [view addSubview:dot];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(6);
            make.leading.mas_equalTo(view).offset(36);
            make.top.mas_equalTo(label1.mas_bottom).offset(28);
            make.bottom.mas_equalTo(view).offset(-20);
        }];
        
        text = NSLocalizedString(@"APP_APSPACE_SAME_LAN", @"手机与傲空间设备是否在同一局域网内");
        UILabel * label2 = [UILabel createLabel:text font:ESFontPingFangRegular(14) color:@"#333333"];
        [view addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(dot.mas_trailing).offset(8);
            make.top.mas_equalTo(label1.mas_bottom).offset(20);
            make.trailing.mas_equalTo(view).offset(-36);
        }];
        
        _searchFaildHintView = view;
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.animation.mas_bottom).offset(20);
        }];
    }
    return _searchFaildHintView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        if (@available(iOS 15.0, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESBoxCell class] forCellReuseIdentifier:@"ESBoxCell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    return _tableView;
}

- (UIButton *)ipInputBtn {
    if (!_ipInputBtn) {
        UIButton * btn = [[UIButton alloc] init];
        btn.hidden = YES;
        [btn setTitle:NSLocalizedString(@"LAN_IPinput", @"局域网 IP 输入") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#85899C"] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangMedium(16);
        _ipInputBtn = btn;
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(44);
            make.bottom.mas_equalTo(self.view).offset(-kBottomHeight - 20);
            make.centerX.mas_equalTo(self.view);
        }];
        [btn addTarget:self action:@selector(onIPInputBtn) forControlEvents:UIControlEventTouchUpInside];
    
    }
    return _ipInputBtn;
}
@end
