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
//  ESBoxListViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxListViewController.h"
#import "ESAuthorizedLoginVC.h"
#import "ESBoxBindViewController.h"
#import "ESBoxListCell.h"
#import "ESBoxListItem.h"
#import "ESBoxManager.h"
#import "ESDebugMacro.h"
#import "ESEmptyView.h"
#import "ESGradientButton.h"
#import "ESCommonToolManager.h"
#import "ESHomeCoordinator.h"
#import "ESQRCodeScanViewController.h"
#import "ESToast.h"
#import "MJRefresh.h"
#import "ESRSACenter.h"
#import "NSString+ESTool.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ESSpaceGatewayQRCodeScanningServiceApi.h"
#import "ESAuthorizedTerminalLoginConfirmInfo.h"
#import "ESSpaceGatewayQRCodeScanningServiceApi.h"
#import "ESSpaceGatewayAdminAuthingServiceApi.h"
#import "ESAccountServiceApi.h"
#import "ESApiClient.h"
#import "ESPushWaitView.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import "ESAutoErrorView.h"
#import "ESAuthorizedLoginVC.h"
#import "ESGatewayManager.h"
#import "ESCache.h"
#import "ESMJHeader.h"
#import "ESGradientButton.h"
#import "ESBoxBindViewModel.h"
#import "ESDeviceOfflineController.h"
#import "ESLocalNetworking.h"
#import "UIView+Status.h"
#import "ESMJHeader.h"
#import "ESBoxItemDeleteConfirmVC.h"
#import "ESDiskInitStartPage.h"
#import "ESBoxBindViewModel.h"
#import "ESDiskInitProgressPage.h"
#import "ESBoxBindViewModel.h"
#import "ESTrailOnLineManager.h"
#import "ESSapceWelcomeVC.h"
#import "ESDiskEmptyPage.h"
#import "ESApiClient+ESHost.h"

#ifdef ES8ackD00r
#import "ESSetting8ackd00rViewController.h"

#import "NSObject+LocalAuthentication.h"
#endif

typedef NS_ENUM(NSUInteger, ESBoxListSection) {
    ESBoxListSectionDefault,
};


@interface ESBoxListViewController ()<ESSecuritySettingJumpDelegate, ESBoxBindViewModelDelegate>

@property (nonatomic, strong) ESGradientButton *bindBox;

@property (nonatomic, assign) BOOL offline;

@property (nonatomic, strong) ESPushWaitView *waitView;

@property (nonatomic, strong) ESAutoErrorView *errorView;

@property (nonatomic, assign) BOOL isPushWait;

@property (nonatomic, assign) BOOL isDomainRewriteTimeout;

@property (nonatomic, strong) UILabel *headerHintLabel;

@property (nonatomic, strong) ESBoxBindViewModel *viewModel;
@property (nonatomic, strong) ESBoxItem *selectedBoxItem;

@end

static CGFloat const ESHeaderHintLabelHeight = 20.0f;
static CGFloat const ESHeaderHintLabelBottomMargin = 10.0f;

@implementation ESBoxListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    self.tabBarController.tabBar.hidden = YES;
}
/// 设备列表
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_LOGIN_TITLE;

    self.cellClass = [ESBoxListCell class];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.tableView.backgroundColor = ESColor.systemBackgroundColor;
    self.section = @[@(ESBoxListSectionDefault)];
    
    if (!self.viewModel) {
        self.viewModel = [ESBoxBindViewModel viewModelWithDelegate:self];
        self.viewModel.mode = ESBoxBindModeBluetoothAndWiredConnection;
    }
    [self initLayout];
    
    self.isDomainRewriteTimeout= NO;
    
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    weakfy(self);

    self.tableView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        [weak_self loadData];

    }];
    if (!ESBoxManager.activeBox) {
        ESBoxManager.manager.justLaunch = NO;
        self.offline = YES;
        UIApplication.sharedApplication.applicationSupportsShakeToEdit = YES;
    }
    
    self.tableView.tableFooterView = self.footerView;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createMemberNSNotification:)
                                                 name:@"createMemberNSNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(domainRewriteTimeout:)
                                                 name:@"domainRewriteTimeout"
                                               object:nil];
  
    if([self.sourceVC isEqual:@"delectMember"]){
        ESDLog(@"[BoxList] delectMember");
        self.navigationItem.hidesBackButton = YES;
        self.showBackBt = NO;

        [ESBoxManager revoke:ESBoxManager.activeBox];
        [weak_self loadData];
        return;
    }
    
    if (self.showTrailUnvalied) {
        [self showTrailUnvaildDialog];
        self.navigationItem.hidesBackButton = YES;
        self.showBackBt = NO;
    }
}

