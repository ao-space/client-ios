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
//  ESDiskImagesView.m
//  EulixSpace
//
//  Created by dazhou on 2022/10/24.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDiskImagesView.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"

@interface ESDiskItemView : UIView
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, weak) UIImageView * diskIv;
@property (nonatomic, weak) UILabel * nameLabel;
@property (nonatomic, weak) UIImageView * failedHintIv;

- (void)setupViews;
- (void)setDiskName:(NSString *)name;
- (void)setDiskOn:(BOOL)on;
- (void)setFailed;
@end

@implementation ESDiskItemView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    self.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disk_off"]];
    [self addSubview:iv];
    self.diskIv = iv;
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(20);
    }];
    
    UILabel * label = [UILabel createLabel:ESFontPingFangRegular(14) color:@"#BCBFCD"];
    [self addSubview:label];
    self.nameLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.leading.mas_greaterThanOrEqualTo(self).offset(10);
        make.trailing.mas_lessThanOrEqualTo(self).offset(-10);
        make.top.mas_equalTo(iv.mas_bottom).offset(20);
        make.bottom.mas_equalTo(self).offset(-20);
    }];
    
    UIImageView * iv1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"failed"]];
    [self addSubview:iv1];
    self.failedHintIv = iv1;
    [iv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.diskIv.mas_trailing);
        make.bottom.mas_equalTo(self.diskIv);
    }];
    iv1.hidden = YES;
}

- (void)setDiskName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setDiskOn:(BOOL)on {
    self.isOn = on;
    self.diskIv.image = on ? [UIImage imageNamed:@"disk_on"] : [UIImage imageNamed:@"disk_off"];
    self.nameLabel.textColor = on ? [UIColor es_colorWithHexString:@"#333333"] :[UIColor es_colorWithHexString:@"#BCBFCD"];
    self.backgroundColor = on ? [UIColor es_colorWithHexString:@"#EDF3FF"] : [UIColor es_colorWithHexString:@"#F5F6FA"];
}

- (void)setFailed {
    if (self.isOn) {
        self.backgroundColor = [UIColor es_colorWithHexString:@"#FFE3E4"];
        self.failedHintIv.hidden = NO;
    }
}

@end

@interface ESSSDDiskItemView : ESDiskItemView

@end

@implementation ESSSDDiskItemView

- (void)setDiskOn:(BOOL)on {
    self.isOn = on;
    self.nameLabel.textColor = on ? [UIColor es_colorWithHexString:@"#333333"] :[UIColor es_colorWithHexString:@"#BCBFCD"];
}

- (void)setupViews {
    [super setupViews];
    self.backgroundColor = [UIColor es_colorWithHexString:@"#EDF3FF"];
    self.diskIv.image = [UIImage imageNamed:@"disk_ssd"];
    [self.diskIv mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(32);
        make.centerY.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(22);
        make.bottom.mas_equalTo(self).offset(-22);
        make.trailing.mas_lessThanOrEqualTo(self.mas_centerX).offset(5);
    }];

    [self.failedHintIv mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.diskIv.mas_trailing);
        make.centerY.mas_equalTo(self.diskIv.mas_bottom).offset(-5);
    }];
    
    self.nameLabel.text = NSLocalizedString(@"M2 SSD", @"M.2 固态硬盘");
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-31);
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.diskIv.mas_trailing).offset(15);
    }];
}

@end

@interface ESDiskImagesView()
@property (nonatomic, weak) ESDiskItemView * disk1;
@property (nonatomic, weak) ESDiskItemView * disk2;

@property (nonatomic, weak) ESSSDDiskItemView * ssdView;
@end

@implementation ESDiskImagesView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setDiskInfos:(NSMutableArray<ESDiskInfoModel *> *)diskInfos {
    _diskInfos = diskInfos;
    
    if (diskInfos == nil || diskInfos.count == 0) {
        [self.disk1 setDiskOn:NO];
        [self.disk2 setDiskOn:NO];
        return;
    }
    
    [diskInfos enumerateObjectsUsingBlock:^(ESDiskInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        long disk = [obj getDiskStorageEnum];
        if (disk == ESDiskStorage_Disk1) {
            if (obj.diskInitStatus == ESDiskInitStatusFormatError
                || obj.diskExpandStatus == ESDiskExpandStatusFormatError) {
                [self.disk1 setFailed];
            } else if (obj.diskException == ESDiskExceptionType_Normal) {
                [self.disk1 setDiskOn:YES];
            }
        } else if (disk == ESDiskStorage_Disk2) {
            if (obj.diskInitStatus == ESDiskInitStatusFormatError
                || obj.diskExpandStatus == ESDiskExpandStatusFormatError) {
                [self.disk2 setFailed];
            } else if (obj.diskException == ESDiskExceptionType_Normal) {
                [self.disk2 setDiskOn:YES];
            }
        } else if (disk == ESDiskStorage_SSD) {
            if (obj.diskInitStatus == ESDiskInitStatusFormatError
                || obj.diskExpandStatus == ESDiskExpandStatusFormatError) {
                [self.ssdView setFailed];
            } else if (obj.diskException == ESDiskExceptionType_Normal) {
                [self.ssdView setDiskOn:YES];
            }
            [self.ssdView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self);
                make.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self.disk1.mas_bottom).offset(10);
                make.bottom.mas_lessThanOrEqualTo(self).offset(-10);
            }];
        }
    }];
}

- (void)setupViews {
    {
        ESDiskItemView * item = [[ESDiskItemView alloc] init];
        [self addSubview:item];
        [item setDiskName:NSLocalizedString(@"Disk 1", @"磁盘 1")];
        self.disk1 = item;
    }
    
    {
        ESDiskItemView * item = [[ESDiskItemView alloc] init];
        [self addSubview:item];
        [item setDiskName:NSLocalizedString(@"Disk 2", @"磁盘 2")];
        self.disk2 = item;
    }
    
    [self.disk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.leading.mas_equalTo(self);
        make.bottom.mas_lessThanOrEqualTo(self).offset(-10);
        make.width.mas_equalTo(self).multipliedBy(0.5).offset(-7.5);
    }];
    
    [self.disk2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.leading.mas_equalTo(self.disk1.mas_trailing).offset(15);
        make.bottom.mas_equalTo(self.disk1);
        make.width.mas_equalTo(self).multipliedBy(0.5).offset(-7.5);
    }];
}

- (ESSSDDiskItemView *)ssdView {
    if (!_ssdView) {
        ESSSDDiskItemView * view = [[ESSSDDiskItemView alloc] init];
        [self addSubview:view];
        _ssdView = view;
    }
    return _ssdView;
}

@end
