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
//  ESMeViewController.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/2.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESMeViewController.h"
#import "ESAboutViewController.h"
#import "ESAccountManager.h"
#import "ESBannerDeviceInfo.h"
#import "ESBannerMemberInfo.h"
#import "ESCacheCleanTools.h"
#import "ESDeviceInfoView.h"
#import "ESFeedbackViewController.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESFormView.h"
#import "ESMeHeader.h"
#import "ESMemberManager.h"
#import "ESMoreFunctionView.h"
#import "ESPersonalInfoViewController.h"
#import "ESPlatformClient.h"
#import "ESSettingItemView.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESTryListVC.h"
#import "ESVersionManager.h"
#import "ESRecycleBinVC.h"
#import "ESBoxManager.h"
#import "ESWebContainerViewController.h"
#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import "ESSpaceGatewayVersionCheckingServiceApi.h"
#import <Masonry/Masonry.h>
#import "ESAccountServiceApi.h"
#import "ESCommentCachePlistData.h"
#import "ESLoginTerminalVC.h"
#import "ESPushNewsSettingVC.h"
#import "ESLockSetingVC.h"
#import "ESMeSettingController.h"
#import "ESMeNewListVC1.h"
#import "ESMeSettingV2.h"
#import "ESAccountInfoStorage.h"
#import "ESCommonToolManager.h"
#import "ESSecurityEmailMamager.h"
#import "UILabel+ESTool.h"
#import "UIView+ESTool.h"
#import "ESGatewayManager.h"
#import "UIColor+ESHEXTransform.h"
#import "ESPersonalSpaceInfoVC.h"
#import "ESNetworkRequestManager.h"
#import "ESDeviceInfoServiceModule.h"
#import "ESCommentToolVC.h"
#import "ESCache.h"
#import "ESDeviceStorageInfoView.h"
#import <MessageUI/MessageUI.h>
#import "ESDIDDocManager.h"

typedef NS_ENUM(NSUInteger, ESSettingCellType) {
    ESSettingCellTypeDevice,
    ESSettingCellTypeMember, //家庭
    
    ESSettingCellTypeRecycleBin,        //回收站
    ESSettingCellTypeMeShare,        //我的分享
    ESSettingCellTypeCache,            //清除缓存
    ESSettingCellTypeTrialFeedback,    //试用反馈
    ESSettingCellTypeFAQ,              //帮助与反馈
    ESSettingCellTypeLogin,              //登陆终端

    ESSettingCellTypeWeb,   //访问网页端
    ESSettingCellTypeNews,   //消息设置
    ESSettingCellTypeAbout, //关于
    ESSettingCellTypeSetting, //设置
    ESSettingCellTypeContactEmail, // Contact Email
};

@interface ESMeViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) ESMeHeader *header;

@property (nonatomic, strong) ESDeviceStorageInfoView * deviceStorageInfoView;

//@property (nonatomic, strong) ESMoreFunctionView *moreFunction;

@property (nonatomic, strong) ESSettingItemView *settingItemView;

@property (nonatomic, strong) UIView *deviceInfoNumView;

@property (nonatomic, strong) UIView *tryUserInfoNumView;

@property (nonatomic, copy) NSString *cacheSize;

@property (nonatomic, assign) BOOL isVarNewVersionExist;

@property (nonatomic, strong) UIImageView *new;

@property (nonatomic, strong) UIView *redNewPointView;

@property (nonatomic, strong) UIView * sloganView;
@end


@implementation ESMeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkVersionServiceApi];
    [self initUI];
    id isHaveNews = [[NSUserDefaults standardUserDefaults] objectForKey:@"isHaveNews"];
    if([isHaveNews boolValue]){
        self.redNewPointView.hidden = NO;
    }else{
        self.redNewPointView.hidden = YES;
    }
    
    [self checkBoxSupportNewBind];
    [self updateDIDDocInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initUI];
    self.tableView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    self.tableView.tableHeaderView = self.container;
    self.navigationBarBackgroundColor = ESColor.clearColor;

    [self.redNewPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.new.mas_right).offset(-6);
        make.top.mas_equalTo(self.new.mas_top).offset(8);
        make.width.height.mas_equalTo(8);
    }];

    [self.sloganView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.settingItemView.mas_bottom).mas_equalTo(20);;
    }];
    [self fetchDeviceInfo:NO];
}