- (UIView *)footerView {
    UIView *footerView = [UIView new];
    footerView.frame = CGRectMake(0, 0, 300, 100);
    footerView.backgroundColor = [ESColor clearColor];
    
    UIView *footerContainerView = [UIView new];
    footerContainerView.backgroundColor = [ESColor colorWithHex:0xF5F6FA];
    footerContainerView.clipsToBounds = YES;
    footerContainerView.layer.cornerRadius = 10.0f;
    
    [footerView addSubview:footerContainerView];
    [footerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(footerView);
        make.left.right.mas_equalTo(footerView).inset(0.0f);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFootView:)];
    [footerContainerView addGestureRecognizer:tapGes];
    
    UIButton  *addBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [addBtn setImage:[UIImage imageNamed:@"add_box"] forState:UIControlStateNormal];
    [footerContainerView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
        make.centerY.mas_equalTo(footerContainerView);
        make.left.mas_equalTo(footerContainerView.mas_left).inset(20);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = ESColor.labelColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.numberOfLines = 0;
    titleLabel.font = ESFontPingFangMedium(18);
    titleLabel.text = NSLocalizedString(@"box_login_more", @"登录更多空间");
    [footerContainerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(footerContainerView);
        make.left.mas_equalTo(addBtn.mas_right).inset(20);
    }];
    return footerView;
}

- (void)tapFootView:(UITapGestureRecognizer *)ges {
    [self loginMoreBox];
}

- (void)dealloc {
    ESDLog(@"[BoxList] delloc");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (ESBoxManager.manager.justLaunch == NO) {
        return;
    }
    //just Launch
    if (!ESBoxManager.activeBox) {
        return;
    }
 
    [self updateActiveBoxOnlineState];
}

- (void)updateActiveBoxOnlineState {
    ESBoxItem * box = ESBoxManager.activeBox;
    if (box.diskInitStatus != ESDiskInitStatusNormal
        && [box hasInnerDiskSupport]) {
        return;
    }
    
    if (ESBoxManager.activeBox.boxType == ESBoxTypeAuth) {
        ESDLog(@"[BoxList] boxType is Auth");
        ESToast.waiting(TEXT_WAIT).delay(5).showFrom(self.view.window);
        [self autoLoginFirst:ESBoxManager.activeBox completed:^{
            [ESToast dismiss];
        }];
        return;
    }
    
    ESDLog(@"[BoxList] boxType is Not Auth");
    [self getLocalAuthentication:^(BOOL success, NSError * _Nullable error) {
        if(success){
            [ESHomeCoordinator showHome];
        }
    }boxUUID:@"" typeInt:4];
}

- (void)loadData {
    [self.tableView.mj_header endRefreshing];
    self.tabBarController.tabBar.hidden = YES;

    ESBoxItem * curBox = ESBoxManager.activeBox;
    self.dataSource[@(ESBoxListSectionDefault)] = [ESBoxManager.bindBoxArray yc_mapWithBlock:^id(NSUInteger idx, ESBoxItem *obj) {
        ESBoxListItem *item = [ESBoxListItem new];
        item.height = 105;
        item.title = obj.spaceName.length > 0  ? obj.spaceName : obj.name;
        item.inuse = [obj isEqual:ESBoxManager.activeBox];
        item.category = TEXT_LOGIN_TITLE;
        
        item.data = obj;
        
        ESBoxIPModel * ipModel = [curBox.boxIPResp getConnectedBoxIP];
        ESBoxItem * tmpBox = obj;
        if ([curBox isEqual:obj] && ipModel) {
            tmpBox = obj.copy;
            tmpBox.info.userDomain = [ipModel getIPDomain];
        }
        [ESBoxManager loadOnlineState:tmpBox
                           completion:^(BOOL offline) {
            item.online = !offline;
            [self.tableView reloadData];
        }];
        
        return item;
    }];
    if (self.dataSource[@(ESBoxListSectionDefault)].count <= 0) {
        [ESBoxManager.manager cleanBoxsInfo];
        
        self.showBackBt = NO;
    }
    [self.tableView reloadData];
}

