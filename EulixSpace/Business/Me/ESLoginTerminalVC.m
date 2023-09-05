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
//  ESLoginTerminalVC.m
//  EulixSpace
//
//  Created by qu on 2022/5/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESLoginTerminalVC.h"

#import "ESBoxManager.h"
#import "ESPlatformClient.h"
#import "ESThemeDefine.h"
#import "ESColor.h"
#import "ESToast.h"
#import "ESTerminalListCell.h"
#import "ESWebTryPageVC.h"
#import "ESTerminalAuthorizationServiceApi.h"
#import "ESTerminalAutorizationServiceApi.h"
#import "ESAccountServiceApi.h"
#import <Masonry/Masonry.h>

#import "ESAccountManager.h"
#import "ESBindResultViewController.h"
#import "ESBoxManager.h"
#import "ESDeviceInfoView.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESGradientButton.h"
#import "ESRSACenter.h"
#import "ESSecurityPasswordInputViewController.h"
#import "ESThemeDefine.h"
#import "ESUpgradeVC.h"
#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import <Masonry/Masonry.h>
#import "ESSpaceSystemInfoVC.h"
#import "ESDeviceInfoModel.h"
#import "ESDeviceInfoServiceModule.h"
#import "ESCache.h"
#import "ESCommonToolManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ESLoginTerminalVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) NSMutableArray *selfDataList;

@property (strong, nonatomic) NSString *uuid;

@property (nonatomic, strong) ESDeviceInfoView *deviceInfo;

@property (nonatomic, strong) ESGradientButton *unbindingBtn;

@property (nonatomic, strong) UILabel *netNameLabel;

@property (nonatomic, strong) NSString *appVersion;

@property (nonatomic, copy) NSString *pkgSize;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *packName;

@property (nonatomic, copy) NSString *pckVersion;

@property (nonatomic, assign) BOOL isVarNewVersionExist;

@property (nonatomic, strong) UIView *deviceInfoNumView;

@property (nonatomic, strong) ESTerminalListCell *headCell;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) ESDeviceInfoModel *deviceInfoModel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *zpgl;

@property (nonatomic, strong) UIView *bgView1;

@property (nonatomic, strong) UIView *bgView2;

@property (nonatomic, strong) UIView *systemUpView;

@property (nonatomic, strong) UIView *zpglInfoNumView;

@end

@implementation ESLoginTerminalVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [self getManagementServiceApi];
    [self checkVersionServiceApi];
    [self reqDiskInfos];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = TEXT_ME_DEVICE_MANAGER;
    [self initUI];

    if (!ESAccountManager.manager.deviceInfo) {
        [ESAccountManager.manager loadDeviceStorage:^(ESDeviceInfoResult *deviceInfo) {
            [self showDeviceStorage:deviceInfo];
        }];
    } else {
        [self showDeviceStorage:ESAccountManager.manager.deviceInfo];
    }


    [self fetchDeviceInfo];

    if (ESBoxManager.activeBox.boxType == ESBoxTypeAuth) {
        self.unbindingBtn.hidden = YES;
    }
    [self getDataServiceApi];
    self.dataList = nil;
}

- (void)showDeviceStorage:(ESDeviceInfoResult *)deviceInfo {
    UInt64 spaceSizeUsed = deviceInfo.spaceSizeUsed.longLongValue;
    UInt64 spaceSizeTotal = deviceInfo.spaceSizeTotal.longLongValue;
    
    self.deviceInfoModel.storageInfo.totalSize = spaceSizeTotal;
    self.deviceInfoModel.storageInfo.usagedSize = spaceSizeUsed;
    self.deviceInfoModel.storageInfo.freeSize = spaceSizeTotal - spaceSizeUsed;
    [self.deviceInfo loadWithDeviceInfo:self.deviceInfoModel];
}

