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
//  ESEmptyView.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/7/13.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESEmptyView.h"
#import "ESGradientButton.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import <Masonry/Masonry.h>

@interface ESEmptyView ()

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, readonly) UIView *contentView;

@property (nonatomic, strong) ESGradientButton *button;

@end

@implementation ESEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self initUI];
    return self;
}

- (void)initUI {
    self.contentView.backgroundColor = ESColor.systemBackgroundColor;
    
    if([self.type isEqual:@"main"]){
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(20);
            make.size.mas_equalTo(CGSizeZero);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView).inset(0);
            make.size.mas_equalTo(CGSizeZero);
            make.centerX.mas_equalTo(self.backgroundView);
        }];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom).offset(40);
            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
            make.height.mas_equalTo(0);
        }];

        [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom).inset(40);
            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
            make.height.mas_equalTo(0);
        }];
    }else{
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).inset(96);
            make.size.mas_equalTo(CGSizeZero);
            make.centerX.mas_equalTo(self.contentView);
        }];
        
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView).inset(32);
            make.size.mas_equalTo(CGSizeZero);
            make.centerX.mas_equalTo(self.backgroundView);
        }];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom).offset(40);
            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
            make.height.mas_equalTo(0);
        }];

        [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom).inset(40);
            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)reloadWithData:(ESEmptyItem *)data {
    if (!data.backgroundImage) {
        self.backgroundView.image = IMAGE_EMPTY_BG;
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).inset(data.topOffset);
            make.size.mas_equalTo(self.backgroundView.image.size);
        }];
        self.icon.image = data.icon;
        [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(data.icon.size);
        }];
    } else {
        self.backgroundView.image = data.backgroundImage;
        [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).inset(data.topOffset);
            make.size.mas_equalTo(data.backgroundImage.size);
        }];
        self.icon.image = nil;
    }

    CGFloat offset = 40;
    self.title.text = data.title;
    if (self.title.text.length > 0) {
        CGFloat titleHeight = [self.title.text es_heightFitWidth:ScreenWidth - 62 font:self.title.font];
        [self.title mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(titleHeight);
        }];
        offset += titleHeight + 10;
    }
    if (data.attributedContent) {
        self.content.text = nil;
        self.content.attributedText = data.attributedContent;
        CGFloat contentHeight = [data.attributedContent es_sizeForWidth:ScreenWidth - 62 height:ScreenHeight].height;
        [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(contentHeight);
            make.top.mas_equalTo(self.backgroundView.mas_bottom).inset(offset);
        }];
    } else if (data.content) {
        self.content.attributedText = nil;
        self.content.text = data.content;
        CGFloat contentHeight = [self.content.text es_heightFitWidth:ScreenWidth - 62 font:self.content.font];
        [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(contentHeight);
        }];
    }

    _button.hidden = YES;
    if (data.actionTitle.length > 0) {
        self.button.hidden = NO;
        [self.button setTitle:data.actionTitle forState:UIControlStateNormal];
    }
    if (self.onLoad) {
        self.onLoad(self.backgroundView);
    }
}

- (void)action:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock(@(sender.tag));
    }
}

#pragma mark - Lazy Load

- (UIView *)contentView {
    return self;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIImageView new];
        [self.contentView addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentCenter;
        _content.numberOfLines = 0;
        _content.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (ESGradientButton *)button {
    if (!_button) {
        _button = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_button setCornerRadius:10];
        _button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_button setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.contentView addSubview:_button];
        [_button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.content.mas_bottom).inset(30);
            make.centerX.mas_equalTo(self.contentView);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(200);
        }];
    }
    return _button;
}

//-(void)setType:(NSString *)type{
//    _type = type;
//    if([self.type isEqual:@"main"]){
//        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.contentView.mas_top).offset(20);
//            make.size.mas_equalTo(CGSizeZero);
//            make.centerX.mas_equalTo(self.contentView);
//        }];
//        
//        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.backgroundView).inset(0);
//            make.size.mas_equalTo(CGSizeZero);
//            make.centerX.mas_equalTo(self.backgroundView);
//        }];
//
//        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.backgroundView.mas_bottom).offset(40);
//            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
//            make.height.mas_equalTo(0);
//        }];
//
//        [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.backgroundView.mas_bottom).inset(40);
//            make.left.right.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
//            make.height.mas_equalTo(0);
//        }];
//    }
//}

@end
