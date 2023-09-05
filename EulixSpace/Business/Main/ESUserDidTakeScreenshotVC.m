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
//  ESUserDidTakeScreenshotVC.m
//  EulixSpace
//
//  Created by qu on 2021/11/26.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESUserDidTakeScreenshotVC.h"
#import "ESDebugMacro.h"
#import "ESGlobalMacro.h"

@interface ESUserDidTakeScreenshotVC ()

@property (strong, nonatomic) UIImage *testImg;

@end

@implementation ESUserDidTakeScreenshotVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

//截屏响应
- (void)userDidTakeScreenshot:(NSNotification *)notification {
    NSLog(@"检测到截屏");
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    _testImg = [self imageWithScreenshot];

    //    //添加显示
    UIImageView *imgvPhoto = [[UIImageView alloc] initWithImage:_testImg];
    imgvPhoto.frame = CGRectMake(0, ScreenWidth / 2, ScreenWidth / 2, ScreenHeight / 2);
    imgvPhoto.backgroundColor = [UIColor orangeColor];
    imgvPhoto.userInteractionEnabled = YES;
    //添加边框
    CALayer *layer = [imgvPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 5.0f;
    //添加四个边阴影
    imgvPhoto.layer.shadowColor = [UIColor blackColor].CGColor;
    imgvPhoto.layer.shadowOffset = CGSizeMake(0, 0);
    imgvPhoto.layer.shadowOpacity = 0.5;
    imgvPhoto.layer.shadowRadius = 10.0;
    //添加两个边阴影
    imgvPhoto.layer.shadowColor = [UIColor blackColor].CGColor;
    imgvPhoto.layer.shadowOffset = CGSizeMake(4, 4);
    imgvPhoto.layer.shadowOpacity = 0.5;
    imgvPhoto.layer.shadowRadius = 2.0;

    [self.view addSubview:imgvPhoto];

    // 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgView:)];
    [imgvPhoto addGestureRecognizer:tap];
}

/**
 *  截取当前屏幕 并修改
 *
 *  @return NSData *
 */
- (UIImage *)imageWithScreenshot {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

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

    // 修改图片
    NSData *imageData = UIImagePNGRepresentation(image);
    UIImage *LastImage = [UIImage imageWithData:imageData];

    UIImage *img = [UIImage imageNamed:@"ico_nursery.png"];
    CGImageRef imgRef = img.CGImage;
    CGFloat w = CGImageGetWidth(imgRef);
    CGFloat h = CGImageGetHeight(imgRef);

    //以1.png的图大小为底图
    UIImage *img1 = LastImage;
    CGImageRef imgRef1 = img1.CGImage;
    CGFloat w1 = CGImageGetWidth(imgRef1);
    CGFloat h1 = CGImageGetHeight(imgRef1);

    //以1.png的图大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(w1, h1 + 100));
    [img1 drawInRect:CGRectMake(0, 0, w1, h1)];                       //先把1.png 画到上下文中
    [img drawInRect:CGRectMake(10, h1 + 10, 80, 80)];                 //再把小图放在上下文中
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext(); //从当前上下文中获得最终图片
    UIGraphicsEndImageContext();                                      //关闭上下文

    return resultImg;
}

// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)tapImgView:(UITapGestureRecognizer *)tap {
    // 微信
    //    [MyAPIClient mobEvent:@"wechat"];
    ////  [Helper shareImageName:_testImg type:SSDKPlatformSubTypeWechatSession];//  微信好友
    //    [Helper shareImageName:_testImg type:SSDKPlatformSubTypeWechatTimeline];// 微信朋友圈
    // QQ
    //    [MyAPIClient mobEvent:@"QQ"];
    //    [Helper shareImageName:_testImg type:SSDKPlatformTypeQQ];// QQ
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
