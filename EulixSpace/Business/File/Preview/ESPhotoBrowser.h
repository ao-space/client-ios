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
//  ESPhotoBrowser.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKPhotoBrowser/GKPhotoView.h>
#import "ESBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ESPhotoBrowser;

typedef void(^layoutBlock)(ESPhotoBrowser *photoBrowser, CGRect superFrame);

@protocol GKPhotoBrowserDelegate<NSObject>

@optional

// 滚动到一半时索引改变
- (void)photoBrowser:(ESPhotoBrowser *)browser didChangedIndex:(NSInteger)index;

// 选择photoView时回调
- (void)photoBrowser:(ESPhotoBrowser *)browser didSelectAtIndex:(NSInteger)index;

// 单击事件
- (void)photoBrowser:(ESPhotoBrowser *)browser singleTapWithIndex:(NSInteger)index;

// 长按事件
- (void)photoBrowser:(ESPhotoBrowser *)browser longPressWithIndex:(NSInteger)index;

// 旋转事件
- (void)photoBrowser:(ESPhotoBrowser *)browser onDeciceChangedWithIndex:(NSInteger)index isLandscape:(BOOL)isLandscape;

// 保存按钮点击事件
- (void)photoBrowser:(ESPhotoBrowser *)browser onSaveBtnClick:(NSInteger)index image:(UIImage *)image;

// 上下滑动消失
// 开始滑动时
- (void)photoBrowser:(ESPhotoBrowser *)browser panBeginWithIndex:(NSInteger)index;

// 结束滑动时 disappear：是否消失
- (void)photoBrowser:(ESPhotoBrowser *)browser panEndedWithIndex:(NSInteger)index willDisappear:(BOOL)disappear;

// 布局子视图
- (void)photoBrowser:(ESPhotoBrowser *)browser willLayoutSubViews:(NSInteger)index;

// browser完全消失回调
- (void)photoBrowser:(ESPhotoBrowser *)browser didDisappearAtIndex:(NSInteger)index;

// browser自定义加载方式时回调
- (void)photoBrowser:(ESPhotoBrowser *)browser loadImageAtIndex:(NSInteger)index progress:(float)progress isOriginImage:(BOOL)isOriginImage;

// browser加载失败自定义弹窗
- (void)photoBrowser:(ESPhotoBrowser *)browser loadFailedAtIndex:(NSInteger)index;

// browser UIScrollViewDelegate
- (void)photoBrowser:(ESPhotoBrowser *)browser scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)photoBrowser:(ESPhotoBrowser *)browser scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)photoBrowser:(ESPhotoBrowser *)browser scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@interface ESPhotoBrowser : ESBaseViewController

/** 底部内容试图 */
@property (nonatomic, strong, readonly) UIView        *contentView;
/** 图片模型数组 */
@property (nonatomic, strong, readonly) NSArray       *photos;
/** 当前索引 */
@property (nonatomic, assign, readonly) NSInteger     currentIndex;
/** 当前显示的photoView */
@property (nonatomic, strong, readonly) GKPhotoView   *curPhotoView;
/** 是否是横屏 */
@property (nonatomic, assign, readonly) BOOL          isLandscape;
/** 当前设备的方向 */
@property (nonatomic, assign, readonly) UIDeviceOrientation currentOrientation;
/** 显示方式 */
@property (nonatomic, assign) GKPhotoBrowserShowStyle showStyle;
/** 隐藏方式 */
@property (nonatomic, assign) GKPhotoBrowserHideStyle hideStyle;
/** 图片加载方式 */
@property (nonatomic, assign) GKPhotoBrowserLoadStyle loadStyle;
/** 原图加载加载方式 */
@property (nonatomic, assign) GKPhotoBrowserLoadStyle originLoadStyle;
/** 图片加载失败显示方式 */
@property (nonatomic, assign) GKPhotoBrowserFailStyle failStyle;
/** 代理 */
@property (nonatomic, weak) id<GKPhotoBrowserDelegate> delegate;

/// 是否跟随系统旋转，默认是NO，如果设置为YES，isScreenRotateDisabled属性将失效
@property (nonatomic, assign) BOOL isFollowSystemRotation;

/// 是否禁止屏幕旋转监测
@property (nonatomic, assign) BOOL isScreenRotateDisabled;

