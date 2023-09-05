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
//  ESADBannerItemCellCollectionViewCell.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/25.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESADBannerItemCell.h"

@interface ESADBannerItemCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ESADBannerItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.cornerRadius = 10.0f;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}


- (void)bindData:(id)data {
   
}
@end
