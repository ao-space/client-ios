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
//  ESTransferAlbumSyncCell.m
//  EulixSpace
//
//  Created by dazhou on 2023/2/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTransferAlbumSyncCell.h"
#import "ESThemeDefine.h"
#import "ESTransferCellItem.h"
#import "ESTransferProgressView.h"
#import "ESUploadMetadata.h"
#import "UIImageView+ESThumb.h"
#import <Masonry/Masonry.h>
#import "ESTransferTask.h"

@interface ESTransferAlbumSyncCell()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) ESTransferProgressView *progress;
@property (nonatomic, strong) UILabel *state;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) ESTransferCellItem * item;

@end


@implementation ESTransferAlbumSyncCell

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
    if (item.attributedTitle) {
        self.title.attributedText = item.attributedTitle;
    } else {
        self.title.text = item.title;
    }
    self.content.text = item.content;
    self.icon.image = item.icon;
    self.progress.hidden = YES;

    if (!item.metadata) {
        return;
    }
    [item.metadata loadThumbImage:^(UIImage *thumb) {
        self.icon.image = thumb;
    }];
    weakfy(self);
    item.notifyListener = ^{
        strongfy(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self partRefresh];
        });
    };
    
    item.data.updateProgressBlock = ^(ESTransferTask *task) {
        strongfy(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self partRefresh];
        });
    };
    
    [self partRefresh];
}

- (void)partRefresh {
    self.progress.hidden = NO;
    CGFloat progress = [self.item.data getProgress];
    [self.progress reloadWithRate:progress];
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
        make.bottom.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.contentView).inset(86);
        make.right.mas_equalTo(self.contentView).inset(5);
        make.height.mas_equalTo(17);
    }];
    
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.title);
        make.right.mas_equalTo(self.contentView).offset(-100);
        make.top.mas_equalTo(self.title.mas_bottom).inset(6);
        make.height.mas_equalTo(6);
    }];

    [self.state mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(80);
        make.top.mas_equalTo(self.progress.mas_bottom).offset(10);
    }];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.height.mas_equalTo(1);
    }];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = [ESColor labelColor];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _title.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = [ESColor secondaryLabelColor];
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:12];
        _content.numberOfLines = 2;
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        [self.contentView addSubview:_icon];
    }
    return _icon;
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

- (UILabel *)state {
    if (!_state) {
        _state = [[UILabel alloc] init];
        _state.textColor = [ESColor primaryColor];
        _state.textAlignment = NSTextAlignmentRight;
        _state.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_state];
    }
    return _state;
}

@end
