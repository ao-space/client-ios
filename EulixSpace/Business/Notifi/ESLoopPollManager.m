//
//  ESLoopPollManager.m
//  EulixSpace
//
//  Created by dazhou on 2023/7/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLoopPollManager.h"
#import "ESGatewayManager.h"
#import "ESSpaceGatewayNotificationServiceApi.h"
#import "ESAES.h"
#import "ESNotifiManager.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESAutoConfirmVC.h"
#import "ESBoxManager.h"
#import "ESImageDefine.h"
#import "ESLocalizableDefine.h"
#import "ESBoxListViewController.h"
#import "ESCache.h"

@interface ESLoopPollManager()
@property (nonatomic, assign) BOOL appActive;
@property (nonatomic, assign) BOOL isLooping;

@property (nonatomic, strong) NSArray * systemInfoList;
@property (nonatomic, strong) NSArray * businessInfoList;

@end

@implementation ESLoopPollManager

+ (ESLoopPollManager *)Instance {
    static dispatch_once_t onceToken;
    static ESLoopPollManager * sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        self.appActive = YES;
    }
    return self;
}

- (void)onBecomeActiveNotification {
    self.appActive = YES;
    [self loop];
}

- (void)onEnterBackgroundNotification {
    self.appActive = NO;
}

-(void)start {
    [self loop];
}

-(void)loop {
    if (!self.appActive || self.isLooping) {
        return;
    }
    self.isLooping = YES;
    ESDLog(@"[poll] [loop] start");
    [ESGatewayManager token:^(ESTokenItem *token, NSError *error) {
        if (!token) {
            ESDLog(@"[poll] [loop] no token %@", error);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isLooping = NO;
                [self loop];
            });
            return;
        }
        
        ESSpaceGatewayNotificationServiceApi *api =  [[ESSpaceGatewayNotificationServiceApi alloc] init];
        [api setDefaultHeaderValue:@"no-cache" forKey:@"Cache-Control"];
        [api spaceV1ApiGatewayPollGetWithAccessToken:token.accessToken count:@"1" completionHandler:^(ESStatusResult *output, NSError *error) {
            if (error) {
                ESDLog(@"[poll] [loop] error: %@", error);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isLooping = NO;
                    [self loop];
                });
                return;
            }
            
            if(![output.status isEqual:@"ok"]) {
                ESDLog(@"[poll] [loop] output.status not ok");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isLooping = NO;
                    [self loop];
                });
                return;
            }
            
            ESDLog(@"[poll] [loop] output: %@", output);
            NSString *str = [output.message aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
            /// 解析不出来？
            if(output.message.length > 0 && str.length < 1){
                ESGatewayManager *gatewayManager = [ESGatewayManager new];
                [gatewayManager refreshToken:ESBoxManager.activeBox callback:^(ESTokenItem *token, NSError *error) {
                    NSString *strToken = [output.message aes_cbc_decryptWithKey:token.secretKey iv:token.secretIV];
                    [self processInfo:strToken];
                }];
            } else if(str.length > 1){
                [self processInfo:str];
            }
            self.isLooping = NO;
            [self loop];
        }];
    }];
}