- (void)initUI {
    self.tableView.tableHeaderView = self.container;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
        make.left.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(-kBottomHeight);
        make.right.mas_equalTo(self.view).offset(0);
    }];
    
    [self.container addSubview:self.deviceInfo.deviceBaseInfoView];
    __block float containHeight = 0;
    float height = [ESCommonToolManager isEnglish] ? (210 - 18) : 152;
    [self.deviceInfo.deviceBaseInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.container.mas_top).offset(0.0f);
        make.left.mas_equalTo(self.container.mas_left).offset(10.0f);
        make.right.mas_equalTo(self.container.mas_right).offset(-10.0f);
        make.height.mas_equalTo(height);
        containHeight += height;
    }];
    [self.deviceInfo.deviceBaseInfoView setCornerRadius:0];
    
    CGRect tmpFrame = CGRectMake(0, 0, ScreenWidth - 20, height);
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:tmpFrame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = tmpFrame;
    maskLayer.path = maskPath.CGPath;
    self.deviceInfo.deviceBaseInfoView.layer.mask = maskLayer;
    
    BOOL isGen2Box = [ESBoxManager.activeBox.deviceAbilityModel isGen2Box];
    [self.container addSubview:self.deviceInfo.deviceStorageInfoView];
    height = 110;
    [self.deviceInfo.deviceStorageInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceInfo.deviceBaseInfoView.mas_bottom).offset(0);
        make.left.mas_equalTo(self.container).offset(10);
        make.right.mas_equalTo(self.container).offset(-10);
        [self.deviceInfo.deviceStorageInfoView hiddenCPUMemView];
        [self.deviceInfo.deviceStorageInfoView hiddenStorageViewTitle];
        make.height.mas_equalTo(height);
        containHeight += height;
    }];
    [self.deviceInfo.deviceStorageInfoView setCornerRadius:0];

    tmpFrame = CGRectMake(0, 0, ScreenWidth - 20, height);
    maskPath = [UIBezierPath bezierPathWithRoundedRect:tmpFrame byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = tmpFrame;
    maskLayer.path = maskPath.CGPath;
    self.deviceInfo.deviceStorageInfoView.layer.mask = maskLayer;
    
    UIView * topView = self.deviceInfo.deviceStorageInfoView;
    
//    BOOL hiddenSystemUpdate = ([self isRealBoxAuth] || [self isRealBoxMember])
//                               || ([self isTrialBox] && !ESBoxManager.activeBox.deviceAbilityModel.upgradeApiSupport);
    BOOL hiddenSystemUpdate = (ESBoxManager.activeBox.boxType != ESBoxTypePairing);
    if (!hiddenSystemUpdate) {
        UIView *systemUpView = [self cellViewWithTitle:NSLocalizedString(@"System Update", @"系统升级") titleText:@""];
        self.systemUpView = systemUpView;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(systemUpViewClick:)];
        
        [systemUpView addGestureRecognizer:tapRecognizer];
        [self.container addSubview:systemUpView];
        
        [systemUpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topView.mas_bottom).offset(0);
            make.left.mas_equalTo(self.container.mas_left).offset(10.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(-10.0f);
            make.height.mas_equalTo(60);
            containHeight += 60;
        }];
        
        topView = systemUpView;
        
        UIView * linkView = [[UIView alloc] init];
        linkView.backgroundColor = ESColor.separatorColor;
        [self.container addSubview:linkView];
        [linkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topView.mas_bottom).offset(-1);
            make.left.mas_equalTo(self.container.mas_left).offset(26.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(-26.0f);
            make.height.mas_equalTo(1);
        }];
    }

    {
        UIView *bgView = [[UIView alloc] init];
        [self.container addSubview:bgView];
        bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topView.mas_bottom).offset(0);
            make.left.mas_equalTo(self.container.mas_left).offset(0.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(0.0f);
            make.height.mas_equalTo(30);
            containHeight += 30;
        }];
        UILabel *bdsbTitle = [[UILabel alloc] init];
        bdsbTitle.text = NSLocalizedString(@"box_bind_A", @"绑定设备");
        bdsbTitle.textColor = ESColor.grayPointColor;
        bdsbTitle.textAlignment = NSTextAlignmentCenter;
        bdsbTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        [self.container addSubview:bdsbTitle];
        
        [bdsbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_top).offset(8);
            make.left.mas_equalTo(self.container.mas_left).offset(26.0f);
            make.height.mas_equalTo(14);
        }];
        ESTerminalListCell *cell = [[ESTerminalListCell alloc] init];
        self.headCell = cell;
        weakfy(self);
        self.headCell.actionBlock = ^(NSString *selectedNum) {
            strongfy(self);
            [self unbindingBtnClick];
        };
        self.headCell.type = @"head";
        [self.container addSubview:cell];
        
        [cell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_bottom).offset(0);
            make.left.mas_equalTo(self.container.mas_left).offset(0.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(0.0f);
            make.height.mas_equalTo(105);
            containHeight += 105;
        }];
        
        UIView *bgView1 = [[UIView alloc] init];
        self.bgView1 = bgView1;
        [self.container addSubview:bgView1];
        bgView1.backgroundColor = ESColor.secondarySystemBackgroundColor;
        [bgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView.mas_bottom).offset(105);
            make.left.mas_equalTo(self.container.mas_left).offset(0.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(0.0f);
            make.height.mas_equalTo(30);
            containHeight += 30;
        }];
        
        UILabel *bdsbTitle1 = [[UILabel alloc] init];
        bdsbTitle1.text =  NSLocalizedString(@"Login Device A", @"登录设备");
        bdsbTitle1.textColor = ESColor.grayPointColor;
        bdsbTitle1.textAlignment = NSTextAlignmentLeft;
        bdsbTitle1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        [bgView1 addSubview:bdsbTitle1];
        
        [bdsbTitle1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView1.mas_top).offset(8);
            make.left.mas_equalTo(self.container.mas_left).offset(26.0f);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(100);
        }];
        
        UIView *bgView2 = [[UIView alloc] init];
        [self.container addSubview:bgView2];
        bgView2.backgroundColor = ESColor.systemBackgroundColor;
        
        UILabel *bdsbTitle2 = [[UILabel alloc] init];
        //   bdsbTitle2.text = @"显示本空间已登录的所有终端信息，建议您对陌生终端进行下线操作，以防止隐私泄露。被下线的终端仍然可以再次扫码授权登录。* IP 属地仅供参考。";
        bdsbTitle2.textColor = ESColor.grayPointColor;
        bdsbTitle2.numberOfLines = 0;
        bdsbTitle2.textAlignment = NSTextAlignmentLeft;
        bdsbTitle2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [bgView2 addSubview:bdsbTitle2];
        
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Display all the terminal", @"显示本空间已登录的所有终端信息，建议您对陌生终端进行下线操作，以防止隐私泄露。被下线的终端仍然可以再次扫码授权登录 * IP 属地仅供参考。")];
        if ([ESCommonToolManager isEnglish]) {
            [attStr addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(attStr.length - 39, 39)];
        }else{
            [attStr addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(attStr.length -12, 12)];
        }
        
        
        bdsbTitle2.attributedText = attStr;
        
        
        if ([ESCommonToolManager isEnglish]) {
            
            [bgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(bgView1.mas_bottom).offset(0);
                make.left.mas_equalTo(self.container.mas_left).offset(0.0f);
                make.right.mas_equalTo(self.container.mas_right).offset(0.0f);
                make.height.mas_equalTo(120);
            }];
            
            [bdsbTitle2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(bgView2.mas_top).offset(2);
                make.left.mas_equalTo(self.container.mas_left).offset(26.0f);
                make.right.mas_equalTo(self.container.mas_right).offset(-26.0f);
                make.height.mas_equalTo(120);
            }];
            containHeight += 120;
        }else{
            [bgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(bgView1.mas_bottom).offset(0);
                make.left.mas_equalTo(self.container.mas_left).offset(0.0f);
                make.right.mas_equalTo(self.container.mas_right).offset(0.0f);
                make.height.mas_equalTo(80);
            }];
            
            [bdsbTitle2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(bgView2.mas_top).offset(2);
                make.left.mas_equalTo(self.container.mas_left).offset(26.0f);
                make.right.mas_equalTo(self.container.mas_right).offset(-26.0f);
                make.height.mas_equalTo(80);
            }];
            containHeight += 80;
        }
        UIView *linkView3 = [[UIView alloc] init];
        linkView3.backgroundColor = ESColor.separatorColor;
        [self.container addSubview:linkView3];
        
        [linkView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bgView2.mas_bottom).offset(0);
            make.left.mas_equalTo(self.container.mas_left).offset(10.0f);
            make.right.mas_equalTo(self.container.mas_right).offset(-10.0f);
            make.height.mas_equalTo(1);
        }];
    }
    containHeight += 10;
    CGRect frame = self.container.frame;
    frame.size.height = containHeight;
    self.container.frame = frame;
}

