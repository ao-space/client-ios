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
//  ESDiskInitSuccessView.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/26.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskInitSuccessView.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESFileDefine.h"
#import "UIImage+ESTool.h"

@interface ESDiskInitSuccessView()

@property (nonatomic, strong) UILabel * disk1Lable;
@property (nonatomic, strong) UILabel * disk1CapLable;
@property (nonatomic, strong) UILabel * disk2Lable;
@property (nonatomic, strong) UILabel * disk2CapLable;
@property (nonatomic, strong) UILabel * ssdLable;
@property (nonatomic, strong) UILabel * ssdCapLable;

@property (nonatomic, strong) UILabel * modeLable;
@property (nonatomic, strong) UILabel * modeValueLable;

@property (nonatomic, strong) UIImageView * encryIv;
@property (nonatomic, strong) UIImageView * mainStorageIv;

@property (nonatomic, strong) UIView * mConView;

@end

@implementation ESDiskInitSuccessView


- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setModel:(ESDiskManagementModel *)model {
    _model = model;
    
    // 是否加密
    self.encryIv.hidden = !(model.diskEncrypt == 1);
    
    // 存储模式
    if (model.raidType == 1) {
        self.modeValueLable.text = NSLocalizedString(@"Maximum capacity", @"最大容量");
    } else if (model.raidType == 2) {
        self.modeValueLable.text = NSLocalizedString(@"Raid 1 Mode", @"双盘互备\n磁盘 1 + 磁盘 2");
    }
    
    __block BOOL hasSSD = NO;
    [model.diskManageInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ESDiskStorageEnum disk = [obj getDiskStorageEnum];
        if (disk == ESDiskStorage_Disk1 && obj.diskException == ESDiskExceptionType_Normal) {
            [self setDisk:self.disk1Lable capatity:self.disk1CapLable model:obj];
        } else if (disk == ESDiskStorage_Disk2 && obj.diskException == ESDiskExceptionType_Normal) {
            [self setDisk:self.disk2Lable capatity:self.disk2CapLable model:obj];
        } else if (disk == ESDiskStorage_SSD && obj.diskException == ESDiskExceptionType_Normal) {
            hasSSD = YES;
            [self setDisk:self.ssdLable capatity:self.ssdCapLable model:obj];
        }
    }];
    
    self.ssdLable.hidden = !hasSSD;
}

- (void)setDisk:(UILabel *)label capatity:(UILabel *)capatityLabel model:(ESDiskInfoModel *)model {
    if ([self.model.PrimaryStorageHwIds containsObject:model.hwId]) {
        UIImageView * mIv = [self createMainStorageIv];
        [mIv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(label.mas_trailing).offset(10);
            make.centerY.mas_equalTo(label);
        }];
    }
    
    NSString * text = [NSString stringWithFormat:@"%@ / %@",
                       FileSizeString(model.spaceUsage, YES),
                       FileSizeString(model.spaceTotal, YES)];
    capatityLabel.text = text;
}

- (UIImageView *)createMainStorageIv {
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage es_imageNamed:@"disk_main_storage"]];
    [self.mConView addSubview:iv];
    return iv;
}

- (void)setupViews {
    UIView * conView = [[UIView alloc] init];
    self.mConView = conView;
    conView.layer.masksToBounds = YES;
    conView.layer.cornerRadius = 10;
    conView.backgroundColor = [UIColor es_colorWithHexString:@"#F9F9F9"];
    [self addSubview:conView];
    [conView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(26);
        make.trailing.mas_equalTo(self).offset(-26);
        make.top.mas_equalTo(self).offset(20);
    }];
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disk_init_success"]];
    [conView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(conView).offset(30);
        make.top.mas_equalTo(conView).offset(32);
    }];
    
    NSString * text = NSLocalizedString(@"Disk Init Completed", @"磁盘初始化完成");
    UILabel * label = [UILabel createLabel:text font:ESFontPingFangMedium(16) color:@"#333333"];
    self.mTitleLabel = label;
    [conView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(conView).offset(30);
        make.leading.mas_equalTo(iv.mas_trailing).offset(10);
    }];
    
    iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disk_encry"]];
    self.encryIv = iv;
    [self addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(conView).offset(1);
        make.top.mas_equalTo(conView).offset(-1);
    }];
    
    // disk 1
    UILabel * label1 = [UILabel createLabel:NSLocalizedString(@"Disk 1", @"磁盘 1") font:ESFontPingFangRegular(14) color:@"#85899C"];
    self.disk1Lable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).offset(40);
        make.leading.mas_equalTo(conView).offset(30);
    }];
    
    label1 = [UILabel createLabel:@"- -" font:ESFontPingFangMedium(14) color:@"#333333"];
    self.disk1CapLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.disk1Lable.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.disk1Lable);
    }];
    
    // disk 2
    label1 = [UILabel createLabel:NSLocalizedString(@"Disk 2", @"磁盘 2") font:ESFontPingFangRegular(14) color:@"#85899C"];
    self.disk2Lable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.disk1Lable);
        make.leading.mas_equalTo(conView.mas_centerX).offset(30);
    }];
    
    label1 = [UILabel createLabel:@"- -" font:ESFontPingFangMedium(14) color:@"#333333"];
    self.disk2CapLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.disk1CapLable);
        make.leading.mas_equalTo(self.disk2Lable);
    }];
    
    // mode
    label1 = [UILabel createLabel:NSLocalizedString(@"Mode", @"模式") font:ESFontPingFangRegular(14) color:@"#85899C"];
    self.modeLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.disk1CapLable.mas_bottom).offset(20);
        make.leading.mas_equalTo(self.disk1Lable);
    }];
    
    label1 = [UILabel createLabel:@"" font:ESFontPingFangMedium(14) color:@"#333333"];
    self.modeValueLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.modeLable.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.modeLable);
        make.bottom.mas_equalTo(conView).offset(-30);
    }];
    
    // M.2
    label1 = [UILabel createLabel:NSLocalizedString(@"M.2", @"M.2") font:ESFontPingFangRegular(14) color:@"#85899C"];
    self.ssdLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.disk2CapLable.mas_bottom).offset(20);
        make.leading.mas_equalTo(self.disk2CapLable);
    }];
    
    label1 = [UILabel createLabel:ESFontPingFangMedium(14) color:@"#333333"];
    self.ssdCapLable = label1;
    [conView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.ssdLable.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.ssdLable);
    }];
    
}

@end
