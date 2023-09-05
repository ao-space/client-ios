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
//  UIView+ESTool.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/3.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESThemeDefine.h"
#import "UIView+ESTool.h"
#import <Masonry/Masonry.h>
#import <objc/runtime.h>
#import "UILabel+ESTool.h"
#import "UIImageView+ESThumb.h"
#import "UIColor+ESHEXTransform.h"

static void *esLoadingView = &esLoadingView;
static void *esLoadingImageView = &esLoadingImageView;
static void *esLoadingLabel = &esLoadingLabel;

@implementation UIView (ESTool)

- (UIView *)es_addline:(CGFloat)margin offset:(CGFloat)offset vertical:(BOOL)vertical {
    UIView *line = [UIView new];
    line.backgroundColor = ESColor.separatorColor;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        if (vertical) {
            make.top.bottom.mas_equalTo(self).inset(margin);
            make.right.mas_equalTo(self).offset(offset);
            make.width.mas_equalTo(1);
        } else {
            make.left.right.mas_equalTo(self).inset(margin);
            make.bottom.mas_equalTo(self).offset(offset);
            make.height.mas_equalTo(1);
        }
    }];
    return line;
}

- (UIView *)es_addline:(CGFloat)margin offset:(CGFloat)offset {
    return [self es_addline:margin offset:offset vertical:NO];
}

- (UIView *)es_addline:(CGFloat)margin {
    return [self es_addline:margin offset:0];
}

- (UIView *)showLoadingView {
    return [self showLoadingView:NSLocalizedString(@"waiting_operate", @"请稍后")];
}

- (UIView *)showLoadingView:(NSString *)text {
    UIView * view = [[UIView alloc] init];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    objc_setAssociatedObject(self, esLoadingView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIImageView * iv = [UIImageView getLoadingImageView];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view);
        make.width.height.mas_equalTo(30);
        make.left.mas_greaterThanOrEqualTo(view).offset(20);
        make.right.mas_lessThanOrEqualTo(view).offset(-20);
        make.top.mas_equalTo(view);
    }];
    objc_setAssociatedObject(self, esLoadingImageView, iv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UILabel * label = [UILabel createLabel:text font:ESFontPingFangRegular(12) color:@"#85899C"];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iv.mas_bottom).offset(20);
        make.centerX.mas_equalTo(view);
        make.left.mas_greaterThanOrEqualTo(view).offset(10);
        make.right.mas_lessThanOrEqualTo(view).offset(-10);
        make.bottom.mas_equalTo(view);
    }];
    objc_setAssociatedObject(self, esLoadingLabel, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);


    return view;
}

- (UIView *)showLoadingFailedView:(NSString *)text image:(NSString *)imageName {
    UIView * view = (UIView *)objc_getAssociatedObject(self, esLoadingImageView);
    if (text) {
        UILabel * label = (UILabel *)objc_getAssociatedObject(self, esLoadingLabel);
        label.text = text;
    }
    if (imageName) {
        UIImageView * iv = (UIImageView *)objc_getAssociatedObject(self, esLoadingImageView);
        [iv.layer removeAllAnimations];
        iv.image = [UIImage imageNamed:imageName];
    }

    return view;
}

- (void)removeLoadingView {
    UIView * view = (UIView *)objc_getAssociatedObject(self, esLoadingView);
    [view removeFromSuperview];
    view = nil;
}

- (UIViewController *)es_getController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (UIView *)es_sloganView:(NSString *)title {
    UIView * view = [[UIView alloc] init];
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aoSpaceGood"]];
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(view);
        make.centerY.mas_equalTo(view);
    }];
    
    UILabel * label = [UILabel createLabel:title font:ESFontPingFangRegular(12) color:@"#BCBFCD"];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(iv.mas_trailing).offset(6);
        make.trailing.mas_equalTo(view);
        make.top.bottom.mas_equalTo(view);
    }];
    
    return view;
}

+ (UIView *)es_create:(NSString *)color radius:(float)radius {
    UIView * view = [[UIView alloc] init];
    if (radius > 0) {
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = radius;
    }
    if (color) {
        view.backgroundColor = [UIColor es_colorWithHexString:color];
    }
    return view;
}

@end

@interface ESViewBuilder ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) CGFloat pFontSize;

@property (nonatomic, assign) UIFontWeight pFontWeight;

@end

@implementation ESViewBuilder

+ (ESViewBuilder * (^)(NSString *text))label {
    return ^(NSString *text) {
        UILabel *label = [UILabel new];
        label.text = text;
        ESViewBuilder *builder = [ESViewBuilder new];
        builder.label = label;
        builder.pFontWeight = UIFontWeightRegular;
        return builder;
    };
}

- (ESViewBuilder * (^)(CGFloat fontSize))fontSize {
    return ^(CGFloat fontSize) {
        self.pFontSize = fontSize;
        return self;
    };
}

- (ESViewBuilder * (^)(UIFontWeight fontWeight))fontWeight {
    return ^(UIFontWeight fontWeight) {
        self.pFontWeight = fontWeight;
        return self;
    };
}

- (ESViewBuilder * (^)(UIColor *))textColor {
    return ^(UIColor *textColor) {
        self.label.textColor = textColor;
        return self;
    };
}

//- (__kindof UIView * (^)(void))build {
//    return ^(void) {
//        self.label.font = [UIFont systemFontOfSize:self.pFontSize weight:self.pFontWeight];
//        return self.label;
//  };
//
- (__kindof UIView * (^)(UIView *superView))build {
    return ^(UIView *superView) {
        self.label.font = [UIFont systemFontOfSize:self.pFontSize weight:self.pFontWeight];
        [superView addSubview:self.label];

        return self.label;
    };
}

@end
