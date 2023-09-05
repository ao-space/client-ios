//
//  ESSpaceAccountInfoCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceAccountKeyCell.h"

@implementation ESSpaceAccountKeyItem

@end

@interface ESSpaceAccountKeyCell ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *nextIcon;

@property (nonatomic, strong) ESSpaceAccountKeyItem *cellModel;

@end

@implementation ESSpaceAccountKeyCell

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

- (void)setupViews {
    self.contentView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView).inset(20);
        make.right.mas_equalTo(self.contentView).inset(42 + 48);
    }];
    
    [self.contentView addSubview:self.nextIcon];
    [self.nextIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.right.mas_equalTo(self.contentView).inset(20);
    }];
    
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.right.mas_equalTo(self.nextIcon.mas_left).inset(6);
    }];
    
    
}

- (UIImageView *)nextIcon {
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _nextIcon.image = [UIImage imageNamed:@"file_copyback"];
    }
    return _nextIcon;
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
        _detailLabel.textColor = ESColor.redColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = ESFontPingFangRegular(16);
        _detailLabel.text = NSLocalizedString(@"Not set", @"未设置");
    }
    return _detailLabel;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSpaceAccountKeyCell] [bindData] bindData data: %@", data);

    if (! ([data isKindOfClass:[ESSpaceAccountKeyItem class]])) {
        ESDLog(@"[ESSpaceAccountKeyCell] [bindData] bindData data type error");
        return;
    }
    ESSpaceAccountKeyItem* cellModel = (ESSpaceAccountKeyItem *)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    self.detailLabel.hidden = cellModel.isSetted;
    self.nextIcon.hidden = !cellModel.hasNextStep;
    
    CGFloat offset = 0;
    if (cellModel.style == ESSpaceAccountKeyCellStyle_Top) {
        offset = 2.5;
    } else if (cellModel.style == ESSpaceAccountKeyCellStyle_Bottom) {
        offset = -2.5;
    }
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(offset);
    }];
    [self.contentView layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.cellModel.style == ESSpaceAccountKeyCellStyle_Center) {
        return;
    }
    
    UIBezierPath *maskPath;
    if (self.cellModel.style == ESSpaceAccountKeyCellStyle_Top) {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    } else if (self.cellModel.style == ESSpaceAccountKeyCellStyle_Bottom) {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    } else if (self.cellModel.style == ESSpaceAccountKeyCellStyle_Single) {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds cornerRadius:10];
    }
      
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (UIColor *)separatorLineColor {
    return [ESColor colorWithHex:0xEBECF0];
}
@end