- (void)initLayout {
    [self.bindBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).inset(kBottomHeight + kESViewDefaultMargin);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).inset(kBottomHeight + kESViewDefaultMargin + 22 + 20 + 44 + 20);
        make.top.mas_equalTo(self.view).offset( [ESCommonToolManager isEnglish] ? (ESHeaderHintLabelHeight + 2 * ESHeaderHintLabelBottomMargin + 14) : (ESHeaderHintLabelHeight + 2 * ESHeaderHintLabelBottomMargin));
        make.left.right.mas_equalTo(self.view).inset(10.0f);
    }];
    
    [self.view addSubview:self.headerHintLabel];
    [self.headerHintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.tableView.mas_top).inset(ESHeaderHintLabelBottomMargin);
        make.left.right.mas_equalTo(self.view).inset(26.0f);
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? (ESHeaderHintLabelHeight + 14) :  ESHeaderHintLabelHeight);
    }];
}

- (void)loginMoreBox {
    //登录更多空间    basic.click.loginMore
    ESAuthorizedLoginVC *next = [[ESAuthorizedLoginVC alloc] init];
    weakfy(self)
    next.actionBlock = ^(id action) {
        strongfy(self)
        self.tabBarController.selectedIndex = 0;
    };
    
    UINavigationController *navi = self.navigationController ?: [self getCurrentVC].navigationController;
    [navi pushViewController:next animated:YES];
}

- (void)bind {
    //绑定设备    basic.click.bindDevice
    ESQRCodeScanViewController *next = [ESQRCodeScanViewController new];
    next.action = ESQRCodeScanActionBoxUrl;
    weakfy(self)
    next.callback = ^(NSString *value) {
        strongfy(self)
        NSString * urlStr = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSURLComponents *components = [NSURLComponents componentsWithString:urlStr.stringByRemovingPercentEncoding];
        __block NSString *btid;
        __block NSString *sn;
        __block NSString *realSn;
        __block NSString *ipaddr;
        __block NSString *port;
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                            NSUInteger idx,
                                                            BOOL *_Nonnull stop) {
            if ([obj.name isEqualToString:@"sn"]) {
                sn = obj.value;
            }else if ([obj.name isEqualToString:@"realSn"]) {
                realSn = obj.value;
            }else if ([obj.name isEqualToString:@"btid"]) {
                btid = obj.value;
            } else if ([obj.name isEqualToString:@"ipaddr"]) {
                ipaddr = obj.value;
            } else if ([obj.name isEqualToString:@"port"]) {
                port = obj.value;
            }
            
        }];
        ESDLog(@"[Bind] start with uuid : {%@:%@ - %@ -%@}", ipaddr, port, btid, sn);
        //内部不区分btid， sn、  用于展示逻辑
        ESBoxBindViewController *next = [ESBoxBindViewController new];
        if (btid.length > 0) {
            next.btid = btid;
        }
        
        if (sn.length > 0) {
            next.btid = realSn;
            next.sn = sn;
        }
        
        if (ipaddr.length > 0 && port.length > 0) {
            //走有线模拟器mode
            ESNetServiceItem *item = [[ESNetServiceItem alloc] initWithName:@"" ipv4:ipaddr port:[port intValue]];
            next.netServiceItem = item;
        }
        ESPerformBlockOnMainThreadAfterDelay(0.5, ^{
            [self.navigationController pushViewController:next animated:YES];
        });
    };
    [self.navigationController pushViewController:next animated:YES];
}

- (void)deleteSelectBoxIndexPath:(NSIndexPath *)indexPath {
    NSArray *list = self.dataSource[@(ESBoxListSectionDefault)];
    if (indexPath.row >= list.count) {
        return;
    }
    
    ESBoxListItem *item = list[indexPath.row];
    [ESBoxManager revoke:item.data];
}

- (void)startBoxSearch:(ESBoxItem *)box {
    [self.viewModel searchWithUniqueId:box.btid];
    self.selectedBoxItem = box;
    [self.view showLoading:YES];
}

- (void)viewModelOnInit:(ESBoxStatusItem *)boxStatus {
    
}

