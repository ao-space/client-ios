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
//  ESESAppV2SettingPostCell.m
//  EulixSpace
//
//  Created by qu on 2023/8/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

//
//  ESAppV2SettingCell.m
//  EulixSpace
//
//  Created by qu on 2023/7/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESESAppV2SettingPostCell.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"
#import "UIButton+Extension.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"


@interface ESESAppV2SettingPostCell()


@property (nonatomic, strong) UIImageView *cellImageView;


@property (nonatomic, strong) UILabel *subtitleLabel;


@property (nonatomic, strong) UIView *lineView;



@end

@implementation ESESAppV2SettingPostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 创建并添加UILabel和UIImageView
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor es_colorWithHexString:@"#F5F6FA"];
        [self.contentView addSubview:self.bgView];
        
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
            make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
            make.height.mas_equalTo(@57);
        }];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 30)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.bgView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
            make.width.mas_equalTo(@100);
        }];

    
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14.0];
        self.subtitleLabel.textColor = [UIColor grayColor];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textAlignment = NSTextAlignmentRight;
        [self.bgView addSubview:self.subtitleLabel];

        
        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.right.mas_equalTo(self.bgView.mas_right).offset(-20.0f);
            make.left.mas_equalTo(self.titleLabel.mas_right).offset(10.0f);
        }];
    }
    return self;
}



-(void)setItem:(ESV2SettingModel *)item{
    _item = item;
    self.titleLabel.text = item.titleStr;
    self.titleLabel.hidden = NO;
    if(self.containerInfo.ports.count > 0 && [self.titleLabel.text isEqual:NSLocalizedString(@"Port",@"端口")]) {
        NSString *portsString = [self.containerInfo.ports componentsJoinedByString:@"\n"];
        self.subtitleLabel.text = portsString;
    }else{
        self.subtitleLabel.text = @"";
    }
    if(self.containerInfo.ports.count <= 1){
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
            make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
            make.height.mas_equalTo(57);
        }];
    }else{
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
            make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
            make.height.mas_equalTo(self.containerInfo.ports.count *23);
        }];
    }
}



- (void)didClickReSetBtn {
    if (self.actionReSetBlock) {
        self.actionReSetBlock(@"1");
    }
}


- (void)didClickStopBtn {
    if (self.actionStoptBtnBlock) {
        self.actionStoptBtnBlock(@"1");
    }
}

- (void)didClickStartBtn {
    if (self.actionStartBlock) {
        self.actionStartBlock(@"1");
    }
}

- (NSString *)getRunTime:(NSString *)timestampString {
    // 创建一个NSDateFormatter实例
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSZ"];

    // 将时间戳字符串转换为NSDate对象
    NSDate *timestampDate = [dateFormatter dateFromString:timestampString];
    
    NSDate *currentDate = [NSDate date];

    // 计算时间差
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *components = [calendar components:units fromDate:timestampDate toDate:currentDate options:0];
    NSString *formattedString = @"";
    if([ESCommonToolManager isEnglish]){
        // 根据时间差进行格式化

        if (components.day > 0) {
            if(components.day > 1){
                formattedString = [NSString stringWithFormat:@"%ld days %ld hours", (long)components.day, (long)components.hour];
            }else{
                formattedString = [NSString stringWithFormat:@"%ld day %ld hours", (long)components.day, (long)components.hour];
            }
       
        } else if (components.hour > 0 &&components.minute> 30) {
                formattedString = [NSString stringWithFormat:@"%ld hours", (long)components.hour +1];
        }
        else if (components.hour > 0 ) {
            if(components.hour == 1){
                formattedString = [NSString stringWithFormat:@"%ld hour", (long)components.hour];
            }else{
                formattedString = [NSString stringWithFormat:@"%ld hours", (long)components.hour];
            }
       } else {
           
            NSInteger minutes = components.minute;
            if (minutes <= 0) {
                minutes = 1; // 最少显示1分钟
            }
            formattedString = [NSString stringWithFormat:@"%ld分钟", (long)minutes];
        }
    }else{
        // 根据时间差进行格式化

        if (components.day > 0) {
            formattedString = [NSString stringWithFormat:@"%ld天 %ld小时", (long)components.day, (long)components.hour];
        } else if (components.hour > 0 &&components.minute> 30) {
            formattedString = [NSString stringWithFormat:@"%ld小时", (long)components.hour +1];
        }
        else if (components.hour > 0) {
           formattedString = [NSString stringWithFormat:@"%ld小时", (long)components.hour];
       } else {
            NSInteger minutes = components.minute;
            if (minutes <= 0) {
                minutes = 1; // 最少显示1分钟
            }
            formattedString = [NSString stringWithFormat:@"%ld分钟", (long)minutes];
        }
    }
   
    return formattedString;
}

@end



