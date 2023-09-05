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
//  ESTitleDetailBaseView.m
//  EulixSpace
//
//  Created by KongBo on 2022/8/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTitleDetailBaseView.h"

@interface ESTitleDetailBaseView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, assign) BOOL showArrowImage;

@end

static CGFloat const ESTitleDetailGap = 26;
static CGFloat const ESTitleMaxLengthGap = ESTitleDetailGap + 26 + 52;
static CGFloat const ESDetailRightGap = 52;
static CGFloat const ESArrowRightGap = 26;
static CGFloat const ESArrowSzie = 16;

@implementation ESTitleDetailBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.backgroundColor = ESColor.systemBackgroundColor;
        [self addTapGesture];
    }
    return self;
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self addGestureRecognizer:tap];
}

- (void)tapView:(id)sender {
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)setTitle:(NSString *)title detail:(NSString *)detail showArrow:(BOOL)show {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    self.showArrowImage = show;
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    BOOL titleHaveContent = _titleLabel.text.length > 0;
    if (titleHaveContent) {
        [_titleLabel sizeToFit];
        CGSize titleLabelSize = _titleLabel.frame.size;
        CGFloat titleWidth = titleLabelSize.width  > (viewSize.width - ESTitleMaxLengthGap) ?
                             (viewSize.width - ESTitleMaxLengthGap) : titleLabelSize.width;
        _titleLabel.frame = CGRectMake(26.0f,
                                       (viewSize.height - titleLabelSize.height) /2 ,
                                       titleWidth,
                                       titleLabelSize.height);
    }
    _titleLabel.hidden = !titleHaveContent;

    BOOL detailHaveContent = _detailLabel.text.length > 0;
    if (detailHaveContent) {
        [_detailLabel sizeToFit];
        CGSize detailLabelSize = _detailLabel.frame.size;
        CGFloat detailWidth = viewSize.width - CGRectGetMaxX(_titleLabel.frame) - ESDetailRightGap - ESTitleDetailGap;
        _detailLabel.frame = CGRectMake(viewSize.width - ESDetailRightGap - detailWidth,
                                       (viewSize.height - detailLabelSize.height) /2 ,
                                        detailWidth,
                                        detailLabelSize.height);
        
    }
    _detailLabel.hidden = !detailHaveContent;
    
    if (_showArrowImage) {
        _arrowImageView.frame = CGRectMake(viewSize.width - ESArrowRightGap - ESArrowSzie,
                                       (viewSize.height - ESArrowSzie) /2 ,
                                           ESArrowSzie,
                                           ESArrowSzie);
    }
    
    _arrowImageView.hidden = !_showArrowImage;
}

- (void)setupViews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.arrowImageView];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = ESFontPingFangRegular(16);
        _titleLabel.textColor = [ESColor labelColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = ESFontPingFangRegular(16);
        _detailLabel.textColor = [ESColor secondaryLabelColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _detailLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"me_arrow"];
    }
    return _arrowImageView;
}

@end