- (void)viewModelOnSpaceCheckReady:(ESSpaceReadyCheckResp *)response {
    ESDLog(@"[系统启动] 检测磁盘是否初始化结果:%@", response);
    
    if (response && [response.code isEqualToString:@"AG-200"]) {
        if (response.results.missingMainStorage) {
            // 主存储缺失，直接显示 无法启动 页面
            [self.view showLoading:NO];
            ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
            self.viewModel.paringBoxItem = self.selectedBoxItem;
            ctl.viewModel = self.viewModel;
            [self.navigationController pushViewController:ctl animated:YES];
            return;
        } else if (response.results.diskInitialCode == ESDiskInitStatusFormatting
                   || response.results.diskInitialCode == ESDiskInitStatusSynchronizingData) {
            // 正在格式化 或 正在数据同步
            [self.viewModel sendDiskRecognition];
        } else if (response.results.diskInitialCode == ESDiskInitStatusNormal) {
            [self.view showLoading:NO];

            ESBoxItem * box = self.selectedBoxItem;
            box.diskInitStatus = ESDiskInitStatusNormal;
            [[ESBoxManager manager] saveBox:box];
            
            ESSapceWelcomeVC *next = [ESSapceWelcomeVC new];
            next.viewModel = self.viewModel;
            next.viewModel.paringBoxItem = self.selectedBoxItem;
            [self.navigationController pushViewController:next animated:YES];
            return;
        } else {
            [self.view showLoading:NO];

            ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
            self.viewModel.paringBoxItem = self.selectedBoxItem;
            ctl.viewModel = self.viewModel;
            [self.navigationController pushViewController:ctl animated:YES];
            return;
        }
        
        return;
    }
}

- (void)viewModelDiskRecognition:(ESDiskRecognitionResp *)response {
    [self.view showLoading:NO];
    if ([response isOK]) {
        if (self.viewModel.supportNewBindProcess) {
            if (self.viewModel.diskInitialCode == ESDiskInitStatusNormal) {
                ESBoxItem * box = self.selectedBoxItem;
                box.diskInitStatus = ESDiskInitStatusNormal;
                [[ESBoxManager manager] saveBox:box];
                
                ESSapceWelcomeVC *next = [ESSapceWelcomeVC new];
                next.viewModel = self.viewModel;
                next.viewModel.paringBoxItem = self.selectedBoxItem;
                [self.navigationController pushViewController:next animated:YES];
                return;
            } else if (self.viewModel.diskInitialCode == ESDiskInitStatusFormatting
                       || self.viewModel.diskInitialCode == ESDiskInitStatusSynchronizingData) {
                ESDiskInitProgressPage * ctl = [[ESDiskInitProgressPage alloc] init];
                ctl.status = ESDeviceStartupStatusDiskIniting;
                ctl.viewModel = self.viewModel;
                ctl.diskListModel = response.results;
                [self.navigationController pushViewController:ctl animated:NO];
            } else {
                ESDiskListModel *diskModel = response.results;
                // 空磁盘
                if ([diskModel hasDisk:ESDiskStorage_Disk1] == NO &&
                    [diskModel hasDisk:ESDiskStorage_Disk2] == NO &&
                    [diskModel hasDisk:ESDiskStorage_SSD] == NO) {
                    ESDiskEmptyPage * ctl = [[ESDiskEmptyPage alloc] init];
                    ctl.viewModel = self.viewModel;
                    ctl.diskListModel = response.results;
                    [self.navigationController pushViewController:ctl animated:NO];
                    return;
                }
                
                ESDiskInitStartPage * ctl = [[ESDiskInitStartPage alloc] init];
                ctl.viewModel = self.viewModel;
                ctl.viewModel.paringBoxItem = self.selectedBoxItem;
                ctl.diskListModel = response.results;
                [self.navigationController pushViewController:ctl animated:NO];
            }
            return;
        }
    }
}
    
- (void)action:(id)action atIndexPath:(NSIndexPath *)indexPath {
    ESBoxListItem *actionBoxItem = [self objectAtIndexPath:indexPath];
    
    ESBoxItem * box = actionBoxItem.data;
    
    NSArray *array = self.dataSource[@(ESBoxListSectionDefault)];
    ESBoxListItem *item = array[indexPath.row];
    ESDLog(@"[action] ESBoxListItem:%@", item.data.boxUUID);
    
    if (!item.online &&  ESBoxManager.activeBox.boxType != ESBoxTypePairing  && self.isDomainRewriteTimeout) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录失败" message:@"登录空间失败，管理员将空间平台域名切换到新的地址，请联系管理员重新邀请后再使用。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"删除登录记录"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action){
            [ESBoxManager revoke:item.data];
        }];
        //2.2 取消按钮
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action) {
    
        }];
        [alert addAction:cancel];
        [alert addAction:conform];
        //4.显示弹框
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (item.data.boxType == ESBoxTypeAuth) {
        [self autoLogin:item indexPath:indexPath];
        return;
    }
    
    if ([ESBoxManager.activeBox isEqual:item.data] && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (item.data.showTrailUnvalied) {
        [self showTrailUnvaildDialog:item.data];
        return;
    }
    
    //盒子无效不能触发离线使用
    if (!item.online && self.showTrailUnvalied == NO) {
        [ESDeviceOfflineController showDeviceOfflineHintView:self box:item.data];
        return;
    }
    
    if (!item.online &&
        self.showTrailUnvalied &&
        [item.data.aoid isEqualToString:ESBoxManager.activeBox.aoid]) {
        [self showTrailUnvaildDialog];
        return;
    }
    if (!item.online &&
        [[ESTrailOnLineManager shareInstance].cacheInvaliedUserDomainList containsObject:ESSafeString(item.data.uniqueKey)]) {
        [self showTrailUnvaildDialog];
        return;
    }
    
    NSDictionary *boxInfo = [ESBoxManager cacheInfoForBox:item.data];
    ESDLog(@"[action] ESBoxListItem - boxInfo:%@", boxInfo);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"loopUrlChangeNSNotification" object: boxInfo[@"userDomain"]];
   
    weakfy(self)
    [self.view showLoading:YES];
    [self getLocalAuthentication:^(BOOL success, NSError * _Nullable error) {
        [self.view showLoading:NO];

        strongfy(self)
        if(success){
            [self checkToken:item indexPath:indexPath];
        }
    } boxUUID:item.data.boxUUID typeInt:item.data.boxType];
    return;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
