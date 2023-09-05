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
//  ESTransferCompletedCell.m
//  EulixSpace
//
//  Created by dazhou on 2023/4/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESTransferCompletedCell.h"
#import "ESTransferCellItem.h"
#import "UIButton+ESTouchArea.h"
#import "ESTransferListDefine.h"
#import "NSString+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "ESFileDefine.h"
#import "UIImageView+ESThumb.h"

@interface ESTransferCompletedCell()

@property (nonatomic, strong) UIImageView * fileIconIv;
@property (nonatomic, strong) UILabel * fileNameLabel;
@property (nonatomic, strong) UILabel * contentLabel;
@property (nonatomic, strong) UIButton * selectBtn;
@property (nonatomic, strong) UIView * lineView;

@property (nonatomic, weak) ESTransferCellItem *item;

@end


@implementation ESTransferCompletedCell

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
    self.fileNameLabel.text = item.title;
    self.contentLabel.text = item.content;
    self.fileIconIv.image = item.icon;

    [self setSelectBtnState];

    self.fileIconIv.image = item.icon;
    weakfy(self);
    
    if (IsMediaForFile(item.data.file) && item.data.isDownloadTask) {
        [self.fileIconIv es_setThumbImageWithFile:item.data.file placeholder:item.icon];
    }

    if (item.data.metadata) {
        [item.data.metadata loadThumbImage:^(UIImage *thumb) {
            if (thumb.size.width != 0) {
                self.fileIconIv.image = thumb;
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

- (void)partRefresh {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    paragraphStyle.minimumLineHeight = 20;
    paragraphStyle.maximumLineHeight = 20;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12],
        NSForegroundColorAttributeName: ESColor.secondaryLabelColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    };
    self.contentLabel.attributedText = [self.item.content es_toAttr:attributes];
}

- (void)setSelectBtnState {
    UIImage * sImage = self.item.data.selectForDelectRecord ? [UIImage imageNamed:@"file_selected"] : nil;
    [self.selectBtn setImage:sImage forState:UIControlStateNormal];
}

- (void)onSelectBtn:(UIButton *)btn {
    [self.item.data updateSelectForRecord:!self.item.data.selectForDelectRecord];
    [self setSelectBtnState];
    if (self.actionBlock) {
        self.actionBlock(@(ESTransferCellActionSelect));
    }
}

- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && self.actionBlock) {
        self.actionBlock(@(ESTransferCellActionLongPress));
    }
}

- (void)initUI {
    [self.fileIconIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(22);
        make.left.mas_equalTo(self.contentView).inset(26);
        make.height.width.mas_equalTo(40);
    }];

    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.left.mas_equalTo(self.contentView).inset(86);
        make.right.mas_equalTo(self.selectBtn.mas_left).offset(-20);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.fileNameLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.fileNameLabel);
        make.right.mas_equalTo(self.contentView).offset(-100);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(14);
        make.top.mas_equalTo(self.contentView).offset(35);
        make.right.mas_equalTo(self.contentView).offset(-30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView).inset(26);
        make.height.mas_equalTo(1);
    }];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.contentView addGestureRecognizer:longPress];
}

- (UIImageView *)fileIconIv {
    if (!_fileIconIv) {
        _fileIconIv = [UIImageView new];
        _fileIconIv.contentMode = UIViewContentModeScaleAspectFill;
        _fileIconIv.clipsToBounds = YES;
        [self.contentView addSubview:_fileIconIv];
    }
    return _fileIconIv;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.textColor = [ESColor labelColor];
        _fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _fileNameLabel.font = ESFontPingFangRegular(16);
        [self.contentView addSubview:_fileNameLabel];
    }
    return _fileNameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [ESColor secondaryLabelColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = ESFontPingFangRegular(12);
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setEnlargeEdge:UIEdgeInsetsMake(20, 10, 20, 20)];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 7;
        btn.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
        [btn addTarget:self action:@selector(onSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _selectBtn = btn;
    }
    return _selectBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_lineView];
    }
    return _lineView;
}


@end



