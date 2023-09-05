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
//  ESSpaceTunSwitchCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTitleDetailSwitchCell.h"
#import "UIWindow+ESVisibleVC.h"
#import "ESInputPlatformAddressController.h"
#import "UIColor+ESHEXTransform.h"
#import "ESDeveloperVC.h"
#import "UILabel+ESTool.h"
#import "ESCommonToolManager.h"

@interface ESTitleDetailSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *switchBt;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIView *hintView;

@property (nonatomic, strong) id<ESTitleDetailSwitchListItemProtocol> cellModel;
@property (nonatomic, strong) UIButton * platformAddressBtn;
@property (nonatomic, strong) UILabel * switchLabel;
@property (nonatomic, strong) UIImageView * nextStepIv;
@end

static CGFloat const ESTitleDetailGap = 26;
static CGFloat const ESTitleMaxLengthGap = ESTitleDetailGap + 28 + 26;
static CGFloat const ESDetailRightGap = 28;

@implementation ESTitleDetailSwitchCell

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

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.switchBt.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.switchBt.layer.mask = maskLayer;
    
//    CGSize viewSize = self.contentView.frame.size;
//
//    BOOL titleHaveContent = _titleLabel.text.length > 0;
//    if (titleHaveContent) {
//        [_titleLabel sizeToFit];
//        CGSize titleLabelSize = _titleLabel.frame.size;
//        CGFloat titleWidth = titleLabelSize.width  > (viewSize.width - ESTitleMaxLengthGap) ?
//                             (viewSize.width - ESTitleMaxLengthGap) : titleLabelSize.width;
//        _titleLabel.frame = CGRectMake(26.0f,
//                                       (viewSize.height - titleLabelSize.height) /2 ,
//                                       titleWidth,
//                                       titleLabelSize.height);
//    }
//    _titleLabel.hidden = !titleHaveContent;
//
//    BOOL detailHaveContent = _detailLabel.text.length > 0;
//    if (detailHaveContent) {
//        [_detailLabel sizeToFit];
//        CGSize detailLabelSize = _detailLabel.frame.size;
//        CGFloat detailWidth = viewSize.width - CGRectGetMaxX(_titleLabel.frame) - ESDetailRightGap - ESTitleDetailGap;
//        _detailLabel.frame = CGRectMake(viewSize.width - ESDetailRightGap - detailWidth,
//                                       (viewSize.height - detailLabelSize.height) /2 ,
//                                        detailWidth,
//                                        detailLabelSize.height);
//    }
//    _detailLabel.hidden = !detailHaveContent;
}

- (void)setupViews {
    self.contentView.layer.cornerRadius = 10.0f;
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [ESColor colorWithHex:0xF8FAFF];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.contentView).inset(16);
        make.right.mas_equalTo(self.contentView).inset(94);
    }];
    
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).inset(10);
        make.left.mas_equalTo(self.contentView).inset(16);
        make.right.mas_equalTo(self.contentView).inset(16);
    }];
    
    [self.contentView addSubview:self.switchBt];
    [self.switchBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(74);
        make.right.top.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.switchView];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.right.mas_equalTo(self.contentView).inset(16);
    }];
    
    [self.contentView addSubview:self.hintView];
    [self.hintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).inset(16);
        make.right.mas_equalTo(self.contentView).inset(16);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.detailLabel.mas_bottom).inset(9);
    }];
    
    [self.contentView addSubview:self.platformAddressBtn];
    [self.platformAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).inset(16);
        make.right.mas_equalTo(self.contentView).inset(16);
        make.height.mas_equalTo(46);
        make.top.mas_equalTo(self.detailLabel.mas_bottom).inset(10);
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
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = ESFontPingFangRegular(12);
    }
    return _detailLabel;
}

