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
//  ESSelectCell.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUniversalSelectCell.h"

@interface ESUniversalSelectCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *selectedIcon;

@end

static CGFloat const ESTitleDetailGap = 26;
static CGFloat const ESTitleMaxLengthGap = ESTitleDetailGap + 28 + 60;
static CGFloat const ESDetailRightGap = 28;

@implementation ESUniversalSelectCell

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
        _titleLabel.frame = CGRectMake(60.0f,
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
    [self.contentView addSubview:self.selectedIcon];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];

    [self.selectedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).inset(26.0f);
        make.width.mas_equalTo(22.0f);
        make.height.mas_equalTo(22.0f);
    }];
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

- (UIImageView *)selectedIcon {
    if (!_selectedIcon) {
        _selectedIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _selectedIcon;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSwitchCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(detail)] &&
           [data respondsToSelector:@selector(isSelected)])) {
        ESDLog(@"[ESSwitchCell] [bindData] bindData data type error");
        return;
    }
    id<ESUniversalSelectCellModelProtocol> cellModel = (id <ESUniversalSelectCellModelProtocol>)data;
    self.selectedIcon.image =  (cellModel.isSelected) ?  [UIImage imageNamed:@"cache_manager_selected"] : [UIImage imageNamed:@"cache_manager_unselected"];
    [self setTitle:cellModel.title detail:cellModel.detail];
}

- (void)setTitle:(NSString *)title detail:(NSString *)detail {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    
    [self layoutIfNeeded];
}

@end

