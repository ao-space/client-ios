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
//  ESTransferUploadCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/31.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTransferUploadCell.h"

#import "ESFileDefine.h"
#import "ESThemeDefine.h"
#import "ESTransferCellItem.h"
#import "ESTransferListDefine.h"
#import "ESTransferProgressView.h"
#import "ESTransferTask.h"
#import "ESUploadMetadata.h"
#import "ESToast.h"
#import "NSString+ESTool.h"
#import "UIImage+ESTool.h"
#import "UIImageView+ESThumb.h"
#import "UILabel+ESAutoSize.h"
#import "ESCommentCachePlistData.h"
#import <Masonry/Masonry.h>
#include <CommonCrypto/CommonDigest.h>
#import "NSString+ESTool.h"
#import "ESLocalNetworking.h"


@interface ESTransferUploadCell()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel * speedLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *statePauseLabel;
@property (nonatomic, strong) ESTransferProgressView *progressView;
@property (nonatomic, weak) ESTransferCellItem *item;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIButton *pauseBtn;

@end

@implementation ESTransferUploadCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initUI];
    return self;
}

- (void)reloadWithData:(ESTransferCellItem *)item {
    self.item = item;
    self.title.text = item.title;
    self.icon.image = item.icon;
    weakfy(self);
    [self.progressView reloadWithRate:0];

    if (item.data.metadata) {
        [item.data.metadata loadThumbImage:^(UIImage *thumb) {
            if (thumb.size.width != 0) {
                self.icon.image = thumb;
            }
        }];
    }

    item.data.updateProgressBlock = ^(ESTransferTask *task) {
        strongfy(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self partRefresh];
        });
    };
    
    [self partRefresh];
}

/// 局部刷新
- (void)partRefresh {    
    CGFloat progress = [self.item.data getProgress];
    [self.progressView reloadWithRate:progress];
    
    self.pauseBtn.hidden = NO;
    
    self.content.text = self.item.content;
    self.statePauseLabel.hidden = YES;

    self.speedLabel.text = nil;
    switch (self.item.data.state) {
        case ESTransferStateReady: {
            NSString * speedStr = NSLocalizedString(@"Waiting for upload", @"等待上传");
            UIColor * speedColor = [ESColor secondaryLabelColor];
            self.speedLabel.text = speedStr;
            self.speedLabel.textColor = speedColor;
            
            [self.pauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];
            self.pauseBtn.tag = ESTransferCellActionResume;
        }
            break;
        case ESTransferStateRunning: {
            [self.pauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];
            self.pauseBtn.tag = ESTransferCellActionResume;
            
            NSString * speedStr = [self.item.data getTaskSpeed];
            UIColor * speedColor = [ESColor secondaryLabelColor];
            
            if ([ESLocalNetworking shared].reachableBox) {
                speedStr = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Fast Upload", @"极速上传"), speedStr];
                speedColor = [ESColor downGreenColor];
            }
            
            self.speedLabel.text = speedStr;
            self.speedLabel.textColor = speedColor;
        } break;
        case ESTransferStateSuspended: {
            [self.pauseBtn setImage:IMAGE_FILE_UPLOAD forState:UIControlStateNormal];
            self.pauseBtn.tag = ESTransferCellActionPause;
            
            self.statePauseLabel.hidden = NO;
            self.statePauseLabel.textColor = [ESColor primaryColor];
            self.statePauseLabel.text = NSLocalizedString(@"transfer_upload_pause", @"上传暂停");
        } break;
        case ESTransferStateFailed: {
            self.statePauseLabel.hidden = NO;
            self.statePauseLabel.textColor = ESColor.redColor;
            self.statePauseLabel.text = [self.item.data getFailedReason];

            [self.pauseBtn setImage:IMAGE_FILE_UPLOAD forState:UIControlStateNormal];
            self.pauseBtn.tag = ESTransferCellActionPause;
        } break;
        case ESTransferStateCompleted: {
            // Implemented in file ESTransferCompletedCell
        } break;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && self.actionBlock) {
        self.actionBlock(@(ESTransferCellActionLongPress));
    }
}

/// 按钮点击
- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

/// 暂停
- (void)actionPauseBtn:(UIButton *)sender {
    if(sender.tag == ESTransferCellActionResume){
        sender.tag = ESTransferCellActionPause;
        [self.pauseBtn setImage:IMAGE_FILE_UPLOAD forState:UIControlStateNormal];
    } else if (sender.tag == ESTransferCellActionPause) {
        [self.pauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];
        sender.tag = ESTransferCellActionResume;
    }
    
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

- (void)initUI {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.height.width.mas_equalTo(40);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.contentView).inset(86);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-100);
        make.height.mas_equalTo(22);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).offset(-20);
        make.left.mas_equalTo(self.contentView).inset(86);
    }];
    
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).offset(-20);
        make.left.mas_equalTo(self.content.mas_right).offset(10);
    }];
    
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(20);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-79);
        make.height.mas_equalTo(17);
    }];
    
    [self.pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(34);
    }];
    
    [self.statePauseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.progressView.mas_right).offset(0);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(48.0f);
        make.height.mas_equalTo(17.0f);
    }];


    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.title);
        make.right.mas_equalTo(self.contentView).offset(-100);
        make.top.mas_equalTo(self.title.mas_bottom).inset(6);
        make.height.mas_equalTo(6);
    }];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.height.mas_equalTo(1);
    }];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
}

#pragma mark - Lazy Load
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = [ESColor labelColor];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _title.font = ESFontPingFangRegular(16);
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = [ESColor secondaryLabelColor];
        _content.numberOfLines = 0;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = ESFontPingFangRegular(12);
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        UILabel * label = [[UILabel alloc] init];
        label.textColor = [ESColor secondaryLabelColor];
        label.font = ESFontPingFangRegular(12);
        [self.contentView addSubview:label];
        _speedLabel = label;
    }
    return _speedLabel;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.textColor = [ESColor redColor];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.font = ESFontPingFangRegular(12);
        _errorLabel.numberOfLines = 1;
        _errorLabel.hidden = YES;
        [self.contentView addSubview:_errorLabel];
    }
    return _errorLabel;
}


- (UILabel *)statePauseLabel {
    if (!_statePauseLabel) {
        _statePauseLabel = [[UILabel alloc] init];
        _statePauseLabel.textColor = [ESColor primaryColor];
        _statePauseLabel.textAlignment = NSTextAlignmentRight;
        _statePauseLabel.font = ESFontPingFangRegular(12);
        _statePauseLabel.hidden = YES;
        [self.contentView addSubview:_statePauseLabel];
    }
    return _statePauseLabel;
}

- (UIButton *)pauseBtn {
    if (!_pauseBtn) {
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseBtn addTarget:self action:@selector(actionPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_pauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];
        [self.contentView addSubview:_pauseBtn];
    }
    return _pauseBtn;
}

- (ESTransferProgressView *)progressView {
    if (!_progressView) {
        _progressView = [ESTransferProgressView new];
        [self.contentView addSubview:_progressView];
    }
    return _progressView;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line];
    }
    return _line;
}



@end
