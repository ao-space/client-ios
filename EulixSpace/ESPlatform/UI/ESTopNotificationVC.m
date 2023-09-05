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
//  ESTopNotificationVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/7/19.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESTopNotificationVC.h"
#import "ESGlobalMacro.h"

@interface ESTopNotificationVC ()

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *avatarName;

@end

static NSInteger const gMessageMaxLine = 5;

@implementation ESTopNotificationVC

+ (instancetype)notificationWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    ESTopNotificationVC *instance = [[self alloc] init];
    instance.alertTitle = title;
    instance.message = message;
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    [self setupShadow];
    
    [self.view addSubview:self.avatar];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20.0f);
        make.width.height.mas_equalTo(16.0f);
        make.top.mas_equalTo(self.view.mas_top).offset(13.0f);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(13.0f);
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.avatar);
        make.right.mas_equalTo(self.view.mas_right).offset(-10.0f);
    }];

    [self.view addSubview:self.detailLabel];
    [self addeGestures];
}

- (void)setupShadow {
    self.view.layer.cornerRadius = 10;
    self.view.layer.shadowColor = [ESColor.darkTextColor colorWithAlphaComponent:0.15].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 8;
    self.view.backgroundColor = ESColor.systemBackgroundColor;
}

- (void)addeGestures {
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapGecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGecognizer];
    
    [tapGecognizer requireGestureRecognizerToFail:recognizer];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
   if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
       [self swipeHidden];
   }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
    if (self.tapBlock) {
        self.tapBlock();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.view.superview != nil && self.isViewLoaded && self.view.window) {
            [self hidden];
            return;
        }
    });
}

- (void)setIconImageWithName:(NSString *)imageName {
    _avatarName = imageName;
}

- (void)loadData {
    self.avatar.image = _avatarName.length > 0 ? [UIImage imageNamed:_avatarName] : nil;
    self.titleLabel.text = self.alertTitle;
    self.detailLabel.text = self.message;
    
    CGSize detailSize = [self sizeOfMessage:self.message];
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(detailSize);
        make.left.mas_equalTo(self.view.mas_left).offset(46.0f);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-10.0f);
    }];
  
    self.view.frame = CGRectMake(10, kStatusBarHeight + 8, ScreenWidth - 20, 10 + 22 + 16 + detailSize.height);
}

- (void)show {
    [self loadData];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self autoHidden];
    }];
}

- (void)autoHidden {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.view.superview != nil && self.isViewLoaded && self.view.window) {
            [self hidden];
            return;
        }
    });
}

- (void)hidden {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)swipeHidden {
    CGRect frame = self.view.frame;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width,  frame.size.height);
        self.view.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


#pragma mark - Lazy Load

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [UIImageView new];
    }
    return _avatar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = ESColor.secondaryLabelColor;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = gMessageMaxLine;
        _detailLabel.font = ESFontPingFangRegular(12);
    }
    return _detailLabel;
}

- (CGSize)sizeOfMessage:(NSString *)subtitle {
    if (subtitle.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    CGFloat width = [self contentViewWidth] - 46 - 19;
    
    CGSize size = [subtitle boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : ESFontPingFangRegular(12)}
                                         context:nil].size;
    
    size.height = ceil(size.height);
    size.width = ceil(width);
    return size;
}

- (CGFloat)contentViewWidth {
    return [UIScreen mainScreen].bounds.size.width - 20;
}

@end