- (BOOL)isRealBoxAuth {
    return ![ESBoxManager.activeBox.deviceAbilityModel isTrialBox] && ESBoxManager.activeBox.boxType == ESBoxTypeAuth;
}

- (BOOL)isRealBoxMember {
    return ![ESBoxManager.activeBox.deviceAbilityModel isTrialBox] && ESBoxManager.activeBox.boxType == ESBoxTypeMember;
}

- (BOOL)isRealBoxPairing {
    return ![ESBoxManager.activeBox.deviceAbilityModel isTrialBox] && ESBoxManager.activeBox.boxType == ESBoxTypePairing;
}

- (BOOL)isTrialBox {
    return [ESBoxManager.activeBox.deviceAbilityModel isTrialBox];
}

- (NSInteger)supportCount {
    NSMutableArray *supportCount = [NSMutableArray array];
    if (ESBoxManager.activeBox.deviceAbilityModel.upgradeApiSupport) {
        [supportCount addObject:@(YES)];
    }
    if (ESBoxManager.activeBox.deviceAbilityModel.networkConfigSupport) {
        [supportCount addObject:@(YES)];
    }
    if (ESBoxManager.activeBox.deviceAbilityModel.innerDiskSupport) {
        [supportCount addObject:@(YES)];
    }
    return supportCount.count;
}