#ifdef ES8ackD00r
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //振动效果 需要#import <AudioToolbox/AudioToolbox.h>
        ESSetting8ackd00rViewController *next = [ESSetting8ackd00rViewController new];
        YCNavigationController *navi = [[YCNavigationController alloc] initWithRootViewController:next];
        [self presentViewController:navi animated:YES completion:nil];
#endif
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell<YCActionCallbackProtocol> *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if (cell.tag > 0) {
        return;
    }
    cell.tag = 1;
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeTranslation(0, 46);
    
    NSTimeInterval delay = 0.02 + indexPath.row * 0.03;
    [UIView animateWithDuration:0.18 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        cell.alpha = 1;
        cell.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Lazy Load

- (ESGradientButton *)bindBox {
    if (!_bindBox) {
        _bindBox = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_bindBox setCornerRadius:10];
        [_bindBox setTitle:TEXT_BOX_BIND forState:UIControlStateNormal];
        _bindBox.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_bindBox setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_bindBox];
        [_bindBox addTarget:self action:@selector(bind) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBox;
}

- (UILabel *)headerHintLabel {
    if (!_headerHintLabel) {
        _headerHintLabel = [[UILabel alloc] init];
        _headerHintLabel.textColor = ESColor.secondaryLabelColor;
        _headerHintLabel.textAlignment = NSTextAlignmentLeft;
        _headerHintLabel.numberOfLines = 0;
        _headerHintLabel.font = ESFontPingFangRegular(12);
        _headerHintLabel.text = NSLocalizedString(@"binding_clicktip", @"提示： 点击切换空间，左滑清除本地空间信息。");
    }
    return _headerHintLabel;
}

- (void)createMemberNSNotification:(NSNotification *)notification {
    [ESHomeCoordinator showHome];
}

- (void)domainRewriteTimeout:(NSNotification *)notification {
    self.isDomainRewriteTimeout = YES;
}

-(void)autoLoginFirst:(ESBoxItem *)box completed:(void (^)(void))completed {
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString * userDomain = [NSString stringWithFormat:@"https://%@", dic[@"userDomain"]];
    
    ESDLog(@"[autoLoginFirst box lanHost: %@] userDomain:%@", box.localHost, userDomain);

    if (box != nil &&
        box.supportNewBindProcess &&
        box.enableInternetAccess == NO) {
        userDomain = box.localHost;
        ESDLog(@"[autoLoginFirst.localHost] lanHost:%@", userDomain);
    }
    
    ESBoxIPModel * ipModel = [box.boxIPResp getConnectedBoxIP];
    // 如果点击的是正在使用的盒子，且盒子是 IP 连通的，则通过 IP 去检测 token
    if (ipModel && [box isEqual:ESBoxManager.activeBox]) {
        userDomain = [ipModel getIPDomain];
    }
    
    NSURL *requesetUrl = [NSURL URLWithString:userDomain];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    
    ESSpaceGatewayQRCodeScanningServiceApi *api =  [[ESSpaceGatewayQRCodeScanningServiceApi alloc] initWithApiClient:client];
    api.apiClient.boxItem = box;
    
    ESDLog(@"[BoxList] autoLoginFirst url:%@", api.apiClient.baseURL);

    ESRSAPair *pair = [ESRSACenter boxPair:ESBoxManager.activeBox.boxUUID];
    ESAuthorizedTerminalLoginInfo *info = [ESAuthorizedTerminalLoginInfo new];
    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
    info.refreshToken = box.authToken.refreshToken;
    info.tmpEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
    [api spaceV1ApiAuthAutoLoginPollPostWithBody:info completionHandler:^(ESResponseBaseCreateTokenResult *output, NSError *error) {
        if (completed) {
            completed();
        }
        if ([output.code isEqual:@"GW-200"]) {
            [ESBoxManager onActive:box];
            [ESHomeCoordinator showHome];
            [self loadData];
        }
    }];
}

-(void)autoLogin:(ESBoxListItem *)item indexPath:(NSIndexPath *)indexPath{
    [self.view showLoading:YES];
    
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:item.data];
    NSString * userDomain = [NSString stringWithFormat:@"https://%@", dic[@"userDomain"]];
    
    ESDLog(@"[autoLogin box lanHost: %@] userDomain:%@", item.data.localHost, userDomain);

    if (item.data != nil &&
        item.data.enableInternetAccess == NO &&
        item.data.localHost.length > 0) {
        userDomain = item.data.localHost;
        ESDLog(@"[autoLogin.localHost] lanHost:%@", userDomain);
    }
    
    ESBoxIPModel * ipModel = [item.data.boxIPResp getConnectedBoxIP];
    // 如果点击的是正在使用的盒子，且盒子是 IP 连通的，则通过 IP 去检测 token
    if (ipModel && [item.data isEqual:ESBoxManager.activeBox]) {
        userDomain = [ipModel getIPDomain];
    }
    
    NSURL *requesetUrl = [NSURL URLWithString:userDomain];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];
    
    ESSpaceGatewayQRCodeScanningServiceApi * api = [[ESSpaceGatewayQRCodeScanningServiceApi alloc] initWithApiClient:client];
    api.apiClient.boxItem = item.data;

    ESDLog(@"[BoxList] autoLogin url:%@", api.apiClient.baseURL);

    ESAuthorizedTerminalLoginInfo *info =  [ESAuthorizedTerminalLoginInfo new];
    info.refreshToken = item.data.authToken.refreshToken;
    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
    ESRSAPair *pair = [ESRSACenter boxPair:item.data.boxUUID];
    self.isPushWait = YES;
    self.errorView.hidden = YES;
    self.errorView.item = item;
    
    info.tmpEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
    [api spaceV1ApiAuthAutoLoginPostWithBody:info
                           completionHandler:^(ESResponseBaseCreateTokenResult *output, NSError *error) {
        [self.view showLoading:NO];

        if (error != nil) {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            return;
        }
        if(!error){
            if ([output.code isEqual:@"GW-200"]) {
                [ESBoxManager onActive:item.data];
                [self loadData];
                
                if (self.navigationController.viewControllers.count > 0) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [ESHomeCoordinator showHome];
                }else{
                    [ESHomeCoordinator showHome];
                }
            }else if([output.code isEqual:@"GW-4046"]){
                self.waitView.hidden = YES;
                [self loginMoreBox];
            }
            else if([output.code isEqual:@"GW-4045"]){
                self.errorView.hidden = NO;
            }
            else if([output.code isEqual:@"GW-4044"]){
                
                if(!self.waitView){
                    self.waitView = [[ESPushWaitView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
                    NSDictionary *dic = [ESBoxManager cacheInfoForBox:item.data];
                    NSString *userDomain = dic[@"userDomain"];
                    self.waitView.aoid = dic[@"aoId"];
                    self.waitView.clientUUID = ESBoxManager.clientUUID;
                    self.waitView.nameStr = dic[@"personalName"];
                    self.waitView.domainStr = userDomain;
                    self.waitView.imagePath = dic[@"imagePath"];
                    self.waitView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
                    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
                    [window addSubview:self.waitView];
                    
                    weakfy(self);
                    self.waitView.actionBlock =  ^(NSNumber *action) {
                        strongfy(self);
                        self.isPushWait = NO;
                    };
                }else{
                    self.waitView.hidden = NO;
                }
                if(self.waitView.hidden == NO){
                    [self runloop:item indexPath:indexPath];
                }
            }
        }
    }];
}
-(void)runloop:(ESBoxListItem *)item indexPath:(NSIndexPath *)indexPath{
    if (!self.isPushWait) {
        return;
    }
    ESSpaceGatewayQRCodeScanningServiceApi *api =  [ESSpaceGatewayQRCodeScanningServiceApi new];
    ESRSAPair *pair = [ESRSACenter boxPair:ESBoxManager.activeBox.boxUUID];
    ESAuthorizedTerminalLoginInfo *info = [ESAuthorizedTerminalLoginInfo new];
    NSString *arcRandom16Str = [ESCommonToolManager arcRandom16Str];
    info.refreshToken = item.data.authToken.refreshToken;
    info.tmpEncryptedSecret = [pair publicEncrypt:arcRandom16Str];
    weakfy(self)
    [api spaceV1ApiAuthAutoLoginPollPostWithBody:info completionHandler:^(ESResponseBaseCreateTokenResult *output, NSError *error) {
        strongfy(self)
        ESDLog(@"[ESSpaceGatewayQRCodeScanningServiceApi] output:%@",output);
        if ([output.code isEqual:@"GW-200"]) {
            self.waitView.hidden = YES;
            [ESBoxManager onActive:item.data];
            [ESHomeCoordinator showHome];
            [self loadData];
        }else if([output.code isEqual:@"GW-4046"]){
            self.waitView.hidden = YES;
            [self loginMoreBox];
        }
        else if([output.code isEqual:@"GW-4044"]){
            if(self.waitView.hidden == NO){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self runloop:item indexPath:indexPath];
                });
            }
        }
        if(error){
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
     
    }];
}


