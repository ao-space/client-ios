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
//  ESAppV2SettingCell.m
//  EulixSpace
//
//  Created by qu on 2023/7/17.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESAppV2SettingCell.h"
#import "ESToast.h"
#import "ESCommonToolManager.h"

#import "UIButton+Extension.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"

@interface ESAppV2SettingCell()


@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) UIButton *arrowButton;

@property (strong,nonatomic) UISwitch *adminSwitch;

@property (strong,nonatomic) UIButton *startBtn;

@property (strong,nonatomic) UIButton *stopBtn;

@property (nonatomic, strong) UILabel *subtitleLabel;


@property (nonatomic, strong) UIView *lineView;

@property (strong,nonatomic) UIButton *reStartBtn;

@end

@implementation ESAppV2SettingCell

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

        [self.adminSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.right.mas_equalTo(self.bgView.mas_right).offset(-20.0f);
            make.width.mas_equalTo(@50);
            make.height.mas_equalTo(@30);
        }];
        

        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14.0];
        self.subtitleLabel.textColor = [UIColor grayColor];
        self.subtitleLabel.numberOfLines = 2;
        self.subtitleLabel.textAlignment = NSTextAlignmentRight;
        [self.bgView addSubview:self.subtitleLabel];

        
        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.right.mas_equalTo(self.bgView.mas_right).offset(-20.0f);
            make.left.mas_equalTo(self.titleLabel.mas_right).offset(10.0f);
        }];
        
        
        UIView * lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor es_colorWithHexString:@"#EBECF0"];
        [self.contentView addSubview:lineView];
        self.lineView = lineView;

        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX).multipliedBy(1);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(@1);
            make.height.mas_equalTo(@42);
        }];
        
        [self.stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView.mas_left).offset(0);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo((ScreenWidth - 40)/2);
            make.height.mas_equalTo(@50);
        }];
        
        [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX).multipliedBy(1);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
                
        [self.reStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          
            make.left.equalTo(self.stopBtn.mas_right).offset(0).offset(1);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo((ScreenWidth - 40)/2);
            make.height.mas_equalTo(@50);
        }];

        // 设置分割线
        UIView *separatorView = [[UIView alloc] init];
    
        separatorView.backgroundColor = [UIColor es_colorWithHexString:@"#EBECF0"];
        [self.bgView addSubview:separatorView];
        [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgView.mas_bottom);
            make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
            make.right.mas_equalTo(self.bgView.mas_right).offset(-20.0f);
            make.height.mas_equalTo(@1);
        }];
        self.separatorView = separatorView;

    }
    return self;
}