- (UIView *)container {
  if (!_container) {
      _container = [[UIView alloc] init];
  }
  return _container;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESTerminalListCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                         @"ESTerminalListCellD"];
    if (cell == nil) {
        cell = [[ESTerminalListCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"ESTerminalListCellDI"];
    }
    if (self.dataList.count > indexPath.row) {
        cell.uuid = self.uuid;
        cell.model = self.dataList[indexPath.row];
    }
    if (indexPath.row != self.dataList.count - 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25, 104, ScreenWidth - 50, 1)];
        lineView.backgroundColor = ESColor.separatorColor;
        [cell.contentView addSubview:lineView];
    }
    weakfy(self)
    cell.actionBlock  = ^(ESAuthorizedTerminalResult *model) {
        strongfy(self)
        [self downLine:model];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)getDataServiceApi {
    ESTerminalAuthorizationServiceApi *api = [ESTerminalAuthorizationServiceApi new];
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *aoid = dic[@"aoId"];
    
    [api spaceV1ApiTerminalAllInfoGetWithAoid:aoid completionHandler:^(ESResponseBaseListAuthorizedTerminalResult *output, NSError *error) {
        if(!error){
            self.selfDataList = [[NSMutableArray alloc] init];
            NSArray *array = [[NSArray alloc] init];
            array =output.results;
            self.dataList = [[NSMutableArray alloc] init];
            for (ESAuthorizedTerminalResult*result  in array) {
                  if([result.uuid isEqual:ESBoxManager.clientUUID]){
                    [self.selfDataList addObject:result];
                    self.headCell.model = result;
                    [self.dataList addObject:result];
                  }else{
                      [self.dataList addObject:result];
                  }
            }
      
            ESAccountServiceApi *apiInfo= [ESAccountServiceApi new];
            [apiInfo spaceV1ApiPersonalInfoGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
                if ([output.code isEqualToString:@"GW-5005"]) {
                    [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
                    return;
                }
                NSArray *array = [[NSArray alloc] init];
                array = output.results;
                if(array.count > 0){
                    ESAccountInfoResult *result = array[0];
                    self.uuid = result.clientUUID;
                    [self.tableView reloadData];
                }
            }];
        }else{
             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        }
    }];
}

-(void)downLine:(ESAuthorizedTerminalResult *)model{
    
    NSString *str  = [NSString stringWithFormat:NSLocalizedString(@"Are you sure to offline %@ ?", @"确认下线%@吗？"),model.terminalModel];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Offline Terminal", @"下线终端")  message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"确认")
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        ESTerminalAuthorizationServiceApi *api = [ESTerminalAuthorizationServiceApi new];
        ESBoxItem *box = ESBoxManager.activeBox;
        NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
        NSString *aoid = dic[@"aoId"];
        [api spaceV1ApiTerminalInfoDeletePostWithAoid:aoid clientUUID:model.uuid completionHandler:^(ESResponseBaseAuthorizedTerminalResult *output, NSError *error) {
            if(!error){
                [ESToast toastSuccess:NSLocalizedString(@"Offline Success", @"下线成功")];
                [self getDataServiceApi];
                [self.tableView reloadData];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }];
    //2.2 取消按钮
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action){
                                                   }];

    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    [alert addAction:cancel];

    //4.显示弹框
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Lazy Load