- (void)processInfo:(NSString *)str {
    NSArray *msgArray = [self convert2DictionaryWithJSONString:str];
    NSDictionary *dic = [msgArray firstObject];
    
    ESDLog(@"[poll] [loop] userInfo: %@", dic);
    NSString *optType = dic[@"optType"];
    ESDLog(@"[poll] [loop] optType: %@", optType);
    if (![self isReceiveSystemInfo] && [self.systemInfoList containsObject:optType]) {
        return;
    }
    if (![self isReceiveBusinessInfo] && [self.businessInfoList containsObject:optType]) {
        return;
    }
    
    if ([ESNotifiManager processNotifi:dic]) {
        ESDLog(@"[poll] [loop] ESNotifiManager");
    } else if([optType isEqual:@"login_confirm"]){
        UIViewController *topVC = [UIWindow getCurrentVC];
        if(![topVC isKindOfClass:[ESAutoConfirmVC class]]){
            NSString *jsonStr = dic[@"data"];
            NSDictionary *josnDic = [self convertDictionaryWithJSONString:jsonStr];
            ESAutoConfirmVC *vc= [ESAutoConfirmVC new];
            vc.aoid = josnDic[@"aoId"];
            vc.clientUUID = josnDic[@"uuid"];
            [topVC presentViewController:vc animated:YES completion:^{
            }];
        }
    }
    else if([optType isEqual:@"login"] || [optType isEqual:@"login_confirm"]){
        [self loginConfirm:dic optType:optType];
    } else if([dic[@"optType"] isEqual:@"revoke"]|| [dic[@"optType"] isEqual:@"logout"]){
        [self processRevoke];
    } else if([optType isEqual:@"restore_success"]){
        [self loginConfirm:dic optType:optType];
    } else if([optType isEqual:@"backup_progress"]){
        NSDictionary *data = [self convertDictionaryWithJSONString:dic[@"data"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"backupProgressNotification" object:data];
    }
    else {
        if(dic.count > 0){
            NSDictionary *dataDic = [self convertDictionaryWithJSONString:dic[@"data"]];
            NSString *aoid = dataDic[@"aoId"];
            if (aoid.length > 0) {
                [self pushNewsAlertAction:dic[@"title"] contentStr:dic[@"text"] optType:dic[@"optType"] aoid:dataDic[@"aoId"]];
            }else{
                [self pushNewsAlertAction:dic[@"title"] contentStr:dic[@"text"] optType:dic[@"optType"] aoid:dataDic[@"aoid"]];
            }
        }
    }
}

- (void)processRevoke {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"logout_title", "下线通知") message:NSLocalizedString(@"logout_content", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:TEXT_COMMON_OK
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *_Nonnull action) {
        if(![[UIWindow getCurrentVC] isKindOfClass:[ESBoxListViewController class]]) {
            ESBoxListViewController *vc = [ESBoxListViewController new];
            [[UIWindow getCurrentVC].navigationController pushViewController:vc animated:YES];
        }
    }];
    //3.将动作按钮 添加到控制器中
    [alert addAction:conform];
    //4.显示弹框
    [[UIWindow getCurrentVC] presentViewController:alert animated:YES completion:nil];
}


-(void)loginConfirm:(NSDictionary * )dic optType:(NSString * )optType {
    UIImageView *topView ;
    UIButton *btn ;
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(28, 28, 16, 16)];
    if ([optType isEqual:@"restore_success"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reStoreInProgress"];
        topView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, ScreenWidth-10, 120)];
        iconImage.image = [UIImage imageNamed:@"main_gengxin"];
        UILabel *pointOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 45, 229, 46)];
        pointOutLabel.text = dic[@"text"];
        pointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        pointOutLabel.numberOfLines = 0;
        pointOutLabel.textColor = [ESColor secondaryLabelColor];
        pointOutLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:pointOutLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 24, 229, 22)];
        titleLabel.text = dic[@"title"];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        titleLabel.textColor = [ESColor labelColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:titleLabel];
    }else{
        topView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, ScreenWidth-10, 70)];
        iconImage.image = IMAGE_PUSH_LOGIN_ICON;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(273, 22, 84, 26)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 24, 229, 22)];
        titleLabel.text = dic[@"text"];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        titleLabel.textColor = [ESColor labelColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:titleLabel];
    }
    
    [topView addSubview:iconImage];
    [btn setTitle:TEXT_VIEW_NOW forState:UIControlStateNormal];
    [btn setBackgroundColor:ESColor.pushBgColor];
    [btn setTitleColor:ESColor.pushTitleColor forState:UIControlStateNormal];
    btn.layer.cornerRadius = 13;
    btn.layer.masksToBounds = YES;
    btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [topView addSubview:btn];
    
    topView.tag = 90001;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:topView];
    topView.image = IMAGE_PUSH_BG;
    
    topView.image = IMAGE_PUSH_BG;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        topView.hidden = YES;
        [[window viewWithTag:90001] removeFromSuperview];
    });
}


