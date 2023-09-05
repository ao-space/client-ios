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
//  UILabel+ESTool.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/22.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "UILabel+ESTool.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>
#import "UIColor+ESHEXTransform.h"

@implementation UILabel (ESTool)

+ (UILabel *)createLabel:(UIFont *)font color:(NSString *)color {
    return [self createLabel:@"" font:font color:color];
}

+ (UILabel *)createLabel:(NSString *)title font:(UIFont *)font color:(NSString *)color {
    UILabel * label = [[UILabel alloc] init];
    label.text = title;
    label.font = font;
    label.textColor = [UIColor es_colorWithHexString:color];
    label.numberOfLines = 0;
    return label;
}

@end




@implementation UILabel (ESAutoSize)

- (void)es_es_flexibleFitWidth:(CGFloat)maxWidth {
    CGFloat width = [self.text es_sizeFitWidth:maxWidth font:self.font].width;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

- (void)es_flexible {
    [self es_es_flexibleFitWidth:CGFLOAT_MAX];
}

@end