- (ESDeviceInfoView *)deviceInfo {
    if (!_deviceInfo) {
        _deviceInfo = [ESDeviceInfoView new];
        [self.container addSubview:_deviceInfo];
        _deviceInfo.backgroundColor = ESColor.systemBackgroundColor;
        _deviceInfo.layer.cornerRadius = 10.0f;
        _deviceInfo.clipsToBounds = YES;
        
        __weak typeof(self) weakSelf = self;
        _deviceInfo.actionBlock = ^(id sender) {
            __strong typeof(weakSelf) self = weakSelf;
            ESSpaceSystemInfoVC *vc = [[ESSpaceSystemInfoVC alloc] init];
            [vc reloadDataWithDeviceInfo:self.deviceInfoModel];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _deviceInfo;
}

- (void)loadData {
    [ESAccountManager.manager loadNetworkInfo:^(NSString *linkName) {
       // self.netNameLabel.text = linkName;
        self.netNameLabel.text = [self getWifiName];
    }];
}

- (UIView *)cellViewWithTitle:(NSString *)title titleText:(NSString *)titleText {
    UIView *cellView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    titleLabel.textColor = [ESColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = title;
    [cellView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellView.mas_left).offset(16.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-20.0);
        make.width.equalTo(@(200.0f));
        make.height.equalTo(@(25.0f));
    }];

    if ([title isEqual:NSLocalizedString(@"box_network_setup", @"网络设置")]) {
        UILabel *titleTextLabel = [[UILabel alloc] init];
        titleTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        titleTextLabel.textColor = [ESColor secondaryLabelColor];
        titleTextLabel.textAlignment = NSTextAlignmentRight;
        titleTextLabel.text = titleText;
        [cellView addSubview:titleTextLabel];
        [titleTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cellView.mas_right).offset(-26.0);
            make.width.equalTo(@(200.0f));
            make.bottom.mas_equalTo(cellView.mas_bottom).offset(-20.0);
            make.height.equalTo(@(22.0f));
        }];
    
        self.netNameLabel = titleTextLabel;
        
    }
  
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = IMAGE_FILE_COPYBACK;
    [cellView addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-29.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-24.0);
        make.height.equalTo(@(16.0f));
        make.width.equalTo(@(16.0f));
    }];

    if (titleText.length > 0) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = ESColor.separatorColor;
        [cellView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(cellView.mas_right).offset(-20.0);
            make.bottom.mas_equalTo(cellView.mas_bottom).offset(-1.0f);
            make.left.mas_equalTo(cellView.mas_left).offset(26.0);
            make.height.equalTo(@(1.0f));
        }];
    }

    if ([title isEqual:NSLocalizedString(@"System Update", @"系统升级")]) {
        _deviceInfoNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _deviceInfoNumView.layer.masksToBounds = YES;
        _deviceInfoNumView.hidden = YES;
        [_deviceInfoNumView setBackgroundColor:[UIColor redColor]];
        _deviceInfoNumView.layer.cornerRadius = 8;
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = @"1";
        [_deviceInfoNumView addSubview:numLabel];
        [_deviceInfoNumView setBackgroundColor:[UIColor redColor]];
        [cellView addSubview:_deviceInfoNumView];
//        _deviceInfoNumView.hidden = !self.isHaveRedView;

        [_deviceInfoNumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(arrowImageView.mas_left).offset(-14.0);
            make.width.equalTo(@(16));
            make.height.equalTo(@(16.0f));
            make.centerY.mas_equalTo(titleLabel.mas_centerY);
        }];
    }
    if ([title isEqual:NSLocalizedString(@"Disk Management", @"磁盘管理")]) {
        _zpglInfoNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _zpglInfoNumView.layer.masksToBounds = YES;
        _zpglInfoNumView.hidden = YES;
        [_zpglInfoNumView setBackgroundColor:[UIColor redColor]];
        _zpglInfoNumView.layer.cornerRadius = 8;
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = @"1";
        [_zpglInfoNumView addSubview:numLabel];
        [_zpglInfoNumView setBackgroundColor:[UIColor redColor]];
        [cellView addSubview:_zpglInfoNumView];
//        _deviceInfoNumView.hidden = !self.isHaveRedView;

        [_zpglInfoNumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(arrowImageView.mas_left).offset(-14.0);
            make.width.equalTo(@(16));
            make.height.equalTo(@(16.0f));
            make.centerY.mas_equalTo(titleLabel.mas_centerY);
        }];
    }

    return cellView;
}


