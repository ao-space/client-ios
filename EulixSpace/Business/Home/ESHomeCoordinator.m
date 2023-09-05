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
//  ESHomeCoordinator.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESHomeCoordinator.h"
#import "AppDelegate.h"
#import "ESAppForceUpgradeViewController.h"
#import "ESBoxListViewController.h"
#import "ESBoxManager.h"
#import "ESFileHomePageVC.h"
#import "ESLaunchManager.h"
#import "ESLaunchlntroductionVC.h"
#import "ESLocalNetworking.h"
#import "ESMeViewController.h"
#import "ESSessionClient.h"
#import "ESTabBarController.h"
#import "NSString+ESTool.h"
#import "ESCommonToolManager.h"
#import "ESTabBar.h"

@interface ESTabBarController ()

@property (nonatomic, strong) ESTabBar *ylTabBar;

- (void)tabBar:(ESTabBar *)tabBar clickCenterButton:(UIButton *)sender;

@end

@interface ESDDLogFileManagerDefault : DDLogFileManagerDefault
@property (nonatomic, strong) NSDateFormatter * dateFormatter;
@end

@implementation ESDDLogFileManagerDefault

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"MMdd_HH_mm_ss"];
        _dateFormatter = dateFormatter;
    }
    return _dateFormatter;
}

- (NSString *)newLogFileName {
//    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *formattedDate = [self.dateFormatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"AoSpace%@.log", formattedDate];
}


- (BOOL)isLogFile:(NSString *)fileName {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

    // We need to add a space to the name as otherwise we could match applications that have the name prefix.
    BOOL hasProperPrefix = [fileName hasPrefix:appName];
    BOOL hasProperSuffix = [fileName hasSuffix:@".log"];

    return (hasProperPrefix && hasProperSuffix);
}

@end

@interface ESDDLogFileFormatterDefault : DDLogFileFormatterDefault {
    NSDateFormatter *_dateFormatter;
}
- (instancetype)init;
- (instancetype)initWithDateFormatter:(nullable NSDateFormatter *)aDateFormatter;
@end

@implementation ESDDLogFileFormatterDefault

- (instancetype)init {
    return [self initWithDateFormatter:nil];
}

- (instancetype)initWithDateFormatter:(nullable NSDateFormatter *)aDateFormatter {
    if (self = [super initWithDateFormatter:aDateFormatter]) {
        if (aDateFormatter) {
            _dateFormatter = aDateFormatter;
        } else {
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4]; // 10.4+ style
    //            [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    //            [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [_dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
        }
    }
    
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *dateAndTime = [_dateFormatter stringFromDate:logMessage->_timestamp];

    return [NSString stringWithFormat:@"%@  %@", dateAndTime, logMessage->_message];
}

@end

@interface AppDelegate ()

//@property (nonatomic, strong) ESAddMumberView *addMumberView;

@end

@interface ESHomeCoordinator () <ESChatEventProtocol>

@property (nonatomic, strong) UIWindow *window;

@property (strong, nonatomic) UIImage *testImg;

@property (strong, nonatomic) ESCompatibleCheckRes *compatibleInfo;

@end

@implementation ESHomeCoordinator

+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (UITabBarController *)mainTab {
    ESTabBarController *tabbarVc = [[ESTabBarController alloc] init];
    tabbarVc.view.backgroundColor = [UIColor whiteColor];

    YCNavigationController *fileVC = [[YCNavigationController alloc]
        initWithRootViewController:[[ESFileHomePageVC alloc] init]];
    [self setChildVc:fileVC withTitle:TEXT_HOME_FILE image:@"tabbar_icon_file" selectedImage:@"tabbar_icon_file_selected"];

    
    YCNavigationController *discoverVc = [[YCNavigationController alloc]
        initWithRootViewController:[[ESMeViewController alloc] init]];
    [self setChildVc:discoverVc withTitle:TEXT_HOME_MINE image:@"tabbar_icon_me" selectedImage:@"tabbar_icon_me_selected"];
    // 4. 添加子控制器
    tabbarVc.viewControllers = @[fileVC, discoverVc];
    tabbarVc.tabBar.backgroundColor = [UIColor whiteColor];
    UIView *bgView = [[UIView alloc] initWithFrame:tabbarVc.tabBar.bounds];
    // 给自定义 View 设置颜色
    bgView.backgroundColor = [UIColor whiteColor];
    tabbarVc.tabBar.backgroundImage = [[UIImage alloc] init];
    tabbarVc.tabBar.shadowImage = [[UIImage alloc] init];
    // 将自定义 View 添加到 tabBar 上
    [tabbarVc.tabBar insertSubview:bgView atIndex:0];
    return tabbarVc;
}