/// 是否禁用默认单击事件
@property (nonatomic, assign) BOOL isSingleTapDisabled;

/// 是否显示状态栏，默认NO：不显示状态栏
@property (nonatomic, assign) BOOL isStatusBarShow;

/// 状态栏样式，默认Light
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// 滑动消失时是否隐藏原来的视图：默认YES
@property (nonatomic, assign) BOOL isHideSourceView;

/// 滑动切换图片时，是否恢复上（下）一张图片的缩放程度，默认是NO
/// 如果滑动超过一张，则恢复原状
@property (nonatomic, assign) BOOL isResumePhotoZoom;

/// 横屏时是否充满屏幕宽度，默认YES，为NO时图片自动填充屏幕
@property (nonatomic, assign) BOOL isFullWidthForLandScape;

/// 是否适配安全区域，默认NO，为YES时图片会自动适配iPhone X的安全区域
@property (nonatomic, assign) BOOL isAdaptiveSafeArea;

/// 是否启用滑动返回手势处理（当showStyle为GKPhotoBrowserShowStylePush时有效）
@property (nonatomic, assign) BOOL isPopGestureEnabled;

/// 是否隐藏countLabel，默认NO
@property (nonatomic, assign) BOOL hidesCountLabel;

/// 是否隐藏pageControl，默认NO
@property (nonatomic, assign) BOOL hidesPageControl;

/// 图片最大放大倍数
@property (nonatomic, assign) CGFloat maxZoomScale;

/// 双击放大倍数，默认maxZoomScale，不能超过maxZoomScale
@property (nonatomic, assign) CGFloat doubleZoomScale;

/// 动画时间，默认0.3
@property (nonatomic, assign) NSTimeInterval animDuration;

/// 浏览器背景（默认黑色）
@property (nonatomic, strong) UIColor *bgColor;

/// 数量Label，默认显示，若要隐藏需设置hidesCountLabel为YES
@property (nonatomic, strong) UILabel *countLabel;

/// 页码，默认显示，若要隐藏需设置hidesPageControl为YES
@property (nonatomic, strong) UIPageControl *pageControl;

/// 保存按钮，默认隐藏
@property (nonatomic, strong) UIButton *saveBtn;

/// 加载失败时显示的文字或图片
@property (nonatomic, copy) NSString    *failureText;
@property (nonatomic, strong) UIImage   *failureImage;

/// 是否添加导航控制器，默认NO，添加后会默认隐藏导航栏
/// showStyle = GKPhotoBrowserShowStylePush时无效
@property (nonatomic, assign, getter=isAddNavigationController) BOOL addNavigationController;

// 初始化方法

/**
 创建图片浏览器
 
 @param photos 包含GKPhoto对象的数组
 @param currentIndex 当前的页码
 @return 图片浏览器对象
 */
+ (instancetype)photoBrowserWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex;

- (instancetype)initWithPhotos:(NSArray<GKPhoto *> *)photos currentIndex:(NSInteger)currentIndex;

/// 自定义图片请求类
/// @param protocol 需实现GKWebImageProtocol协议
- (void)setupWebImageProtocol:(id<GKWebImageProtocol>)protocol;

/**
 为浏览器添加自定义遮罩视图
 
 @param coverViews  视图数组
 @param layoutBlock 布局
 */
- (void)setupCoverViews:(NSArray *)coverViews layoutBlock:(layoutBlock)layoutBlock;

/**
 显示图片浏览器
 
 @param vc 控制器
 */
- (void)showFromVC:(UIViewController *)vc;

/**
 隐藏图片浏览器
 */
- (void)dismiss;

/**
 选中指定位置的内容
 
 @param index 位置索引
 */
- (void)selectedPhotoWithIndex:(NSInteger)index animated:(BOOL)animated;

/**
 移除指定位置的内容
 
 @param index 位置索引
 */
- (void)removePhotoAtIndex:(NSInteger)index;

/**
 重置图片浏览器
 
 @param photos 图片内容数组
 */
- (void)resetPhotoBrowserWithPhotos:(NSArray *)photos;

/**
 加载原图方法，外部调用
 */
- (void)loadCurrentPhotoImage;

@end
NS_ASSUME_NONNULL_END