- (ESGradientButton *)unbindingBtn {
    if (!_unbindingBtn) {
        _unbindingBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_unbindingBtn setCornerRadius:10];
        [_unbindingBtn setTitle:NSLocalizedString(@"box_unbind", @"解绑设备") forState:UIControlStateNormal];
        _unbindingBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_unbindingBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_unbindingBtn setTitleColor:ESColor.disableTextColor forState:UIControlStateDisabled];
        [self.view addSubview:_unbindingBtn];
        [_unbindingBtn addTarget:self action:@selector(unbindingBtnClick) forControlEvents:UIControlEventTouchUpInside];

    }
    return _unbindingBtn;
}

- (void)unbindingBtnClick {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];

    if ([self failCount] >= 3 &&
        [self failTimer] > 0 &&
        (currentTime - self.failTimer) < 60) {
        ESToast.networkError(NSLocalizedString(@"retry 1 min later", @"请1分钟后重试")).show();
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TEXT_BOX_BIND_UNBIND message:TEXT_BOX_BIND_UNBIND_PROMPT preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action){

                                                   }];
    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:TEXT_OK
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       ESBoxItem *box = ESBoxManager.activeBox;
                                                       ESRSAPair *pair = [ESRSACenter boxPair:box.boxUUID];
                                                       NSDictionary *dicFamily = [ESBoxManager cacheInfoForBox:box];
                                                       NSNumber *boolNum = dicFamily[@"isAdmin"];
                                                       BOOL isAdmin = [boolNum boolValue];
                                                       if (isAdmin) {
                                                           ESSecurityPasswordInputViewController *next = [ESSecurityPasswordInputViewController new];
                                                           next.type = ESSecurityPasswordTypeUnbindBox;
                                                           next.authType = ESAuthenticationTypeBinderResetPassword;
                                                           [self.navigationController pushViewController:next animated:YES];
                                                       } else {
                                                           ESSpaceGatewayMemberAuthingServiceApi *api = [ESSpaceGatewayMemberAuthingServiceApi new];
                                                           ESRevokeMemberClientInfo *info = [ESRevokeMemberClientInfo new];
                                                           info.encryptedAuthKey = [pair publicEncrypt:box.info.authKey];
                                                           info.encryptedClientUUID = [pair publicEncrypt:ESBoxManager.clientUUID];
                                                           [api spaceV1ApiGatewayAuthRevokeMemberPostWithBody:info
                                                                                            completionHandler:^(ESResponseBaseRevokeMemberClientResult *output, NSError *error) {
                                                                                                ESBindResultViewController *vc = [ESBindResultViewController new];
                                                                                                if (!error) {
                                                                                                    [ESBoxManager.manager justRevoke:ESBoxManager.activeBox];
                                                                                                    vc.success = YES;
                                                                                                    vc.type = ESBindResultTypeUnbind;
                                                                                                } else {
                                                                                                     [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                                                                                    vc.success = NO;
                                                                                                    vc.type = ESBindResultTypeUnbind;
                                                                                                }
                                                            
                                                                                                [self.navigationController pushViewController:vc animated:YES];
                                                                                            }];
                                                       }
                                                   }];

    [alertController addAction:cancel];
    [alertController addAction:turnOn];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)systemUpViewClick:(UITapGestureRecognizer *)sender {
    ESUpgradeVC *vc = [ESUpgradeVC new];
    
    ESSapceUpgradeInfoModel *upgradeInfo = [ESSapceUpgradeInfoModel new];
    upgradeInfo.appVersion = self.appVersion;
    upgradeInfo.pkgSize = self.pkgSize;
    upgradeInfo.packName = self.packName;
    upgradeInfo.pckVersion = self.pckVersion;
    upgradeInfo.isVarNewVersionExist = self.isVarNewVersionExist;
    upgradeInfo.desc = self.desc;
    [self checkVersionServiceApi];
    upgradeInfo.isVarNewVersionExist = self.isVarNewVersionExist;
    
    [vc loadWithUpgradeInfo:upgradeInfo];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkVersionServiceApi {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    self.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    
    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    __weak typeof(self) weakSelf = self;
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:self.appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                                 __strong typeof(weakSelf) self = weakSelf;
                                                 if (!error) {
                                                     ESDLog(@"[ESDeviceManagerViewController] appVersion: %@ \n checkVersionServiceApi: %@",self.appVersion, output);
                                                     BOOL isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     self.isHaveRedView = isVarNewVersionExist;
                                                     ESPackageRes *res = output.results.latestBoxPkg;
                                                     self.pkgSize = FileSizeString(res.pkgSize.floatValue, YES);
                                                     self.packName = res.pkgName;
                                                     self.pckVersion = res.pkgVersion;
                                                     self.isVarNewVersionExist = isVarNewVersionExist;
                                                     self.desc = res.updateDesc;
                                                     self.deviceInfoNumView.hidden = !isVarNewVersionExist;
                                                     if (isVarNewVersionExist == NO) {
                                                         [clientResultApi spaceV1ApiGatewayVersionBoxCurrentGetWithCompletionHandler:^(ESResponseBaseString1 *output, NSError *error) {
                                                             self.pckVersion = output.results;
                                                         }];
                                                     }
                                                 } else {
                                                     self.isVarNewVersionExist = NO;
                                                     self.deviceInfoNumView.hidden = YES;
                                                     [clientResultApi spaceV1ApiGatewayVersionBoxCurrentGetWithCompletionHandler:^(ESResponseBaseString1 *output, NSError *error) {
                                                         if(!error){
                                                             self.pckVersion = output.results;
                                                         }
                                                     }];
                                                 }
                                             }];
}