- (void)loadDeviceStorage {
    ESDeviceInfoResult *deviceInfo = ESAccountManager.manager.deviceInfo;
    [self showDeviceStorage:(UInt64)deviceInfo.spaceSizeUsed.longLongValue spaceSizeTotal:(UInt64)deviceInfo.spaceSizeTotal.longLongValue boxHasNewVersion:NO];
    [ESAccountManager.manager loadDeviceStorage:^(ESDeviceInfoResult *deviceInfo) {
        [ESVersionManager checkBoxVersion:^(ESPackageCheckRes *info) {
            ESDLog(@"[ESMeViewController] checkBoxVersion: %@", info);
            [self showDeviceStorage:(UInt64)deviceInfo.spaceSizeUsed.longLongValue
                     spaceSizeTotal:(UInt64)deviceInfo.spaceSizeTotal.longLongValue
                   boxHasNewVersion:info.varNewVersionExist.boolValue];
        }];
    }];
}

- (BOOL)isTrailOnlineAccount {
    return [ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox];
}

- (void)showDeviceStorage:(UInt64)spaceSizeUsed spaceSizeTotal:(UInt64)spaceSizeTotal boxHasNewVersion:(BOOL)boxHasNewVersion {
    ESDeviceInfoModel * info = [[ESDeviceInfoModel alloc] init];
    ESDeviceStorageInfoModel * model = [[ESDeviceStorageInfoModel alloc] init];
    model.title = NSLocalizedString(@"es_device", @"设备");
    model.showBgImage = YES;
    model.totalSize = spaceSizeTotal;
    model.usagedSize = spaceSizeUsed;
    model.freeSize = spaceSizeTotal - spaceSizeUsed;
    info.storageInfo = model;
    [self.deviceStorageInfoView loadWithDeviceInfo:info];
}

- (void)showInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        ESPersonalInfoResult *info = ESAccountManager.manager.userInfo;
        ESFormItem *item = [ESFormItem new];
        item.title = info.personalName ?: ESBoxManager.activeBox.spaceName;
        item.content = info.personalSign;
        item.lineMargin = 0;
        item.avatar = ESAccountManager.manager.avatarPath;
        [self.header reloadWithData:item];
    });
}

- (void)loadPersonInfo {
    [self showInfo];
    [ESAccountManager.manager loadInfo:^(ESPersonalInfoResult *info) {
        [self showInfo];
    }];
    [ESAccountManager.manager loadAvatar:^(NSString *imagePath) {
        [self showInfo];
    }];
}

- (void)loadData {
    [self loadDeviceStorage];
    [self loadPersonInfo];
    [self reloadSetting];
    self.cacheSize = @"0.00B";
    [ESCacheCleanTools cacheSizeWithCompletion:^(NSString *size) {
        self.cacheSize = size;
    }];
}


//2.O
- (void)reloadSetting {
    NSMutableArray<ESFormItem *> *data = NSMutableArray.array;
    //设置
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeSetting;
        item.icon = [UIImage imageNamed:@"sz"];
        item.title = TEXT_COMMON_SETTING;
        item.arrowRight = 16;
        [data addObject:item];
    }
 
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeFAQ;
        item.icon = [UIImage imageNamed:@"bzzx"];
        item.title = TEXT_HOME_HELP;
        item.arrowRight = 16;
        [data addObject:item];
    }
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeContactEmail;
        item.icon = [UIImage imageNamed:@"me_contact_email"];
        item.title = NSLocalizedString(@"feedback_email", @"联系邮箱");
        item.content = @"service@ao.space";
        item.arrowRight = 16;
        [data addObject:item];
    }
  
    {
        ESFormItem *item = [ESFormItem new];
        item.row = ESSettingCellTypeAbout;
        item.icon = [UIImage imageNamed:@"guanyu"];
        item.title = TEXT_ME_ABOUT;
        item.arrowRight = 16;
        [data addObject:item];
    }
    data.lastObject.hideLine = YES;
    [self.settingItemView reloadWithData:data];
}