+ (void)showHome {
    if (ESHomeCoordinator.sharedInstance.compatibleInfo) {
        return;
    }
    if ([self activeBoxVailed]) {
        UITabBarController *tabbarVc = [self mainTab];
        ESHomeCoordinator.sharedInstance.window.rootViewController = tabbarVc;
        [NSNotificationCenter.defaultCenter postNotificationName:@"switchBoxNSNotification" object:nil];
//        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
//        if (appDelegate.addMumberView.hidden == NO) {
//            [appDelegate.addMumberView.superview bringSubviewToFront:appDelegate.addMumberView];
//        }
    } else {
        YCNavigationController *rootVC = (YCNavigationController *)ESHomeCoordinator.sharedInstance.window.rootViewController;
        if ([rootVC isKindOfClass:[YCNavigationController class]] && [rootVC.viewControllers.firstObject isKindOfClass:[ESBoxListViewController class]]) {
            
        } else {
            ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
            ESHomeCoordinator.sharedInstance.window.rootViewController = [[YCNavigationController alloc] initWithRootViewController:boxVC];
        }
    }
}

+ (BOOL)activeBoxVailed {
    if (ESBoxManager.activeBox.enableInternetAccess == NO && ESBoxManager.activeBox.localHost.length > 0) {
        return YES;
    }
    return ESBoxManager.activeBox.prettyDomain.length > 0;
}

+ (void)showLogin {
    ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
    ESHomeCoordinator.sharedInstance.window.rootViewController = [[YCNavigationController alloc] initWithRootViewController:boxVC];
}

+ (void)showForceUpgrade:(ESCompatibleCheckRes *)compatibleInfo {
    [ESLocalNetworking.shared stopMonitor];
    ESHomeCoordinator.sharedInstance.compatibleInfo = compatibleInfo;
    ESAppForceUpgradeViewController *next = [ESAppForceUpgradeViewController new];
    next.info = compatibleInfo;
    ESHomeCoordinator.sharedInstance.window.rootViewController = [[YCNavigationController alloc] initWithRootViewController:next];
}