- (UIButton *)switchBt {
    if (!_switchBt) {
        _switchBt = [[UIButton alloc] init];
        _switchBt.backgroundColor = [ESColor colorWithHex:0xDAE6FF];
        [_switchBt setTitle:@"已开启" forState:UIControlStateNormal];
        _switchBt.titleLabel.font = ESFontPingFangMedium(12);
        [_switchBt setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_switchBt addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBt;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = ESColor.primaryColor;
        _switchView.on = YES;
        [_switchView addTarget:self action:@selector(switchted:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)switchted:(UISwitch *)sender {
    self.cellModel.isOn = sender.isOn;
    if (self.changedBlock) {
        self.changedBlock(self, sender.isOn);
    }
}

- (void)setSwitchOn:(BOOL)isOn {
    self.switchView.on = isOn;
    self.cellModel.isOn = isOn;
    [self.switchBt setTitle:self.cellModel.isOn ? NSLocalizedString(@"common_on", @"已开启") : NSLocalizedString(@"common_off", @"已关闭") forState:UIControlStateNormal];
    _switchBt.backgroundColor = self.cellModel.isOn ? [ESColor colorWithHex:0xDAE6FF] : [ESColor colorWithHex:0xE4E7ED];
    [_switchBt setTitleColor: self.cellModel.isOn ? ESColor.primaryColor : [ESColor colorWithHex:0x85899C] forState:UIControlStateNormal];
    
    self.hintView.hidden = isOn || self.cellModel.switchType == ESSwitchTypeText;
    if (self.cellModel.switchType == ESSwitchTypeSwitch && isOn) {
        self.platformAddressBtn.hidden = NO;
        [self setPlatformAddress:self.cellModel.platformAddress];
    } else {
        self.platformAddressBtn.hidden = YES;
    }
}

- (void)switchAction:(id)sender {
   
}

- (void)bindData:(id)data {
    ESDLog(@"[ESSwitchCell] [bindData] bindData data: %@", data);

    if (! ([data respondsToSelector:@selector(title)] &&
           [data respondsToSelector:@selector(detail)])) {
        ESDLog(@"[ESSwitchCell] [bindData] bindData data type error");
        return;
    }
    id<ESTitleDetailSwitchListItemProtocol> cellModel = (id <ESTitleDetailSwitchListItemProtocol>)data;
    self.cellModel = cellModel;
    
    self.titleLabel.text = cellModel.title;
    if (cellModel.detailAtr.length > 0){
        self.detailLabel.attributedText = cellModel.detailAtr;
    } else {
        self.detailLabel.text = cellModel.detail;
    }
    
    self.switchBt.hidden = cellModel.switchType == ESSwitchTypeSwitch;
    self.switchView.hidden = cellModel.switchType == ESSwitchTypeText;
    
    [self.switchBt setTitle:cellModel.isOn ? NSLocalizedString(@"common_on", @"已开启") : NSLocalizedString(@"common_off", @"已关闭")  forState:UIControlStateNormal];
    _switchBt.backgroundColor = cellModel.isOn ? [ESColor colorWithHex:0xDAE6FF] : [ESColor colorWithHex:0xE4E7ED];
    [_switchBt setTitleColor: cellModel.isOn ? ESColor.primaryColor : [ESColor colorWithHex:0x85899C] forState:UIControlStateNormal];
    
    self.switchView.on = cellModel.isOn;
    self.hintView.hidden = cellModel.isOn || cellModel.switchType == ESSwitchTypeText;

    if (cellModel.switchType == ESSwitchTypeSwitch && cellModel.isOn) {
        self.platformAddressBtn.hidden = NO;
        [self setPlatformAddress:self.cellModel.platformAddress];
    } else {
        self.platformAddressBtn.hidden = YES;
    }
    if (cellModel.isBind) {
        self.nextStepIv.hidden = YES;
        self.switchLabel.hidden = YES;
    } else {
        self.nextStepIv.hidden = NO;
        self.switchLabel.hidden = NO;
    }
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? 40 : 20);
    }];
    
    [self.hintView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([ESCommonToolManager isEnglish] ? 40 : 20);
    }];
}

- (UIView *)hintView {
    if (!_hintView) {
        UIView *hintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 20)];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [ESColor colorWithHex:0xF6222D];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"binding_closeInternetchannel", @"不开通互联网通道，将无法在外网环境访问");
        titleLabel.font = ESFontPingFangRegular(12);
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconImageView.image = [UIImage imageNamed:@"bind_tixing"];
        
        [hintView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(hintView.mas_left).offset(0);
            make.top.mas_equalTo(hintView.mas_top).inset(2);
            make.width.height.mas_equalTo(16);
        }];
        
        [hintView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(iconImageView.mas_right).offset(6.0f);
            make.right.mas_equalTo(hintView.mas_right).offset(- 6.0f);
            make.top.mas_equalTo(iconImageView.mas_top);
        }];
        _hintView = hintView;
    }
   
    
    return _hintView;
}

- (UIButton *)platformAddressBtn {
    if (!_platformAddressBtn) {
        UIButton * btn = [[UIButton alloc] init];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor es_colorWithHexString:@"#BCBFCD"] forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 10;
        [btn setTitle:NSLocalizedString(@"es_input_platform_address", @"请输入空间平台地址") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onPlatformAddressBtn) forControlEvents:UIControlEventTouchUpInside];
        _platformAddressBtn = btn;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_arrow"]];
        self.nextStepIv = iv;
        [btn addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(btn).offset(-10);
            make.centerY.mas_equalTo(btn);
        }];
        
        UILabel * label = [UILabel createLabel:NSLocalizedString(@"es_switch", @"去切换") font:ESFontPingFangRegular(14) color:@"#85899C"];
        self.switchLabel = label;
        [btn addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(btn);
            make.right.mas_equalTo(iv.mas_left).offset(-4);
        }];
    }
    return _platformAddressBtn;
}

- (void)setPlatformAddress:(NSString *)url {
    if (url.length > 0) {
        [self.platformAddressBtn setTitle:url forState:UIControlStateNormal];
        [self.platformAddressBtn setTitleColor:[UIColor es_colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    } else {
        [self.platformAddressBtn setTitle:NSLocalizedString(@"es_input_platform_address", @"请输入空间平台地址") forState:UIControlStateNormal];
        [self.platformAddressBtn setTitleColor:[UIColor es_colorWithHexString:@"#BCBFCD"] forState:UIControlStateNormal];
    }
}

- (void)onPlatformAddressBtn {
    if (self.cellModel.isBind) {
        weakfy(self)
        [ESInputPlatformAddressController showView:[UIWindow getCurrentVC] url:self.cellModel.platformAddress block:^(NSString * _Nonnull urlString) {
            weak_self.cellModel.platformAddress = urlString;
            [weak_self setPlatformAddress:urlString];

            if (weak_self.changedBlock) {
                weak_self.changedBlock(weak_self, weak_self.cellModel.isOn);
            }
        }];
    } else {
        ESDeveloperVC *vc = [[ESDeveloperVC alloc] init];
        [[UIWindow getCurrentVC].navigationController pushViewController:vc animated:YES];
    }
}


@end