- (void)initUI {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(-kTopHeight);
    }];
    self.view.backgroundColor = ESColor.secondarySystemBackgroundColor;

    [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.container).offset(0);
        make.right.mas_equalTo(self.container).offset(0);
        make.left.mas_equalTo(self.container);
        make.height.mas_equalTo(200);
    }];

    [self.deviceStorageInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.header.mas_bottom);
        make.right.mas_equalTo(self.container).inset(10);
        make.left.mas_equalTo(self.container).inset(10);
        make.height.mas_equalTo(136);
    }];

    [self.deviceInfoNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceStorageInfoView.mas_top).offset(15);
        make.right.mas_equalTo(self.deviceStorageInfoView).offset(-16);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(16);
    }];

    [self.settingItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deviceStorageInfoView.mas_bottom).inset(10);
        make.right.mas_equalTo(self.container);
        make.left.mas_equalTo(self.container);
        make.height.mas_equalTo([self.settingItemView getDataNum] * 60);
    }];
    
}

- (UIView *)sloganView {
    if (!_sloganView) {
        UIView * conView = [[UIView alloc] init];
        conView.backgroundColor = ESColor.secondarySystemBackgroundColor;
        conView.layer.masksToBounds = YES;
        conView.layer.cornerRadius = 10;
        [self.view addSubview:conView];

        
        UIView * view = [UIView es_sloganView:NSLocalizedString(@"common_encrypted_main", @"多重安全技术，保护数据隐私")];
        [conView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_greaterThanOrEqualTo(conView).inset(20);
            make.trailing.mas_lessThanOrEqualTo(conView).inset(-20);
            make.top.mas_equalTo(conView);
            make.bottom.mas_equalTo(conView).offset(-10);
            make.centerX.mas_equalTo(conView);
        }];
        
        _sloganView = conView;
    }
    return _sloganView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect frame = self.view.bounds;
    [self.container layoutIfNeeded];
    frame.size.height = CGRectGetMaxY(self.settingItemView.frame) + kStatusBarHeight + 10;
    self.container.frame = frame;
}

- (void)personalInfo {
    if (ESBoxManager.activeBox.supportNewBindProcess) {
        ESPersonalSpaceInfoVC *next = [ESPersonalSpaceInfoVC new];
        next.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }
    ESPersonalInfoViewController *next = [ESPersonalInfoViewController new];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)checkBoxSupportNewBind {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
   
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-agent-service"
                                                    apiName:@"internet_service_get_config"
                                                queryParams:@{@"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
                                                              @"aoId" : ESSafeString(dic[@"aoId"])
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@"ESInternetServiceConfigModel"
                                               successBlock:^(NSInteger requestId, ESInternetServiceConfigModel *_Nullable response) {
        ESBoxManager.activeBox.enableInternetAccess = response.enableInternetAccess;
        if (ESBoxManager.activeBox.supportNewBindProcess == NO) {
            ESBoxManager.activeBox.supportNewBindProcess = YES;
            [ESBoxManager.manager saveBox:ESBoxManager.activeBox];
        }
        if (response.userDomain.length > 0 &&
            ![response.userDomain isEqualToString:ESSafeString(ESBoxManager.activeBox.info.userDomain)]) {
            ESBoxManager.activeBox.info.userDomain = response.userDomain;
        }
        [ESBoxManager.manager saveBox:ESBoxManager.activeBox];
       
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
    }];
}

- (void)updateDIDDocInfo {
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-agent-service"
                                                    apiName:@"get_did_document"
                                                queryParams:@{@"clientUUID" : ESSafeString(ESBoxManager.clientUUID),
                                                              @"aoId" : ESSafeString(dic[@"aoId"])
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, NSDictionary *_Nullable response) {
        [[ESDIDDocManager shareInstance] saveOrUpdateDIDDocBase64Str:response[@"didDoc"]
                                                encryptedPriKeyBytes:response[@"encryptedPriKeyBytes"]
                                                                 box:box];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
    }];
}

