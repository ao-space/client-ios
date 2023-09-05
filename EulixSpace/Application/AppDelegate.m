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
//  AppDelegate.m
//  EulixSpace
//
//  Created by qu on 2021/5/20.
//

#import "AppDelegate.h"
#import "ESFeedbackImagItem.h"
#import "ESFeedbackViewController.h"
#import "ESGlobalMacro.h"
#import "ESHomeCoordinator.h"
#import "ESImageDefine.h"
#import "ESLocalPath.h"
#import "ESNetworking.h"
#import "ESToast.h"
#import "ESAutoConfirmVC.h"
#import "ESCommonToolManager.h"
#import "ESSpaceGatewayNotificationServiceApi.h"
#import "ESUpgradeNotificationManager.h"
#import "ESNotifiManager.h"

#import "ESCommonToolManager.h"
#import "ESBoxListViewController.h"
#import "ESCommonToolManager.h"
#import "ESLanguageManager.h"
#import "ESUpgradeVC.h"
#import "ESWebContainerViewController.h"

#import "ESGatewayManager.h"
#import "ESBoxManager.h"
#import "ESAccountManager.h"
#import "ESWebContainerViewController.h"
#import "ESFeedbackViewController.h"
#import "ESDeviceInfoModel.h"
#import "ESCache.h"
#import "ESDeviceInfoServiceModule.h"
#import "ESCommonToolManager.h"

@interface ESNetworking ()

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

@end

@interface AppDelegate ()

@property (nonatomic, strong) NSString *shareUrlStr;

@property (strong, nonatomic) UIImage *testImg;

@property (strong, nonatomic) UIImageView *imgvPhoto;

@property (strong, nonatomic) NSDictionary *pushDic;

@property (assign, nonatomic) BOOL isEnterForegroundTime;

@property (copy, nonatomic) NSString *timeStartStr;

@property (copy, nonatomic) NSString *timeEndStr;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary* remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(remoteNotification.count > 0){
        self.pushDic = remoteNotification;
    }
    [userDefaults setBool:NO forKey:@"isShareSource"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"select_up_path_uuid"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"select_up_path"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isHavaCycleScrollView"];
    
    
    [ESLanguageManager systemLanguage];
    // 1. 创建窗口
    self.window = [ESHomeCoordinator keyWindow];
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
    
    return YES;
}




- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    NSURL *url = userActivity.webpageURL;
    self.shareUrlStr = url.absoluteString;
    ESDLog(@"[OPEN APP] Universal Link:%@", url);
    
    [self opneH5Page:url.absoluteString];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    ESDLog(@"[OPEN APP] Scheme URL:%@", url);
    
    return NO;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    NSLog(@"Start handle Events For Background URLSession: %@", identifier);
    [ESNetworking.shared application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ESNetworking.shared cancelAllTransfer:^{
    }];
    
    self.timeStartStr = [ESCommonToolManager getCurrentTime];
    self.timeEndStr = nil;
    self.isEnterForegroundTime = NO;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.timeEndStr = [ESCommonToolManager getCurrentTime];
    
    if ([ESCommonToolManager isShowMsgTime:self.timeStartStr endTime:self.timeEndStr]) {
        self.isEnterForegroundTime = YES;
    }
    
    if (self.isEnterForegroundTime) {
        [[ESCommonToolManager manager] lockCheck:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                UIViewController *topVC = [self topViewController];
                ESBoxListViewController *boxVC = [[ESBoxListViewController alloc] init];
                [topVC.navigationController pushViewController:boxVC animated:NO];
            }
        }boxUUID:@""];
    }
}

//截屏响应
- (void)userDidTakeScreenshot:(NSNotification *)notification {
    //添加显示
    UIViewController *topVC = [self topViewController];
    if ([topVC isKindOfClass:[ESUpgradeVC class]]){
        ESUpgradeVC *vc = nil;
        if ([topVC respondsToSelector:@selector(isHaveInstall)]){
            vc = (ESUpgradeVC *)topVC;
            if(vc.isHaveInstall){
                return;
            }
        }
    }
    _testImg = [self imageWithScreenshot];
    if(!self.imgvPhoto){
        self.imgvPhoto = [[UIImageView alloc] initWithImage:_testImg];
        self.imgvPhoto.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.imgvPhoto.userInteractionEnabled = YES;
        
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 75, ScreenHeight - 140 - kBottomHeight, 60, 60)];
        if ([ESCommonToolManager isEnglish]) {
            [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_en"] forState:UIControlStateNormal];
        }else{
            [shareBtn setBackgroundImage:[UIImage imageNamed:@"screenshot_share"] forState:UIControlStateNormal];
        }
        
        [self.imgvPhoto addSubview:shareBtn];
        [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
    
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.imgvPhoto];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView:)];
        [self.imgvPhoto addGestureRecognizer:tap];
    }
    
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)tapImgView:(UITapGestureRecognizer *)tap {
    self.imgvPhoto.hidden = YES;
    [self.imgvPhoto removeFromSuperview];
    self.imgvPhoto = nil;
}