+ (void)setChildVc:(YCNavigationController *)vc withTitle:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        UIImage *backArrow = [IMAGE_IC_BACK_CHEVRON imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, -16, 0, 0)];
        [appearance configureWithTransparentBackground];
        [appearance setBackIndicatorImage:backArrow transitionMaskImage:backArrow];
        vc.navigationBar.standardAppearance = appearance;
        vc.navigationBar.scrollEdgeAppearance = appearance;
    }
    vc.tabBarItem.title = title;
    
    if(title.length < 1 || [title isEqual:@"通讯录"]){
        vc.tabBarItem.titlePositionAdjustment = UIOffsetZero;

        // 假设图片宽度为 30，高度为 30，如果高度不是 30，请按照实际值计算和调整 UIEdgeInsets 中的数值
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0); // 使图片上移 6 个像素
        
        UIImage *image;
        if([ESCommonToolManager isEnglish]){
            image = [[UIImage imageNamed:@"shouye_en"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }else{
            image = [[UIImage imageNamed:@"shouye_2.0"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        vc.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
        NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
        [vc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
        [vc.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
        vc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 0);
        
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -8, 0);
        [vc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
        //UISwitch
        UISwitch.appearance.onTintColor = ESColor.primaryColor;
        vc.tabBarItem.title = nil;
        
    }else{
        
        NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
        // textAttrs[NSForegroundColorAttributeName] = DJColor(123, 123, 123);
        NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
        [vc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
        [vc.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
        vc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 0);
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [vc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
        //UISwitch
        UISwitch.appearance.onTintColor = ESColor.primaryColor;
    }
    
    vc.topViewController.hidesBottomBarWhenPushed = NO;
    // 设置tabbarItem 选中图片
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置tabarItem 选中颜色

}

+ (UIWindow *)keyWindow {
    if (ESHomeCoordinator.sharedInstance.window) {
        return ESHomeCoordinator.sharedInstance.window;
    }
    return [ESHomeCoordinator.sharedInstance setup];
}

- (void)setDefaultTheme {
    UIImage *backArrow = [IMAGE_IC_BACK_CHEVRON imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, -16, 0, 0)];
    [UINavigationBar.appearance setBackIndicatorImage:backArrow];
    [UINavigationBar.appearance setBackIndicatorTransitionMaskImage:backArrow];
    [UINavigationBar.appearance setTranslucent:YES];
    [UINavigationBar.appearance setBackgroundColor:ESColor.lightTextColor];
    [UINavigationBar.appearance setBarTintColor:ESColor.lightTextColor];
    [UINavigationBar.appearance setShadowImage:[UIImage new]];
    [UIBarButtonItem.appearance setTintColor:ESColor.labelColor];

    [ESToast setDefaultTheme];

    if (@available(iOS 14.0, *)) {
        UIBackgroundConfiguration *bgConfig = [UIBackgroundConfiguration listPlainCellConfiguration];
        bgConfig.backgroundColor = UIColor.whiteColor;
        UITableViewHeaderFooterView.appearance.backgroundConfiguration = bgConfig;
    }
}

- (UIWindow *)setup {
//Log
#ifdef DEBUG
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // TTY = Xcode console

    NSString *documents = [[[[NSFileManager defaultManager]
        URLsForDirectory:NSDocumentDirectory
               inDomains:NSUserDomainMask] lastObject] path];
    NSString *logDir = [documents stringByAppendingString:@"/Logs"];
    ESDDLogFileManagerDefault *documentsFileManager = [[ESDDLogFileManagerDefault alloc]
        initWithLogsDirectory:logDir];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:documentsFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 50;
    fileLogger.doNotReuseLogFiles = YES;
    fileLogger.logFormatter = [ESDDLogFileFormatterDefault new];
    [DDLog addLogger:fileLogger];
#endif

    [ESLaunchManager manager];
    //[self listenSocket];
    [self setDefaultTheme];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = ESColor.systemBackgroundColor;
    UIViewController *mianvc;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        mianvc = [[ESLaunchlntroductionVC alloc] init];
        YCNavigationController *navController = [[YCNavigationController alloc] initWithRootViewController:mianvc];
        self.window.rootViewController = navController;
    } else {
        if (ESBoxManager.manager.justLaunch) {
            ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
            self.window.rootViewController = [[YCNavigationController alloc] initWithRootViewController:boxVC];
        } else {
            if (ESBoxManager.activeBox.prettyDomain.length > 0) {
                self.window.rootViewController = [ESHomeCoordinator mainTab];
            } else {
                ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
                self.window.rootViewController = [[YCNavigationController alloc] initWithRootViewController:boxVC];
            }
        }
    }
    return self.window;
}

- (void)listenSocket {
    [ESSessionClient.sharedInstance addObserver:self forEvent:(ESSessionEventTypeReceiveMessage)];
}

- (void)chatClient:(ESSessionClient *)client receiveMessage:(ESSessionMessage *)message {
    NSDictionary *result = message.result;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:result[@"title"] message:[NSString convertToJsonData:message.result] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:(UIAlertActionStyleCancel)handler:^(UIAlertAction *_Nonnull action) {
                                                     [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                                                 }];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [alert addAction:ok];
    [self.window.rootViewController presentViewController:alert
                                                 animated:YES
                                               completion:^{

                                               }];
}

- (BOOL)canHandleMessage:(ESSessionMessage *)message {
    return YES;
}

+ (void)showAddFileVC {
    ESTabBarController * tabVC = (ESTabBarController *)[ESHomeCoordinator sharedInstance].window.rootViewController;
    if ([tabVC isKindOfClass:[ESTabBarController class]]) {
        [tabVC tabBar:tabVC.ylTabBar clickCenterButton:nil];
    }
}

@end