-(void)pushNewsAlertAction:(NSString *)title contentStr:(NSString *)contentStr optType:(NSString *)optType aoid:(NSString *)aoid{
    ESDLog(@"pushNewsAlertAction %@ -- contentStr: %@ optType:%@  aoid:%@", title, contentStr,optType, aoid);
    if ([ESBoxManager.activeBox.deviceAbilityModel isOnlineTrialBox]) {
        //在线试用用户不接受推送相关交互处理
        return;
    }
    if([aoid isEqual:ESBoxManager.activeBox.aoid] ){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isHaveNews"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:contentStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:TEXT_COMMON_OK
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action) {
            if([optType isEqual:@"logout"] && ESBoxManager.activeBox.boxType == ESBoxTypeAuth){
                if(![[UIWindow getCurrentVC] isKindOfClass:[ESBoxListViewController class]]){
                    ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
                    boxVC.navigationItem.hidesBackButton=YES;
                    [[UIWindow getCurrentVC].navigationController pushViewController:boxVC animated:YES];
                }
                return;
            }

           
            [[ESBoxManager manager] revokePush:ESBoxManager.activeBox];
            if(![[UIWindow getCurrentVC] isKindOfClass:[ESBoxListViewController class]]){
                ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
                [[UIWindow getCurrentVC].navigationController pushViewController:boxVC animated:YES];
      
            }
        }];
        //3.将动作按钮 添加到控制器中
        [alert addAction:conform];
        //4.显示弹框
        [[UIWindow getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
}

-(NSArray *)convert2DictionaryWithJSONString:(NSString *)jsonString{
    NSArray *array;
    if(jsonString.length > 0){
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        array = [NSJSONSerialization JSONObjectWithData:jsonData
        options:NSJSONReadingMutableContainers
        error:&err];
        if (err) {
            return nil;
        }
    }
    return array;
}

-(NSDictionary *)convertDictionaryWithJSONString:(NSString *)jsonString{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
    options:NSJSONReadingMutableContainers
    error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}


- (void)setSystemInfo:(BOOL)isReceive {
    [ESCache.defaultCache setObject:@(isReceive) forKey:@"ESAppSystemInfoLoopKey"];
}

- (BOOL)isReceiveSystemInfo {
    id value = [ESCache.defaultCache objectForKey:@"ESAppSystemInfoLoopKey"];
    if (value) {
        return [value boolValue];
    }
    
    return YES;
}

- (void)setBusinessInfo:(BOOL)isReceive {
    [ESCache.defaultCache setObject:@(isReceive) forKey:@"ESAppBusinessInfoLoopKey"];
}

- (BOOL)isReceiveBusinessInfo {
    id value = [ESCache.defaultCache objectForKey:@"ESAppBusinessInfoLoopKey"];
    if (value) {
        return [value boolValue];
    }
    
    return YES;
}

- (NSArray *)systemInfoList {
    if (!_systemInfoList) {
        _systemInfoList = @[@"box_upgrade",
                            @"app_upgrade",
                            @"invite_reward",
                            @"feedback_reward"];
    }
    return _systemInfoList;
}

- (NSArray *)businessInfoList {
    if (!_businessInfoList) {
        _businessInfoList = @[@"login",
                              @"logout",
                              @"revoke",
                              @"member_join",
                              @"member_delete",
                              @"member_self_delete",
                              @"upgrade_success",
                              @"security_passwd_mod_succ",
                              @"security_passwd_reset_succ",
                              @"security_email_set_succ",
                              @"security_email_mod_succ",
                              @"upgrade_download_success",
                              @"upgrade_installing",
                              @"restore_success",
                              @"memories",
                              @"today_in_his",
                              @"ups_exhausted",
                              @"ups_shutdown_abnormal",
                              @"ups_disconnected",
                              @"ups_reconnected",
                              @"ups_onbattery",
                              @"ups_power_restored",
                              @"cpu_hightemp",
                              @"fanspeed_zero",
                              @"disk_hightemp",
                              @"disk_smart_err"
        ];
    }
    return _businessInfoList;
}

@end