- (void)shareBtnAction {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.testImg] applicationActivities:nil];
    [[self appRootViewController] presentViewController:vc animated:YES completion:nil];
    self.imgvPhoto.hidden = YES;
    [self.imgvPhoto removeFromSuperview];
    self.imgvPhoto = nil;
}

- (UIViewController *)appRootViewController {
    UIViewController *RootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = RootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

//获取截屏
- (UIImage *)imageWithScreenshot {
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}
//截屏操作
- (NSData *)dataWithScreenshotInPNGFormat {
    [ESToast dismiss];
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        
        CGContextConcatCTM(context, window.transform);
        
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(image);
}

- (UIViewController *)topViewController{
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (  [vc isKindOfClass:[UINavigationController class]] || [vc isKindOfClass:[UITabBarController class]] ) {
        if ( [vc isKindOfClass:[UINavigationController class]] ) vc = [(UINavigationController *)vc topViewController];
        if ( [vc isKindOfClass:[UITabBarController class]] ) vc = [(UITabBarController *)vc selectedViewController];
        if ( vc.presentedViewController ) vc = vc.presentedViewController;
    }
    return vc;
}


-(void)opneH5Page:(NSString *)urlStr{
    
    ///帮助与反馈
    ESWebContainerViewController *next = [ESWebContainerViewController new];
    
    next.webUrl = urlStr;
    if ([self.shareUrlStr containsString:@"ao.space/support/help"]) {
        next.webTitle = @"帮助中心";
    }else if([self.shareUrlStr containsString:@"ao.space/en/support/help"]){
        next.webTitle = @"Help";
    }else if([self.shareUrlStr containsString:@"ao.space/open/documentation"]){
        next.webTitle = @"开发文档";
    }else if([self.shareUrlStr containsString:@"ao.space/en/open/documentation"]){
        next.webTitle = @"Documentation";
    }else{
        return;
    }
    UIViewController *topVC = [self topViewController];
    [topVC.navigationController pushViewController:next animated:NO];
}

- (NSInteger)compareVersion:(NSString *)version1 withVersion:(NSString *)version2 {
    NSArray *version1Array = [version1 componentsSeparatedByString:@"."];
        NSArray *version2Array = [version2 componentsSeparatedByString:@"."];
    NSInteger count = MAX(version1Array.count, version2Array.count);
    for (NSInteger i = 0; i < count; i++) {
        NSInteger num1 = i < version1Array.count ? [version1Array[i] integerValue] : 0;
        NSInteger num2 = i < version2Array.count ? [version2Array[i] integerValue] : 0;
        if (num1 < num2) {
            return -1;
        } else if (num1 > num2) {
            return 1;
        }
    }
    return 0;
}

-(void)toOCFeedback{
    ESFeedbackViewController *vc = [[ESFeedbackViewController alloc] init];
    ESFeedbackImagItem *imageItem = [ESFeedbackImagItem new];
    NSString *fileName = [NSString stringWithFormat:@"feed_back_%zd.png", (NSInteger)NSDate.date.timeIntervalSince1970 * 1000];
    NSString *localPath = [NSString randomCacheLocationWithName:fileName];
    imageItem.image = self.testImg;
    imageItem.name = fileName;
    imageItem.localPath = localPath.fullCachePath;
    [UIImagePNGRepresentation(self.testImg) writeToFile:localPath.fullCachePath atomically:YES];
    vc.snapshootImage = imageItem;
    [[self topViewController].navigationController pushViewController:vc animated:YES];
    self.imgvPhoto.hidden = YES;
    [self.imgvPhoto removeFromSuperview];
    self.imgvPhoto = nil;
}

@end
