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
//  ESTitleDetailCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTitleDetailCell.h"

@interface ESTitleDetailCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

static CGFloat const ESTitleDetailGap = 26;
static CGFloat const ESTitleMaxLengthGap = ESTitleDetailGap + 28 + 26;
static CGFloat const ESDetailRightGap = 28;

@implementation ESTitleDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize viewSize = self.contentView.frame.size;
    
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
}

- (void)setupViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangRegular(16);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = ESColor.secondaryLabelColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = ESFontPingFangRegular(16);
    }
    return _detailLabel;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSwitchCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(detail)])) {
        ESDLog(@"[ESSwitchCell] [bindData] bindData data type error");
        return;
    }
    id<ESTitleDetailCellModelProtocol> cellModel = (id <ESTitleDetailCellModelProtocol>)data;
    [self setTitle:cellModel.title detail:cellModel.detail];
}

- (void)setTitle:(NSString *)title detail:(NSString *)detail {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    
    [self layoutIfNeeded];
}

@end






