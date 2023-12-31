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
//  FLEXImagePreviewViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 6/12/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXImagePreviewViewController.h"
#import "FLEXUtility.h"
#import "FLEXColor.h"
#import "FLEXResources.h"

@interface FLEXImagePreviewViewController () <UIScrollViewDelegate>
@property (nonatomic) UIImage *image;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UITapGestureRecognizer *bgColorTapGesture;
@property (nonatomic) NSInteger backgroundColorIndex;
@property (nonatomic, readonly) NSArray<UIColor *> *backgroundColors;
@end

#pragma mark -
@implementation FLEXImagePreviewViewController

#pragma mark Initialization

+ (instancetype)previewForView:(UIView *)view {
    return [self forImage:[FLEXUtility previewImageForView:view]];
}

+ (instancetype)previewForLayer:(CALayer *)layer {
    return [self forImage:[FLEXUtility previewImageForLayer:layer]];
}

+ (instancetype)forImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image {
    NSParameterAssert(image);
    
    self = [super init];
    if (self) {
        self.title = @"Preview";
        self.image = image;
        _backgroundColors = @[FLEXResources.checkerPatternColor, UIColor.whiteColor, UIColor.blackColor];
    }
    
    return self;
}


#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = self.backgroundColors.firstObject;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    [self.view addSubview:self.scrollView];
    
    self.bgColorTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackground)];
    [self.scrollView addGestureRecognizer:self.bgColorTapGesture];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
        target:self
        action:@selector(actionButtonPressed:)
    ];
}

- (void)viewDidLayoutSubviews {
    [self centerContentInScrollViewIfNeeded];
}


#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerContentInScrollViewIfNeeded];
}


#pragma mark Private

- (void)centerContentInScrollViewIfNeeded {
    CGFloat horizontalInset = 0.0;
    CGFloat verticalInset = 0.0;
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        horizontalInset = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) / 2.0;
    }
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        verticalInset = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) / 2.0;
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (void)changeBackground {
    self.backgroundColorIndex++;
    self.backgroundColorIndex %= self.backgroundColors.count;
    self.scrollView.backgroundColor = self.backgroundColors[self.backgroundColorIndex];
}

- (void)actionButtonPressed:(id)sender {
    static BOOL canSaveToCameraRoll = NO, didShowWarning = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (UIDevice.currentDevice.systemVersion.floatValue < 10) {
            canSaveToCameraRoll = YES;
            return;
        }
        
        NSBundle *mainBundle = NSBundle.mainBundle;
        if ([mainBundle.infoDictionary.allKeys containsObject:@"NSPhotoLibraryUsageDescription"]) {
            canSaveToCameraRoll = YES;
        }
    });
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.image] applicationActivities:@[]];
    
    if (!canSaveToCameraRoll && !didShowWarning) {
        didShowWarning = YES;
        NSString *msg = @"Add 'NSPhotoLibraryUsageDescription' to this app's Info.plist to save images.";
        [FLEXAlert makeAlert:^(FLEXAlert *make) {
            make.title(@"Reminder").message(msg);
            make.button(@"OK").handler(^(NSArray<NSString *> *strings) {
                [self presentViewController:activityVC animated:YES completion:nil];
            });
        } showFrom:self];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
