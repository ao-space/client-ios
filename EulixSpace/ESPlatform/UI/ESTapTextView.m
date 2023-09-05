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
//  ESTapTextView.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/15.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTapTextView.h"

@implementation ESTapModel

@end

@interface ESTapTextView()<UITextViewDelegate>
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) NSArray<ESTapModel *> * tapList;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, assign) CGFloat lineSpacing;
@end

@implementation ESTapTextView

- (instancetype)init {
    if (self = [super init]) {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        self.textAlignment = NSTextAlignmentCenter;
        self.textFont = ESFontPingFangRegular(12);
        self.textColor = [UIColor es_colorWithHexString:@"#85899C"];
    }
    return self;
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
}

- (void)setShowData:(NSString *)content tap:(NSArray<ESTapModel *> *)tapList {
    self.tapList = tapList;
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    if (self.lineSpacing > 1) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.lineSpacing;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    if (self.textFont) {
        attributes[NSFontAttributeName] = self.textFont;
    }
    if (attributes.allKeys.count > 0) {
        attrStr = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    }
    
    if (tapList.count <= 0) {
        self.textView.attributedText = attrStr;
        return;
    }
    
    [self.tapList enumerateObjectsUsingBlock:^(ESTapModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [content rangeOfString:obj.text];
        if (range.location != NSNotFound) {
            NSString * clickName = [NSString stringWithFormat:@"%@://", [self getTapEventName:idx]];
            [attrStr addAttribute:NSLinkAttributeName value:clickName range:range];
            if (obj.textColor) {
                [attrStr addAttribute:NSForegroundColorAttributeName value:obj.textColor range:range];
            }
            if (obj.underlineColor) {
                [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
                [attrStr addAttribute:NSUnderlineColorAttributeName value:obj.underlineColor range:range];
            }
            if (obj.textFont) {
                [attrStr addAttribute:NSFontAttributeName value:obj.textFont range:range];
            }
        }
    }];
    
    self.textView.attributedText = attrStr;
    self.textView.textAlignment = self.textAlignment;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.tapList.count <= 0) {
        return true;
    }
    
    NSString * scheme = URL.scheme;
    for (int i = 0; i < self.tapList.count; i++) {
        NSString * tapName = [self getTapEventName:i];
        if (![tapName isEqualToString:scheme]) {
            continue;
        }
        
        ESTapModel * model = [self.tapList objectAtIndex:i];
        if (model.onTapTextBlock) {
            model.onTapTextBlock();
        }
    }
    
    return true;
}

- (NSString *)getTapEventName:(long)index {
    return [NSString stringWithFormat:@"click%ld", index];
}

- (UITextView *)textView {
    if (!_textView) {
        UITextView * tv = [[UITextView alloc] init];
        tv.delegate = self;
        tv.backgroundColor = [UIColor clearColor];
        tv.scrollEnabled = false;
        tv.editable = false;
        [self addSubview:tv];
        _textView = tv;
    }
    return _textView;
}

@end