- (void)deviceManager {
    ESLoginTerminalVC *vc = [ESLoginTerminalVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearCache {
    [ESCacheCleanTools clearAllCache];
    [ESToast toastSuccess:TEXT_ME_ALREADY_CLEARED_CACHE];
    self.cacheSize = @"0.00B";
    [ESCacheCleanTools cacheSizeWithCompletion:^(NSString *size) {
        self.cacheSize = size;
    }];
}

- (void)about {
    ESAboutViewController *next = [ESAboutViewController new];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)onSetting:(ESFormItem *)item action:(ESFormViewAction)action {
    switch (item.row) {
        //
        case ESSettingCellTypeDevice:
            [self deviceManager];
            break;
        case ESSettingCellTypeRecycleBin: {
            ESRecycleBinVC *vc = [[ESRecycleBinVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case ESSettingCellTypeLogin: {
            ESLoginTerminalVC *vc = [[ESLoginTerminalVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case ESSettingCellTypeCache: {
            //清除缓存    mine.click.clearCache
            NSString *title = [NSString stringWithFormat:TEXT_ME_CONFIRM_THE_DELETION_TITLE, self.cacheSize];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:title
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:TEXT_CONFIRM_THE_DELETION
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *_Nonnull action) {
                                                                [self clearCache];
                                                            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:TEXT_CANCEL
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *_Nonnull action){

                                                           }];

            [alert addAction:confirm];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];

        } break;
        case ESSettingCellTypeContactEmail: {
            [self sendMail];
            break;
        }
           
        case ESSettingCellTypeTrialFeedback: {
            __weak typeof(self) weakSelf = self;
            ESDeviceInfoModel *deviceInfo = [[ESCache defaultCache] objectForKey:ESBoxManager.activeBox.boxUUID];
            if(deviceInfo.systemInfo.spaceVersion){
                NSInteger isWebFeedback = [ESCommonToolManager compareVersion:FeedbackVersionH5 withVersion:deviceInfo.systemInfo.spaceVersion];
                if(isWebFeedback == 1){
                    ESFeedbackViewController *vc = [ESFeedbackViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                
                    [[ESCommonToolManager manager] toWebFeedbackWithImage:nil];
                }
            }else{
                [ESDeviceInfoServiceModule getDeviceInfoWithCompletion:^(ESDeviceInfoResultModel * _Nullable deviceInfoResult, NSError * _Nullable error) {
                    __strong typeof(weakSelf) self = weakSelf;
                    if (!error && deviceInfoResult) {
                        NSInteger isWebFeedback = [ESCommonToolManager compareVersion:FeedbackVersionH5 withVersion:deviceInfoResult.spaceVersion];
                        if(isWebFeedback == 1){
                            ESFeedbackViewController *vc = [ESFeedbackViewController new];
                            [self.navigationController pushViewController:vc animated:YES];
                        }else{
                            [[ESCommonToolManager manager] toWebFeedbackWithImage:nil];
                        }
                    }else{
                        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                    }
                }];
            }
        }
        break;
        case ESSettingCellTypeFAQ: {
            //查看帮助内容    mine.click.viewHelp
            ///帮助与反馈
            ESWebContainerViewController *next = [ESWebContainerViewController new];
            NSString *baseUrl = ESPlatformClient.platformClient.platformUrl;
            NSString *s_help;
            BOOL result = [baseUrl hasSuffix:@"/"];
            if(result){
                s_help = [NSString stringWithFormat:@"%@%@support/help",baseUrl ,[ESCommonToolManager isEnglish] ? @"en/" : @""];
             }else{
                s_help = [NSString stringWithFormat:@"%@/%@support/help",baseUrl ,[ESCommonToolManager isEnglish] ? @"en/" : @""];
             }
        
            next.webUrl = s_help;
            next.webTitle = TEXT_HOME_HELP;
            next.hideNavigationBar = NO;
//            next.insets = UIEdgeInsetsMake(-kTopHeight, 0, 0, 0);
            [next registerAction:@"onClickExit"
                        callback:^(id body) {
                            [self goBack];
                        }];
            [next registerAction:@"onClickFeedback"
                        callback:^(id body) {
                            ESFeedbackViewController *next = [ESFeedbackViewController new];
                            [self.navigationController pushViewController:next animated:YES];
                        }];
            [self.navigationController pushViewController:next animated:YES];
        } break;
            
        case ESSettingCellTypeWeb: {
            if (action == ESFormViewActionArrow) {
                //复制web端链接    mine.click.copyLink
                UIPasteboard.generalPasteboard.string = item.content;
                [ESToast toastInfo:TEXT_ME_WEB_COPY];
            }
        } break;
        case ESSettingCellTypeNews: {
            ESPushNewsSettingVC *pushVC = [ESPushNewsSettingVC new];
            [self.navigationController pushViewController:pushVC animated:YES];
        } break;
            
        case ESSettingCellTypeAbout:
            [self about];
            break;
        case ESSettingCellTypeSetting: {
            ESMeSettingV2 * meSetting = [ESMeSettingV2 new];
            //ESMeSettingController * meSetting = [ESMeSettingController new];
            [self.navigationController pushViewController:meSetting animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)sendMail {
    //先验证邮箱能否发邮件，不然会崩溃
    if (![MFMailComposeViewController canSendMail]) {
        [ESToast toastWarning:NSLocalizedString(@"es_no_email_app", @"")];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    //收件人邮箱，使用NSArray指定多个收件人
    NSArray *toRecipients = [NSArray arrayWithObject:@"service@ao.space"];
    [picker setToRecipients:toRecipients];
    //邮件主题
//    [picker setSubject:title];
    //邮件正文，如果正文是html格式则isHTML为yes，否则为no
//    [picker setMessageBody:content isHTML:NO];
    //添加附件，附件将附加到邮件的结尾
//    NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"icon.jpg"], 1.0);
//    [picker addAttachmentData:data mimeType:@"image/jpeg" fileName:@"new.png"];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    NSString *tipMsg = @"";
    switch (result) {
        case MFMailComposeResultCancelled:
            tipMsg = NSLocalizedString(@"Mail sending canceled", @"邮件发送取消");
            break;
        case MFMailComposeResultSaved:
            tipMsg = NSLocalizedString(@"Mail saved successfully", @"邮件保存成功");
            break;
        case MFMailComposeResultSent:
            tipMsg = NSLocalizedString(@"Mail sent successfully", @"邮件发送成功");
            break;
        case MFMailComposeResultFailed:
            tipMsg = NSLocalizedString(@"Failed to send email", @"邮件发送失败");
            break;
        default:
            tipMsg = NSLocalizedString(@"Mail not sent", @"邮件未发送");
            break;
    }
    [ESToast toastInfo:tipMsg];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Load

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    return _container;
}

- (ESMeHeader *)header {
    if (!_header) {
        _header = [ESMeHeader new];
        [self.container addSubview:_header];
        [_header addTarget:self action:@selector(personalInfo) forControlEvents:UIControlEventTouchUpInside];
    };
    return _header;
}

- (ESDeviceStorageInfoView *)deviceStorageInfoView {
    if (!_deviceStorageInfoView) {
        ESDeviceStorageInfoView * view = [[ESDeviceStorageInfoView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [view hiddenCPUMemView];
        [self.container addSubview:view];
        _deviceStorageInfoView = view;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deviceManager)];
        [view addGestureRecognizer:tap];
    }
    return _deviceStorageInfoView;
}

- (UIView *)deviceInfoNumView {
    if (!_deviceInfoNumView) {
        _deviceInfoNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
//        _deviceInfoNumView.backgroundColor = [UIColor es_colorWithHexString:@"#F6222D"];
        _deviceInfoNumView.layer.masksToBounds = YES;
        _deviceInfoNumView.layer.cornerRadius = 8;
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        numLabel.textColor = ESColor.lightTextColor;
        numLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:8];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = @"1";
        [_deviceInfoNumView addSubview:numLabel];
        [self.deviceStorageInfoView addSubview:_deviceInfoNumView];
    }
    return _deviceInfoNumView;
}

- (ESSettingItemView *)settingItemView {
    if (!_settingItemView) {
        _settingItemView = [ESSettingItemView new];
        [self.container addSubview:_settingItemView];
        weakfy(self);
        _settingItemView.actionBlock = ^(ESFormItem *item, NSNumber *action) {
            strongfy(self);
            [self onSetting:item action:(ESFormViewAction)action.integerValue];
        };
    }
    return _settingItemView;
}

- (void)checkVersionServiceApi {
    self.deviceInfoNumView.hidden = YES;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    ESSpaceGatewayVersionCheckingServiceApi *clientResultApi = [ESSpaceGatewayVersionCheckingServiceApi new];
    [clientResultApi spaceV1ApiGatewayVersionBoxGetWithAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
                                                       appType:@"ios"
                                                       version:appVersion
                                             completionHandler:^(ESResponseBasePackageCheckRes *output, NSError *error) {
                                                 if (!error) {
                                                     BOOL isVarNewVersionExist = output.results.varNewVersionExist.boolValue;
                                                     self.isVarNewVersionExist = isVarNewVersionExist;
                                                     if (isVarNewVersionExist && [ESMemberManager isAdmin]) {
                                                         self.deviceInfoNumView.hidden = NO;
                                                     } else {
                                                         self.deviceInfoNumView.hidden = YES;
                                                     }
                                                 }
                                             }];
    
    ESBoxItem *box = ESBoxManager.activeBox;
    NSDictionary *dic = [ESBoxManager cacheInfoForBox:box];
    NSString *userDomain = dic[@"userDomain"];

    if(ESBoxManager.activeBox.boxType == ESBoxTypeAuth && userDomain.length < 1){
        ESAccountServiceApi *accountServiceApi = [[ESAccountServiceApi alloc] init];
        [accountServiceApi spaceV1ApiMemberListGetWithCompletionHandler:^(ESResponseBaseArrayListAccountInfoResult *output, NSError *error) {
            if (!error) {
                ESResponseBaseArrayListAccountInfoResult *data = output;
                NSArray<ESAccountInfoResult> *results = data.results;
                for (ESAccountInfoResult *result in results) {
                    if([ESAccountManager.manager.userInfo.personalName isEqual:result.personalName]){
                        ESBoxItem *box = ESBoxManager.activeBox;
                        ESBoxItem *matchBoxItem = [ESBoxManager.manager getBoxItemWithBoxUuid:box.boxUUID boxType:box.boxType aoid:box.aoid];
                        if (matchBoxItem == nil) {
                            return;
                        }
                        matchBoxItem.info.userDomain = result.userDomain;
                        [ESBoxManager.manager saveBoxList];
                        return;
                    }
                }
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}

- (UIImageView *)new {
    if (!_new) {
        _new = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 44 - 14 , kStatusBarHeight + 5, 44, 44)];
        _new = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 44 - 14 , kStatusBarHeight + 5, 44, 44)];
        _new.image = IMAGE_ME_NEWS_HEAD;
        _new.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView:)];
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:_new];
        self.navigationItem.rightBarButtonItem = confirmItem;
        [_new addGestureRecognizer:tap];
    }
    return _new;
}

- (UIView *)redNewPointView {
    if (!_redNewPointView) {
        _redNewPointView = [UIView new];
        _redNewPointView.layer.cornerRadius = 4;
        _redNewPointView.layer.masksToBounds = YES;
        _redNewPointView.backgroundColor = ESColor.redColor;
        [self.new addSubview:_redNewPointView];
    }
    return _redNewPointView;
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)tapImgView:(UITapGestureRecognizer *)tap {
    ESMeNewListVC1 *vc = [ESMeNewListVC1 new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)fetchDeviceInfo:(BOOL)showLoading {
    __weak typeof(self) weakSelf = self;
    if (showLoading) {
        ESToast.waiting(NSLocalizedString(@"waiting_operate", @"请稍后")).delay(60).showFrom(self.view);
    }
    
    [ESDeviceInfoServiceModule getDeviceInfoWithCompletion:^(ESDeviceInfoResultModel * _Nullable deviceInfoResult, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [ESToast dismiss];
        if (!error && deviceInfoResult) {
            ESDeviceInfoModel *deviceInfo = [ESDeviceInfoModel new];
            [deviceInfo updateWithDeviceInfoResultModel:deviceInfoResult];
            [[ESCache defaultCache] setObject:deviceInfo forKey:ESBoxManager.activeBox.boxUUID];
        }
    }];
}

@end
