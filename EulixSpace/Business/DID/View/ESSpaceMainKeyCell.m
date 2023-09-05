//
//  ESMainKeyCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceMainKeyCell.h"

@implementation ESSpaceMainKeyItem

@end

@interface ESSpaceMainKeyCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UILabel *hashTitleLabel;
@property (nonatomic, strong) UILabel *hashDetailLabel;


@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UILabel *locationDetailLabel;

@property (nonatomic, strong) UILabel *timeTitleLabel;
@property (nonatomic, strong) UILabel *timedetailLabel;

@property (nonatomic, strong) ESSpaceMainKeyItem *cellModel;

@end

@implementation ESSpaceMainKeyCell

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
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).inset(10);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(10);
    }];
    [self.contentView addSubview:self.line];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(9);
        make.left.right.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.hashTitleLabel];
    [self.hashTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.top.mas_equalTo(self.line.mas_bottom).inset(19);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
    
    [self.contentView addSubview:self.hashDetailLabel];
    [self.hashDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(self.hashTitleLabel.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
    
    [self.contentView addSubview:self.locationTitleLabel];
    [self.locationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.top.mas_equalTo(self.hashDetailLabel.mas_bottom).inset(20);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
    
    [self.contentView addSubview:self.locationDetailLabel];
    [self.locationDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.locationTitleLabel.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
    
    [self.contentView addSubview:self.timeTitleLabel];
    [self.timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.top.mas_equalTo(self.locationDetailLabel.mas_bottom).inset(20);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
    
    [self.contentView addSubview:self.timedetailLabel];
    [self.timedetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.top.mas_equalTo(self.timeTitleLabel.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(24);
        make.right.mas_equalTo(self.contentView).inset(24);
    }];
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [ESColor colorWithHex:0xEBECF0];
    }
    return _line;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangMedium(16);
    }
    return _titleLabel;
}

- (UILabel *)hashTitleLabel {
    if (!_hashTitleLabel) {
        _hashTitleLabel = [[UILabel alloc] init];
        _hashTitleLabel.textColor = ESColor.secondaryLabelColor;
        _hashTitleLabel.textAlignment = NSTextAlignmentLeft;
        _hashTitleLabel.font = ESFontPingFangRegular(14);
        _hashTitleLabel.text = NSLocalizedString(@"account_publickey", @"公钥 Hash");
    }
    return _hashTitleLabel;
}

- (UILabel *)hashDetailLabel {
    if (!_hashDetailLabel) {
        _hashDetailLabel = [[UILabel alloc] init];
        _hashDetailLabel.textColor = ESColor.labelColor;
        _hashDetailLabel.textAlignment = NSTextAlignmentLeft;
        _hashDetailLabel.numberOfLines = 0;
        _hashDetailLabel.font = ESFontPingFangRegular(16);
    }
    return _hashDetailLabel;
}


- (UILabel *)locationTitleLabel {
    if (!_locationTitleLabel) {
        _locationTitleLabel = [[UILabel alloc] init];
        _locationTitleLabel.textColor = ESColor.secondaryLabelColor;
        _locationTitleLabel.textAlignment = NSTextAlignmentLeft;
        _locationTitleLabel.font = ESFontPingFangRegular(14);
        _locationTitleLabel.text = NSLocalizedString(@"account_storage", @"存储位置");
    }
    return _locationTitleLabel;
}

- (UILabel *)locationDetailLabel {
    if (!_locationDetailLabel) {
        _locationDetailLabel = [[UILabel alloc] init];
        _locationDetailLabel.textColor = ESColor.labelColor;
        _locationDetailLabel.textAlignment = NSTextAlignmentLeft;
        _locationDetailLabel.font = ESFontPingFangRegular(16);
    }
    return _locationDetailLabel;
}


- (UILabel *)timeTitleLabel {
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] init];
        _timeTitleLabel.textColor = ESColor.secondaryLabelColor;
        _timeTitleLabel.textAlignment = NSTextAlignmentLeft;
        _timeTitleLabel.font = ESFontPingFangRegular(14);
        _timeTitleLabel.text = NSLocalizedString(@"account_lastupdate", @"最后更新时间");
    }
    return _timeTitleLabel;
}

- (UILabel *)timedetailLabel {
    if (!_timedetailLabel) {
        _timedetailLabel = [[UILabel alloc] init];
        _timedetailLabel.textColor = ESColor.labelColor;
        _timedetailLabel.textAlignment = NSTextAlignmentLeft;
        _timedetailLabel.font = ESFontPingFangRegular(16);
    }
    return _timedetailLabel;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSpaceAccountKeyCell] [bindData] bindData data: %@", data);

    if (! ([data isKindOfClass:[ESSpaceMainKeyItem class]])) {
        ESDLog(@"[ESSpaceAccountKeyCell] [bindData] bindData data type error");
        return;
    }
    ESSpaceMainKeyItem* cellModel = (ESSpaceMainKeyItem *)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    self.hashDetailLabel.text = cellModel.publicKeyHash;
    self.locationDetailLabel.text = cellModel.cacheLocation;
    self.timedetailLabel.text = cellModel.lastUpdateTime;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds  cornerRadius:10];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
@end
