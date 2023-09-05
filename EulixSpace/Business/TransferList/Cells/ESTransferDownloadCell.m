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
//  ESTransferDownloadCell.m
//  EulixSpace
//
//  Created by dazhou on 2022/7/25.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTransferDownloadCell.h"
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
#import "NSString+ESTool.h"
#import "ESLocalNetworking.h"

@interface ESTransferDownloadCell ()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel *contentSpeed;
@property (nonatomic, strong) UILabel *statePauseLabel;
@property (nonatomic, strong) ESTransferProgressView *progress;
@property (nonatomic, strong) ESTransferCellItem *item;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIButton *downPauseBtn;

@end

@implementation ESTransferDownloadCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    [self initUI];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
    
    return self;
}

- (void)reloadWithData:(ESTransferCellItem *)item {
    self.item = item;
    self.title.text = item.title;
    self.icon.image = item.icon;
    [self.progress reloadWithRate:0];

    
    if (IsMediaForFile(item.data.file)) {
        [self.icon es_setThumbImageWithFile:item.data.file placeholder:item.icon];
    }
    
    if (item.data.metadata) {
        [item.data.metadata loadThumbImage:^(UIImage *thumb) {
            if (thumb.size.width != 0) {
                self.icon.image = thumb;
            }
        }];
    }
    
    weakfy(self);
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
    self.statePauseLabel.text = nil;
    self.statePauseLabel.hidden = YES;
    self.contentSpeed.hidden = YES;
    [self.downPauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];

    self.content.text = self.item.content;

    
    CGFloat progress = [self.item.data getProgress];
    [self.progress reloadWithRate:progress];
    
    switch (self.item.data.state) {
        case ESTransferStateReady: {
            self.downPauseBtn.tag = ESTransferCellActionResume;
        }break;
        case ESTransferStateRunning: {
            self.contentSpeed.hidden = NO;

            self.downPauseBtn.tag = ESTransferCellActionResume;

            if ([ESLocalNetworking shared].reachableBox) {
                self.contentSpeed.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Fast Download", @"极速下载"), [self.item.data getTaskSpeed]];
            } else {
                self.contentSpeed.text = [self.item.data getTaskSpeed];
            }
        } break;
            
        case ESTransferStateSuspended: {
            self.statePauseLabel.hidden = NO;
            self.statePauseLabel.textColor = [ESColor primaryColor];
            self.statePauseLabel.font = ESFontPingFangRegular(12);
            self.statePauseLabel.text = NSLocalizedString(@"transfer_download_pause", @"下载暂停");
            
            [self.downPauseBtn setImage:IMAGE_FILE_DOWNLOAD forState:UIControlStateNormal];
            self.downPauseBtn.tag = ESTransferCellActionPause;

        } break;
            
        case ESTransferStateCompleted: {
            // Implemented in file ESTransferCompletedCell
            }
            break;
        case ESTransferStateFailed: {
            self.statePauseLabel.hidden = NO;
            self.statePauseLabel.text = [self.item.data getFailedReason];
            self.statePauseLabel.textColor = ESColor.redColor;
            self.downPauseBtn.tag = ESTransferCellActionPause;
        } break;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && self.actionBlock) {
        self.actionBlock(@(ESTransferCellActionLongPress));
    }
}

- (void)actionDownPauseBtn:(UIButton *)sender {
    if(sender.tag == ESTransferCellActionResume){
        sender.tag = ESTransferCellActionPause;
        [self.downPauseBtn setImage:IMAGE_FILE_DOWNLOAD forState:UIControlStateNormal];
    } else if (sender.tag == ESTransferCellActionPause) {
        [self.downPauseBtn setImage:IMAGE_FILE_PAUSE forState:UIControlStateNormal];
        sender.tag = ESTransferCellActionResume;
    } else {
        return;
    }
    
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

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
        make.bottom.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.contentView).inset(86);
    }];
    
    [self.contentSpeed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.content.mas_right).offset(10);
    }];
    
    [self.downPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(34);
    }];
    
    [self.statePauseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.progress.mas_right).offset(0);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(17.0f);
    }];

    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
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
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = ESFontPingFangRegular(12);
        _content.numberOfLines = 2;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)contentSpeed {
    if (!_contentSpeed) {
        _contentSpeed = [[UILabel alloc] init];
        _contentSpeed.textColor = [ESColor downGreenColor];
        _contentSpeed.textAlignment = NSTextAlignmentLeft;
        _contentSpeed.font = ESFontPingFangRegular(12);
        _contentSpeed.numberOfLines = 2;
        [self.contentView addSubview:_contentSpeed];
    }
    return _contentSpeed;
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

- (UIButton *)downPauseBtn {
    if (!_downPauseBtn) {
        _downPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downPauseBtn addTarget:self action:@selector(actionDownPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downPauseBtn];
    }
    return _downPauseBtn;
}

- (ESTransferProgressView *)progress {
    if (!_progress) {
        _progress = [ESTransferProgressView new];
        [self.contentView addSubview:_progress];
    }
    return _progress;
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