-(void)setItem:(ESV2SettingModel *)item{
    _item = item;
    self.titleLabel.text = item.titleStr;
    self.titleLabel.hidden = NO;
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
        make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
        make.height.mas_equalTo(@57);
    }];
    
    if ([ESCommonToolManager isEnglish] && item.indexPath.section == 1) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
            make.width.mas_equalTo(@180);
        }];
    }else{
        if([ESCommonToolManager isEnglish]){
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.bgView.mas_centerY);
                make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                make.width.mas_equalTo(@120);
            }];
        }else{
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.bgView.mas_centerY);
                make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                make.width.mas_equalTo(@80);
            }];
        }
    }
 
    if(item.type == ESV2SettingCellTypePower ){
        self.stopBtn.hidden = YES;
        self.lineView.hidden = YES;
        self.reStartBtn.hidden = YES;
        self.adminSwitch.hidden = NO;
        self.startBtn.hidden = YES;
        self.subtitleLabel.hidden = YES;
    }else if(item.type == ESV2SettingCellTypeService){
        self.stopBtn.hidden = YES;
        self.reStartBtn.hidden = YES;
        self.lineView.hidden = YES;
        self.startBtn.hidden = YES;
        self.adminSwitch.hidden = YES;
        self.subtitleLabel.hidden = NO;
        if(self.item.indexPath.row == 0){
            self.subtitleLabel.text = self.containerInfo.serviceName;
        }else if(self.item.indexPath.row == 1){
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.bgView.mas_centerY);
                make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                make.width.mas_equalTo(@60);
            }];
            self.startBtn.hidden = YES;
            
            self.subtitleLabel.text = self.containerInfo.containerId;
        }else if(self.item.indexPath.row == 2){
            self.startBtn.hidden = YES;
            NSString *timestampString = self.containerInfo.createdAt;
            // 创建一个NSDateFormatter实例
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSZ"];

            // 将时间戳字符串转换为NSDate对象
            NSDate *timestampDate = [dateFormatter dateFromString:timestampString];

            // 设置新的日期格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

            // 将NSDate对象转换为分钟精度的时间字符串
            NSString *minuteString = [dateFormatter stringFromDate:timestampDate];

            self.subtitleLabel.text = minuteString;
        }else if(self.item.indexPath.row == 3){
            NSString *timestampString = self.containerInfo.startedAt;
            // 创建一个NSDateFormatter实例
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSZ"];

            // 将时间戳字符串转换为NSDate对象
            NSDate *timestampDate = [dateFormatter dateFromString:timestampString];

            // 设置新的日期格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

            // 将NSDate对象转换为分钟精度的时间字符串
            NSString *minuteString = [dateFormatter stringFromDate:timestampDate];
            self.subtitleLabel.text = minuteString;
        }else if(self.item.indexPath.row == 4){
            if([self.containerInfo.webLink containsString:@"http"]){
                self.subtitleLabel.text = self.containerInfo.webLink;
            }else{
                NSString *webUrl = [NSString stringWithFormat:@"https://%@",  self.containerInfo.webLink];
                self.subtitleLabel.text = webUrl;
            }

            if ([ESCommonToolManager isEnglish]) {
                [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.bgView.mas_centerY);
                    make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                    make.width.mas_equalTo(@70);
                }];
            }
   
        }else if(self.item.indexPath.row == 5){
            if(self.containerInfo.ports.count > 0 && [self.titleLabel.text isEqual:NSLocalizedString(@"Port",@"端口")]) {
                NSString *portsString = [self.containerInfo.ports componentsJoinedByString:@"\n"];
                self.subtitleLabel.text = portsString;
            }else{
                self.subtitleLabel.text = @"";
            }
        }
    } else if(item.type == ESV2SettingCellTypeParameter){
        
        if([self.containerInfo.status isEqual:@"exited"]){
            [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-20.0f);;
                make.left.mas_equalTo(self.contentView.mas_left).offset(20.0f);
                make.height.mas_equalTo(@120);
            }];
            self.titleLabel.hidden = YES;
            self.stopBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.reStartBtn.hidden = YES;
            self.adminSwitch.hidden = YES;
            self.startBtn.hidden = YES;
            self.subtitleLabel.hidden = YES;
            self.titleLabel.hidden = YES;
 
  }else{
    
            self.stopBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.reStartBtn.hidden = YES;
            self.adminSwitch.hidden = YES;
            self.startBtn.hidden = YES;
            self.subtitleLabel.hidden = NO;
            self.titleLabel.hidden = NO;
            if(self.item.indexPath.row == 0){
            self.subtitleLabel.text = [self getRunTime:self.containerInfo.startedAt];
            }else if(self.item.indexPath.row == 1){
                [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.bgView.mas_centerY);
                    make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                    make.width.mas_equalTo(@100);
                }];
                self.subtitleLabel.text = self.statsInfo.cpu;
            }else if(self.item.indexPath.row == 2){
              
                if ([ESCommonToolManager isEnglish]) {
                    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(self.bgView.mas_centerY);
                        make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                        make.width.mas_equalTo(@200);
                    }];
                }else{
                    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(self.bgView.mas_centerY);
                        make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
                        make.width.mas_equalTo(@150);
                    }];
                }
                NSString *memoryUsage = self.statsInfo.memoryUsage;
                NSArray *components = [memoryUsage componentsSeparatedByString:@" / "];
                NSString *desiredString = components.firstObject; // 获取分割后的第一个部分
                self.subtitleLabel.text = desiredString;
            }else if(self.item.indexPath.row == 3){
                self.subtitleLabel.text = self.statsInfo.disk;
            }else if(self.item.indexPath.row == 4){
                self.subtitleLabel.text = self.statsInfo.network;
            }
       }
    }
    else{
       
        if([self.containerInfo.status isEqual:@"exited"]){
            self.stopBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.reStartBtn.hidden = YES;
            self.startBtn.hidden = NO;
            self.adminSwitch.hidden = YES;
            self.subtitleLabel.hidden = YES;
            self.titleLabel.hidden = YES;
        }else{
            self.stopBtn.hidden = NO;
            self.reStartBtn.hidden = NO;
            self.lineView.hidden = NO;
            self.startBtn.hidden = YES;
            self.adminSwitch.hidden = YES;
            self.subtitleLabel.hidden = YES;
            self.titleLabel.hidden = YES;
        }
     
    }
    if(self.item.isOpen){
        [self.adminSwitch setOn:YES];
        //self.adminSwitch.enabled = NO;
    }else{
        [self.adminSwitch setOn:NO];
    }
    if(!self.adminSwitch.hidden){
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bgView.mas_centerY);
            make.left.mas_equalTo(self.bgView.mas_left).offset(20.0f);
        }];
    }
}

- (UIButton *)stopBtn {
    if (nil == _stopBtn) {
        
        _stopBtn = [UIButton es_create:NSLocalizedString(@"application_stop",@"强制停止")font:ESFontPingFangMedium(16) txColor:@"#337AFF" bgColor:@"#F5F6FA" target:self selector:@selector(didClickStopBtn)];
        [self.contentView addSubview:_stopBtn];
    }
    return _stopBtn;
}

- (UIButton *)startBtn {
    if (nil == _startBtn) {
        
        _startBtn = [UIButton es_create:NSLocalizedString(@"application_start",@"启动服务") font:ESFontPingFangMedium(16) txColor:@"#337AFF" bgColor:@"#F5F6FA" target:self selector:@selector(didClickStartBtn)];
        _startBtn.hidden = YES;
        [self.contentView addSubview:_startBtn];
    }
    return _startBtn;
}


- (UIButton *)reStartBtn {
    if (nil == _reStartBtn) {
     
        _reStartBtn = [UIButton es_create:NSLocalizedString(@"application_restart",@"重新启动") font:ESFontPingFangMedium(16) txColor:@"#337AFF" bgColor:@"#F5F6FA" target:self selector:@selector(didClickReSetBtn)];
        [self.contentView addSubview:_reStartBtn];
    }
    return _reStartBtn;
}

- (UISwitch *)adminSwitch {
    if (nil == _adminSwitch) {
        _adminSwitch = [[UISwitch alloc] init];
        [self.contentView addSubview:_adminSwitch];
        [_adminSwitch addTarget:self
                        action:@selector(adminSwitch:)
              forControlEvents:UIControlEventValueChanged];
        [_adminSwitch setOn:NO];
    }
    return _adminSwitch;
}

- (void)adminSwitch:(UISwitch *)sender {
    if (sender.on) {
        [ESToast toastSuccess:@"暂时不支持打开"];
    } else {
        self.actionSwitchBlock(@"0");
    }
    if (sender.isOn) {
        sender.on = NO; // 如果 UISwitch 被打开了，则将其关闭
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
