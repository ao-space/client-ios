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
//  ESV2PhotoCell.m
//  EulixSpace
//
//  Created by qu on 2022/12/19.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESV2PhotoCell.h"
#import "ESThemeDefine.h"
#import "NSString+ESTool.h"
#import "PHAsset+ESTool.h"
#import "UILabel+ESAutoSize.h"
#import "ESThemeDefine.h"
#import "ESFileInfoPub.h"
#import "NSDate+Format.h"
#import "ESFileDefine.h"
#import "ESLocalPath.h"
#import <Masonry/Masonry.h>
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "UIImageView+ESThumb.h"
#import <Masonry/Masonry.h>

@interface ESV2PhotoCell ()
/// 相片
@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) UILabel *time1;
/// 选中按钮
@property (nonatomic, strong) UIButton *selectButton;
/// 半透明遮罩
@property (nonatomic, strong) UIView *translucentView;

@property (nonatomic, strong) UILabel *duration;
@end

@implementation ESV2PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self photoImageView];
        [self translucentView];
        [self selectButton];
        [self selectIcon];
    }

    return self;
}

#pragma mark - Set方法
- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    self.translucentView.hidden = !isSelect;
    self.selectIcon.image = isSelect ? IMAGE_FILE_SELECTED : nil;
    self.selectIcon.layer.borderWidth = isSelect ? 0 : 1;
    //_translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

#pragma mark - 加载图片


- (void)selectPhoto:(UIButton *)button {
    if (self.selectPhotoAction) {
          self.selectPhotoAction(self.info);
    }
}

-(void)setInfo:(ESFileInfoPub *)info{
    _info = info;
    self.photoImageView.image = IconForFile(info);
    self.translucentView.hidden = !info.isSelected;
    self.selectIcon.image = info.isSelected ? IMAGE_FILE_SELECTED : nil;
    self.selectIcon.layer.borderWidth = info.isSelected ? 0 : 1;
    if([info.mime containsString:@"video"]){
        self.time1.hidden = NO;
    }else{
        self.time1.hidden = YES;
    }
  
    self.time1.text = [self getMMSSFromSS:info.duration.integerValue];
    
    [self.time1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-4.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-4.0f);
        make.height.mas_equalTo(14.0f);

    }];
    if (IsMediaForFile(info)) {
        [self.photoImageView es_setThumbImageWithFile:info
                                            size:CGSizeZero
                                     placeholder:IMAGE_CLOUD_IMAGE_DEFAULT
                                       completed:^(BOOL ok) {
                    
                                       }];
    }
}



#pragma mark - Get方法
- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [UIImageView new];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.masksToBounds = YES;
        _photoImageView.layer.cornerRadius = 4;
        [self.contentView addSubview:_photoImageView];
        [_photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return _photoImageView;
}

- (UIImageView *)selectIcon {
    if (!_selectIcon) {
        _selectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 22, 22)];
        _selectIcon.contentMode = UIViewContentModeScaleAspectFill;
        _selectIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectIcon.layer.borderWidth = 1.f;
        _selectIcon.layer.cornerRadius = 11.f;
        _selectIcon.layer.masksToBounds = YES;
        [self.contentView addSubview:_selectIcon];
    }
    return _selectIcon;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
        _selectButton.frame = CGRectMake(0, 0, 44, 44);
    }

    return _selectButton;
}

- (UIView *)translucentView {
    if (!_translucentView) {
        _translucentView = [[UIView alloc] init];
        _translucentView.backgroundColor = [ESColor.darkTextColor colorWithAlphaComponent:0.2];
        [self.contentView addSubview:_translucentView];
        _translucentView.hidden = YES;
        [_translucentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return _translucentView;
}

- (UILabel *)duration {
    if (!_duration) {
        _duration = [UILabel new];
        _duration.textColor = ESColor.lightTextColor;
        _duration.font = [UIFont systemFontOfSize:10 weight:(UIFontWeightMedium)];
        [self.contentView addSubview:_duration];
        [_duration mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(self.contentView).inset(4);
            make.width.mas_equalTo(28);
            make.height.mas_equalTo(14);
        }];
    }
    return _duration;
}

-(NSString *)getMMSSFromSS:(NSInteger)seconds{

    seconds = seconds/1000;


    //format of minute

    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60 + (seconds/3600)*60];

    //format of second

    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];

    //format of time

    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
   
    return format_time;

}

- (UILabel *)time1 {
    if (!_time1) {
        _time1 = [[UILabel alloc] init];
        _time1.textColor = [UIColor whiteColor];
        _time1.textAlignment = NSTextAlignmentCenter;
        _time1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        [self.contentView addSubview:_time1];
    }
    return _time1;
}


@end
