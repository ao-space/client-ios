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


#import "ESActionSheetButton.h"


@interface ESActionSheetButton ()
@end

@implementation ESActionSheetButton

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image titleColor:(UIColor *)titleColor handler:(ZJActionSheetSystemHandler)handler {
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateNormal];
        self.titleColor = titleColor;
        _handler = [handler copy];
        _btnHeight = 64.f;
        if (image) {
            // 设置图片和文字的间距 20
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        }
        self.backgroundColor = [[ESColor colorWithHex:0xffffff] colorWithAlphaComponent:0.98];
        self.textLabel.font = ESFontPingFangMedium(18);
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor handler:(ZJActionSheetSystemHandler)handler {
    return [self initWithTitle:title image:nil titleColor:titleColor handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title handler:(ZJActionSheetSystemHandler)handler {
    return [self initWithTitle:title image:nil titleColor:[UIColor blackColor] handler:handler];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (titleColor) {
        [self setTitleColor:titleColor forState:UIControlStateNormal];
    }
    else {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }
}
- (UILabel *)textLabel {
    return self.titleLabel;
}
@end
