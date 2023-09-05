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
//  ESShreCell.m
//  EulixSpace
//
//  Created by qu on 2022/6/27.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShreCell.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "ESCommonToolManager.h"
#import "UIImageView+ESThumb.h"
#import <Masonry/Masonry.h>
#import "ESMyShareRsp.h"
@interface ESShreCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UILabel *lookNumLabel;

@property (nonatomic, strong) UILabel *exceedTimeLabel;

@property (nonatomic, strong) UIImageView *selection;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) ESMyShareRsp *fileMetadata;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, assign) BOOL isCopyMove;

@property (nonatomic, strong) UIView *line;


@end

@implementation ESShreCell

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
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(26.0);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).inset(20);
        make.right.mas_equalTo(self.contentView).offset(-44 - 24);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.contentView.mas_top).offset(19);;
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-44 - 24);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.title.mas_bottom).offset(6);
    }];
    
    [self.lookNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(20);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.content.mas_bottom).offset(6);
    }];

    [self.exceedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lookNumLabel.mas_right).offset(20);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.content.mas_bottom).offset(6);
    }];

    [self.selection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-30.0f);
        make.width.height.mas_equalTo(14.0f);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15.0f);
        make.width.height.mas_equalTo(60.0f);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-1.0f);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-25.0f);
        make.left.mas_equalTo(self.contentView.mas_left).offset(25.0f);
        make.height.mas_equalTo(1.0f);
    }];
    self.selectedArray = [[NSMutableArray alloc] init];
    self.isSelected = NO;
}


- (void)reloadWithData:(ESFormItem *)item {
    ESMyShareRsp *data = item.data;
    NSNumber *fileCountNum = data.fileCount;
    if(fileCountNum.intValue > 1){
        self.title.text = [NSString stringWithFormat:NSLocalizedString(@"%@ and so on", @"等多个文件"),data.fileName];
    }else{
        self.title.text = data.fileName;
    }
    if([data.isDir boolValue] || data.fileCount.intValue > 1){
        self.icon.image = IMAGE_SHARE_ICON;
    }else{
        self.icon.image = IconForShareFile(data);
    }
   
    self.fileMetadata = data;
    self.category = item.category;

    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"Number of Views", @"浏览次数"),data.haveExploredTimes,data.maxExploredTimes];
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    if ([ESCommonToolManager isEnglish]) {
        [aAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                                  value:ESColor.primaryColor
                                range:NSMakeRange(str.length-3, 1)];
    }else{
        [aAttributedString addAttribute:NSForegroundColorAttributeName  //文字颜色
                                  value:ESColor.primaryColor
                                range:NSMakeRange(str.length-3, 1)];
    }

//    111
    self.lookNumLabel.attributedText = aAttributedString;
    
    //self.lookNumLabel.text = [NSString stringWithFormat:@"浏览次数: %@/10",data.haveExploredTimes];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:data.createTime.integerValue / 1000];
    NSString *time = [date stringFromFormat:@"YYYY-MM-dd HH:mm"];
    self.content.text = time;

    self.selection.image = item.selected ? IMAGE_FILE_SELECTED : nil;
    _selection.backgroundColor = [ESColor secondarySystemBackgroundColor];
    
    NSDate *date4 = [NSDate dateWithTimeIntervalSince1970:data.expiredTime.integerValue / 1000];
    
    NSDate *date5 = [NSDate dateWithTimeIntervalSince1970:data.boxTime.integerValue / 1000];


    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:date5 toDate:date4 options:0];

    if(cmps.day + 1 < 0){
        self.exceedTimeLabel.text = NSLocalizedString(@"ULink Failure", @"链接失效");
        self.exceedTimeLabel.textColor = ESColor.redColor;
    }else{
        self.exceedTimeLabel.textColor = ESColor.labelColor;
        NSString *day =[NSString stringWithFormat:@"%ld",cmps.day];
      
        if(cmps.day < 1 && cmps.hour > 0){
            day = @"1";
        }
        NSString *export = [NSString stringWithFormat:NSLocalizedString(@"Expires in day", @"%@ 天后过期"),day];
        
        NSMutableAttributedString * aAttributedStringDay = [[NSMutableAttributedString alloc] initWithString:export];
        if ([ESCommonToolManager isEnglish]) {
            [aAttributedStringDay addAttribute:NSForegroundColorAttributeName  //文字颜色
                                      value:ESColor.primaryColor
                                    range:NSMakeRange(export.length - 6, day.length)];
        }else{
            [aAttributedStringDay addAttribute:NSForegroundColorAttributeName  //文字颜色
                                      value:ESColor.primaryColor
                                    range:NSMakeRange(0, day.length)];
        }

        self.exceedTimeLabel.attributedText = aAttributedStringDay;
    }
    
   
    if (item.selected) {
        self.isSelected = YES;
        [self.selection mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-kESViewDefaultMargin);
            make.width.height.mas_equalTo(22.0f);
            make.centerY.mas_equalTo(self.contentView);
        }];
    } else {
        self.isSelected = NO;
        [self.selection mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-30.0f);
            make.width.height.mas_equalTo(14.0f);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
}

#pragma mark - Lazy Load

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn addTarget:self action:@selector(didClickSelection) forControlEvents:UIControlEventTouchUpInside];
        //_selectBtn.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_selectBtn];
    }
    return _selectBtn;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        [self.contentView addSubview:_icon];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = ESColor.labelColor;
        _title.textAlignment = NSTextAlignmentLeft;
        _title.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_title];
    }
    return _title;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = ESColor.secondaryLabelColor;
        _content.textAlignment = NSTextAlignmentLeft;
        _content.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_content];
    }
    return _content;
}

- (UILabel *)lookNumLabel {
    if (!_lookNumLabel) {
        _lookNumLabel = [[UILabel alloc] init];
        _lookNumLabel.textColor = ESColor.labelColor;
        _lookNumLabel.textAlignment = NSTextAlignmentLeft;
        _lookNumLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_lookNumLabel];
    }
    return _lookNumLabel;
}

- (UILabel *)exceedTimeLabel {
    if (!_exceedTimeLabel) {
        _exceedTimeLabel = [[UILabel alloc] init];
        _exceedTimeLabel.textColor = ESColor.labelColor;
        _exceedTimeLabel.textAlignment = NSTextAlignmentLeft;
        _exceedTimeLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_exceedTimeLabel];
    }
    return _exceedTimeLabel;
}

- (UIImageView *)selection {
    if (!_selection) {
        _selection = [[UIImageView alloc] init];
        [self.contentView addSubview:_selection];
        _selection.layer.masksToBounds = YES;
        _selection.layer.cornerRadius = 14 / 2;
        _selection.userInteractionEnabled = YES;
    }
    return _selection;
}

//点击事件
- (void)didClickSelection {

    if (!self.isSelected) {
        self.selection.image = IMAGE_FILE_SELECTED;
        self.isSelected = YES;
        [self.selection mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-kESViewDefaultMargin);
            make.width.height.mas_equalTo(22.0f);
            make.centerY.mas_equalTo(self.contentView);
        }];
    } else {
        self.selection.image = nil;
        self.isSelected = NO;
        [self.selection mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-30.0f);
            make.width.height.mas_equalTo(14.0f);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@(self.isSelected) forKey:@"isSelected"];
    [dic setValue:self.fileMetadata.shareId forKey:@"shareId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cellSelectedNSNotificationShare" object:dic];
  
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
