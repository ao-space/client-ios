//
//  ESSpaceIdCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/7/27.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESSpaceIdCell.h"

@implementation ESSpaceIdItem

@end

@interface ESSpaceIdCell ()

@property (nonatomic, strong) UITextView *titleLabel;
@property (nonatomic, strong) UIView *backgroudView;

@end

@implementation ESSpaceIdCell

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
  
    [self.contentView addSubview:self.backgroudView];
    [self.backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(1, 1, 1, 1));
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView).inset(12);
        make.bottom.mas_equalTo(self.contentView).inset(12);
        make.left.right.mas_equalTo(self.contentView).inset(20);
    }];
}


- (UITextView *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UITextView alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.backgroundColor = [UIColor clearColor];
//        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = ESFontPingFangMedium(16);
        _titleLabel.textContainerInset = UIEdgeInsetsZero;
        _titleLabel.editable = NO;
    }
    return _titleLabel;
}

- (UIView *)backgroudView {
    if (!_backgroudView) {
        _backgroudView = [[UIView alloc] init];
        _backgroudView.backgroundColor = [ESColor colorWithHex:0xEDF3FF];
        _backgroudView.layer.cornerRadius = 10;
        _backgroudView.layer.borderColor = [ESColor colorWithHex:0x337AFF].CGColor;
        _backgroudView.layer.borderWidth = 1;
    }
    return _backgroudView;
}

- (void)bindData:(id)data {
    ESDLog(@"[ESDiskInfoCell] [bindData] bindData data: %@", data);

    if (! ([data isKindOfClass:[ESSpaceIdItem class]])) {
        ESDLog(@"[ESDiskInfoCell] [bindData] bindData data type error");
        return;
    }
    ESSpaceIdItem * cellModel = (ESSpaceIdItem *)data;
    self.titleLabel.text = cellModel.spaceId;
}
@end
