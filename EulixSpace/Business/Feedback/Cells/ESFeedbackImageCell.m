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
//  ESFeedbackImageCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/11/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFeedbackImageCell.h"
#import "ESFeedbackDefine.h"
#import "ESFeedbackImagItem.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

@interface ESFeedbackImageCell ()

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) ESFormItem *model;

@end

@implementation ESFeedbackImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(22);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];

    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.title.mas_bottom).inset(10);
        make.height.mas_equalTo(0);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(14);
        make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
    }];
}

- (void)reloadWithData:(ESFormItem *)model {
    self.model = model;
    NSMutableArray<ESFeedbackImagItem *> *imagePathArray = model.data;
    self.title.text = [NSString stringWithFormat:model.title, @(imagePathArray.count)];
    self.content.text = model.content;
    [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.width);
    }];
    [self showImages:imagePathArray];
}

- (void)showImages:(NSArray<ESFeedbackImagItem *> *)imagePathArray {
    [self.container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    __block CGFloat offset = 0;
    CGFloat width = self.model.width;
    [imagePathArray enumerateObjectsUsingBlock:^(ESFeedbackImagItem *_Nonnull obj,
                                                 NSUInteger idx,
                                                 BOOL *_Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, 0, width, width)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = obj.image;
        [self.container addSubview:imageView];

        UIButton *remove = [UIButton new];
        remove.tag = idx;
        remove.frame = CGRectMake(offset + width - 20, 0, 20, 20);
        [remove setImage:IMAGE_UPLOAD_IMAGE_DELETE forState:UIControlStateNormal];
        [remove addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.container addSubview:remove];

        offset += width + 6;
    }];
    if (imagePathArray.count < 4) {
        UIButton *add = [UIButton new];
        add.frame = CGRectMake(offset, 0, width, width);
        [add setImage:IMAGE_UPLOAD_IMAGE forState:UIControlStateNormal];
        [add addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
        [self.container addSubview:add];
    }
}

- (void)addImage {
    if (self.actionBlock) {
        self.actionBlock(@(ESFeedbackActionAddImage));
    }
}

- (void)removeImage:(UIButton *)sender {
    NSInteger idx = sender.tag;
    NSMutableArray<ESFeedbackImagItem *> *imagePathArray = self.model.data;
    if (idx > imagePathArray.count - 1) {
        [imagePathArray removeAllObjects];
    } else {
        [imagePathArray removeObjectAtIndex:idx];
    }
    [self showImages:imagePathArray];
}

#pragma mark - Lazy Load

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [self addSubview:_container];
    }
    return _container;
}

@end