- (ESAutoErrorView *)errorView {
    if (!_errorView) {
        _errorView = [[ESAutoErrorView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _errorView.hidden = YES;
        _errorView.tag = 500102;
        weakfy(self);
        _errorView.actionBlock = ^(ESBoxListItem *item) {
            strongfy(self);
            [self loginMoreBox];
            [[ESBoxManager manager] revokePush:item.data];
        };
        
        _errorView.actionCompleBlock = ^(ESBoxListItem *item) {
            strongfy(self);
            [[ESBoxManager manager] revokePush:item.data];
            [self loadData];
            [self.tableView reloadData];
        };
        
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        [window addSubview:_errorView];
    }
    return _errorView;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    ///下文中有分析
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

-(void)checkToken:(ESBoxListItem *)item indexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:item.data];
    NSString * userDomain = [NSString stringWithFormat:@"https://%@", dic[@"userDomain"]];
    ESDLog(@"[checkToken box lanHost: %@] userDomain:%@", item.data.localHost, userDomain);

    if (item.data != nil &&
        item.data.localHost.length > 0 &&
        item.data.enableInternetAccess == NO) {
        userDomain = item.data.localHost;
        ESDLog(@"[checkToken.localHost] lanHost:%@", userDomain);
    }

    ESBoxIPModel * ipModel = [item.data.boxIPResp getConnectedBoxIP];
    // 如果点击的是正在使用的盒子，且盒子是 IP 连通的，则通过 IP 去检测 token
    if (ipModel && [item.data isEqual:ESBoxManager.activeBox]) {
        userDomain = [ipModel getIPDomain];
    }

    NSURL *requesetUrl = [NSURL URLWithString:userDomain];
    ESApiClient *client = [[ESApiClient alloc] initWithBaseURL:requesetUrl];

    ESSpaceGatewayAdminAuthingServiceApi * api = [[ESSpaceGatewayAdminAuthingServiceApi alloc] initWithApiClient:client];
    ESApiClient *apiClient = api.apiClient;
    apiClient.boxItem = item.data;
    
    ESDLog(@"[BoxList] checkToken url:%@", api.apiClient.baseURL);
    [apiClient.configuration.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        [api setDefaultHeaderValue:obj forKey:key];
    }];
    ESCreateTokenInfo *body = [ESCreateTokenInfo new];
    ESRSAPair *pair = [ESRSACenter boxPair:item.data.boxUUID];
    body.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
    body.encryptedAuthKey = [pair publicEncrypt:item.data.info.authKey];
    
    [self.view showLoading:YES];
    [api spaceV1ApiGatewayAuthTokenCreatePostWithBody:body
                                    completionHandler:^(ESCreateTokenResult *output, NSError *error) {
        [self.view showLoading:NO];
        NSDictionary *dict = [[[NSString alloc] initWithData:error.userInfo[@"ESResponseObject"] encoding:NSUTF8StringEncoding] toJson];
        NSString *codeStr = dict[@"code"];
        if(codeStr.length > 0){
            if([codeStr isEqual:@"GW-4012"]){
                [self loadData];
                return;
            }
            if([codeStr isEqual:@"GW-4011"]){
                [ESToast toastError:NSLocalizedString(@"Authorization_Error", @"授权出错")];
                return;
            }
        } else if (error == nil) {
            BOOL noBoxBefore = !ESBoxManager.activeBox || self.offline;
            [ESBoxManager onActive:item.data];
            if (noBoxBefore) {
                [ESHomeCoordinator showHome];
            }
            if (indexPath.row == 0) {
                if (self.navigationController.viewControllers.count > 1) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [ESHomeCoordinator showHome];
                }
                return;
            }
            if(item.online){
                [ESHomeCoordinator showHome];
                [NSNotificationCenter.defaultCenter postNotificationName:@"switchBoxNSNotification" object:nil];
                [ESHomeCoordinator showHome];
            }
        } else if (error) {
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

- (int)viewModelJump {
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //只要实现这个方法，就实现了默认滑动删除！！！！！
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteSelectIndexPath:indexPath];
    }
}

- (void)deleteSelectIndexPath:(NSIndexPath *)indexPath {
    NSArray *list = self.dataSource[@(ESBoxListSectionDefault)];
    if (indexPath.row >= list.count) {
        return;
    }
    ESBoxListItem *item = list[indexPath.row];
    ESBoxItemDeleteConfirmVC *vc = [[ESBoxItemDeleteConfirmVC alloc] init];
    vc.clearBlock = ^() {
        [ESBoxManager revoke:item.data];
        [self loadData];
        [self.tableView reloadData];
    };
    vc.boxItem = item.data;
    [vc show];
    return;
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                  title:@"清除"
                                                                                handler:^(UIContextualAction * _Nonnull action,
                                                                                          __kindof UIView * _Nonnull sourceView,
                                                                                          void (^ _Nonnull completionHandler)(BOOL)) {
        [self deleteSelectIndexPath:indexPath];
        completionHandler (YES);
    }];
    //2.给滑动按钮添加背景、图片 #337AFF
    deleteRowAction.backgroundColor = [UIColor clearColor];  // [UIColor colorWithRed:51/255.0 green:122/255.0 blue:255/255.0 alpha:1];
    //3.返回滑动按钮
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupSlideBtnWithEditingIndexPath:indexPath];
    });
}

