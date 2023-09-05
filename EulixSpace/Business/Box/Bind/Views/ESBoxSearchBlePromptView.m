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
//  ESBoxSearchBlePromptView.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/7.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBoxSearchBlePromptView.h"
#import <Masonry/Masonry.h>
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import "UIFont+ESSize.h"
#import "UIColor+ESHEXTransform.h"

@interface ESBoxSearchBlePromptView()
@property (nonatomic, strong) UILabel * bluetoothHintLabel;

@end

@implementation ESBoxSearchBlePromptView

- (void)reloadWithState:(ESBoxBindState)state {
    self.bluetoothHintLabel.hidden = YES;
    if (state == ESBoxBindStateScaning) {
        self.bluetoothHintLabel.hidden = YES;
        self.title.text = NSLocalizedString(@"Bluetooth connection in progress", @"蓝牙连接中…");
        [self.animation play];
    } else if (state == ESBoxBindStateNotFound) {
        self.bluetoothHintLabel.hidden = YES;
        self.title.text = nil;
        [self.animation stop];
    } else {
        self.bluetoothHintLabel.hidden = NO;
        self.title.text = nil;
        [self.animation stop];
    }
}

- (void)initUI {
    [super initUI];

    [self.container.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    self.bluetoothHintLabel = [[UILabel alloc] init];
    self.bluetoothHintLabel.numberOfLines = 0;
    self.bluetoothHintLabel.textColor = ESColor.secondaryLabelColor;
    [self addSubview:self.bluetoothHintLabel];
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
    };
    NSDictionary *highlightAttr = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
    };
    /*
     硬件设备验证需要通过蓝牙或局域网连接傲空间设备，请打开手机的蓝牙设置。\n\n若蓝牙连接不成功，请将手机与傲空间设备连接到同一个网络，在局域网内搜索设备并连接。
     */
    NSMutableAttributedString *content = [NSLocalizedString(@"box search hint", @"") es_toAttr:attributes];
    [content matchPattern:NSLocalizedString(@"box search highlight hint", @"请打开手机的蓝牙设置") highlightAttr:highlightAttr];
    self.bluetoothHintLabel.attributedText = content;
    
    [self.bluetoothHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(38);
        make.right.mas_equalTo(self).offset(-38);
        make.top.mas_equalTo(self.animation.mas_bottom).offset(50);
    }];
}

- (void)setType:(NSString *)type{
    if([type isEqual:@"V2Community"]){
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
        };
        NSDictionary *highlightAttr = @{
            NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
            NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
        };
        NSMutableAttributedString *content = [NSLocalizedString(@"v2 search hint", @"") es_toAttr:attributes];
        [content matchPattern:NSLocalizedString(@"box search highlight hint", @"请打开手机的蓝牙设置") highlightAttr:highlightAttr];
        self.bluetoothHintLabel.attributedText = content;
    }
}
@end