- (void)fetchDeviceInfo {
    [self tryLoadCacheDeviceInfo];
    __weak typeof(self) weakSelf = self;
    [ESDeviceInfoServiceModule getDeviceInfoWithCompletion:^(ESDeviceInfoResultModel * _Nullable deviceInfoResult, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!error && deviceInfoResult) {
            [self.deviceInfoModel updateWithDeviceInfoResultModel:deviceInfoResult];
            if (self.deviceInfoModel) {
             //   [[ESCache defaultCache] setObject:self.deviceInfoModel forKey:ESBoxManager.activeBox.boxUUID];
            }
            [self.deviceInfo loadWithDeviceInfo:self.deviceInfoModel];
        }
    }];
}

- (void)tryLoadCacheDeviceInfo {
    ESDeviceInfoModel *deviceInfoModel = [[ESCache defaultCache] objectForKey:ESBoxManager.activeBox.boxUUID];
    if (deviceInfoModel) {
        [self.deviceInfo loadWithDeviceInfo:deviceInfoModel];
    }
}

- (ESDeviceInfoModel *)deviceInfoModel {
    if (!_deviceInfoModel) {
        _deviceInfoModel = [ESDeviceInfoModel new];
    }
    return _deviceInfoModel;
}

- (NSTimeInterval)failTimer {
   NSNumber *failTimerNumber = [[ESCache defaultCache] objectForKey:@"ESFailTimer"];
    if (failTimerNumber == nil) {
        return 0;
    }
    return [failTimerNumber doubleValue];
}

- (void)setFailTimer:(NSTimeInterval)failTimer {
    [[ESCache defaultCache] setObject:@(failTimer) forKey:@"ESFailTimer"];
}

- (NSInteger)failCount {
    NSNumber *failCount_ = [[ESCache defaultCache] objectForKey:@"ESFailCount"];
     if (failCount_ == nil) {
         return 0;
     }
     return [failCount_ intValue];
}

- (void)setFailCount:(NSInteger)failCount {
    [[ESCache defaultCache] setObject:@(failCount) forKey:@"ESFailCount"];
}


// 获取当前wifi名称代码
- (NSString *)getWifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString*)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (void)reqDiskInfos {
    weakfy(self);
    self.zpglInfoNumView.hidden = YES;
    [ESNetworkRequestManager sendCallRequest:@{ServiceName: eulixspace_agent_service,
                                               ApiName : disk_management_list
                                             } queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
    
        ESDiskManagementModel * model = [ESDiskManagementModel yy_modelWithJSON:response];
        ESDLog(@"[ESLoginTerminalVC] [reqDiskInfos] response %@", model);
        strongfy(self);
        if (model.isMissingMainStorage) {
            self.zpglInfoNumView.hidden = NO;
        } else {
            [model.diskManageInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.diskException == 1 || obj.diskException == 10) {
                    *stop = YES;
                    self.zpglInfoNumView.hidden = NO;
                    return;
                }
            }];
        }
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        ESDLog(@"[ESLoginTerminalVC] [reqDiskInfos] error %@", error);
    }];
}


- (void)dealloc {
    
}

@end