- (void)setupSlideBtnWithEditingIndexPath:(NSIndexPath *)editingIndexPath {
    // 判断系统是否是 iOS13 及以上版本
    if(@available(iOS 13.0, *)) {
        for(UIView *subView in self.tableView.subviews) {
            if([subView isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] && [subView.subviews count] >= 1) {
                UIView *remarkContentView = subView.subviews.firstObject;
                [self setupRowActionView:remarkContentView];
            }
        }
        return;
    }
    
    // 判断系统是否是 iOS11 及以上版本
    for(UIView * subView in self.tableView.subviews) {
        if([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subView.subviews count] >= 1) {
            UIView *remarkContentView = subView;
            [self setupRowActionView:remarkContentView];
        }
    }
    return;
}

- (void)setupRowActionView:(UIView *)rowActionView {
    UIButton *button = rowActionView.subviews.firstObject;
    
    UIButton *tagBt = [button viewWithTag:1001];
    if (tagBt != nil) {
        return;
    }
    CGRect rect = button.frame;
    rect.size.width -= 10;
    rect.size.height -= 7;
    rect.origin.x = 10;
    
    UIButton *_delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delectBtn.titleLabel setFont:ESFontPingFangRegular(14)];
    [_delectBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
    [_delectBtn setTitle:NSLocalizedString(@"box_list_clear_title", @"清除") forState:UIControlStateNormal];
    _delectBtn.backgroundColor = [UIColor colorWithRed:51/255.0 green:122/255.0 blue:255/255.0 alpha:1];
    _delectBtn.layer.cornerRadius = 10.0f;
    _delectBtn.clipsToBounds = YES;
    _delectBtn.userInteractionEnabled = NO;
    [button addSubview:_delectBtn];
    _delectBtn.frame = rect;
    _delectBtn.tag = 1001;

    button.backgroundColor = [UIColor colorWithRed:51/255.0 green:122/255.0 blue:255/255.0 alpha:0.02];
}

- (void)showTrailUnvaildDialog {
    [self showTrailUnvaildDialog:ESBoxManager.activeBox];
}

- (void)showTrailUnvaildDialog:(ESBoxItem *)box {
    ESDLog(@"[BoxList] showTrailUnvaildDialog :%@", box);
    if (!box) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"trial_expired", @"用户已失效")
                                                                   message:NSLocalizedString(@"trial_userExpired", @"用户已失效，请重新申请激活码") preferredStyle:UIAlertControllerStyleAlert];
    weakfy(self)
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"知道了"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        strongfy(self)
        [[ESBoxManager manager] revokePush:box];
        [self loadData];
    }];
    [alert addAction:conform];
    //4.显示弹框
    [self presentViewController:alert animated:YES completion:nil];
}

@end

