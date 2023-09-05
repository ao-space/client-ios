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
//  ESWebNavigationBar+ESStyle.m
//  EulixSpace
//
//  Created by KongBo on 2023/3/31.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESWebNavigationBar+ESStyle.h"

@interface ESWebNavigationBar ()

@property (nonatomic, strong) UIButton* backBt;
@property (nonatomic, strong) UIView* customView;
@property (nonatomic, strong) UIImageView* customViewBackgroudImageView;

@property (nonatomic, strong) UIButton* closeBt;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, assign) BOOL isBarkStyle;
@property (nonatomic, strong) NSNumber *translucentUseLightIcons;

@property (nonatomic, strong) UIColor *backgroudColor;
@property (nonatomic, strong) UIColor *titleColor;

@end

@implementation ESWebNavigationBar (ESStyle)

- (void)setBarBackgroundColor:(UIColor *)backgroudColor {
    self.backgroudColor = backgroudColor;
    self.isBarkStyle = ![ESColor isLighterColor:backgroudColor];
}

- (void)setUseLightIcons:(BOOL)useLightIcons {
    self.translucentUseLightIcons = @(useLightIcons);
}

- (NSString *)styleKey {
    
    if (self.isTranslucent) {
        if (!self.translucentUseLightIcons) {
            return @"isTranslucent";
        }
        
        if ([self.translucentUseLightIcons boolValue]) {
            return @"isBarkStyle";
        }
        return @"lightStyle";
    }
    
    if (self.isBarkStyle) {
        return @"isBarkStyle";
    }
    return @"lightStyle";
}

- (NSDictionary *)showStyleMap {
    return @{
        @"backBt"  : @{ @"isTranslucent" : @"back_1" , @"isBarkStyle" : @"back_0", @"lightStyle" : @"back_1" },
        @"closeBt" : @{ @"isTranslucent" : @"quxiao_1" , @"isBarkStyle" : @"quxiao_0", @"lightStyle" : @"quxiao_1" },
        @"customBackgroudView" : @{ @"isTranslucent" : @"shape_1" , @"isBarkStyle" : @"shape_0", @"lightStyle" : @"shape_1" }
    };
}

- (NSString *)showStyleImageNameWithViewKey:(NSString *)viewKey {
    NSDictionary *showStyleMap = [self showStyleMap];
    NSDictionary *viewStyleMap = showStyleMap[viewKey];
    if (viewStyleMap == nil) {
        NSAssert(viewStyleMap == nil, @"set error view key!");
    }
    return viewStyleMap[[self styleKey]];
}

- (void)updateShowStyle {
    NSString *backImageBtName = [self showStyleImageNameWithViewKey:@"backBt"];
    [self.backBt setImage:[UIImage imageNamed:backImageBtName] forState:UIControlStateNormal];
    
    
    if (self.isTranslucent) {
        self.titleLabel.textColor = self.titleColor ?: [ESColor colorWithHex:0x333333];
        self.backgroundColor = [UIColor clearColor];
    } else if (self.isBarkStyle == NO) {
        self.titleLabel.textColor = self.titleColor ?: [ESColor colorWithHex:0x333333];
        self.backgroundColor = self.backgroudColor  ?: [ESColor colorWithHex:0xFFFFFF];
    } else {
        self.titleLabel.textColor = self.titleColor ?: [ESColor colorWithHex:0xFFFFFF];
        self.backgroundColor = self.backgroudColor ?: [ESColor colorWithHex:0x337AFF];
    }
    
    if (self.styleUpdateBlock) {
        self.styleUpdateBlock();
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.isTranslucent) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        }
    } else if (self.isBarkStyle == NO) {
        if (@available(iOS 13.0, *)) {
            return UIStatusBarStyleDarkContent;
        }
    } else {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

@end
