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
//  ESFileListCell.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/24.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileListCell.h"
#import "ESFileDefine.h"
#import "ESFormItem.h"
#import "ESThemeDefine.h"
#import "NSDate+Format.h"
#import "UIImageView+ESThumb.h"
#import <Masonry/Masonry.h>

@interface ESFileListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *content;

@property (nonatomic, strong) UIImageView *selection;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) ESFileInfoPub *fileMetadata;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, assign) BOOL isCopyMove;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) ESFileInfoPub *data;

@property (nonatomic, assign) BOOL isOnce;

@end

@implementation ESFileListCell

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
        make.left.mas_equalTo(self.contentView).inset(kESViewDefaultMargin);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).inset(20);
        make.right.mas_equalTo(self.contentView).offset(-44-24);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_top);
    }];

    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).inset(20);
        make.right.mas_equalTo(self.contentView).offset(-44-24);
        make.height.mas_equalTo(22);
        make.bottom.mas_equalTo(self.contentView).inset(10);
    }];

    [self.selection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-30.0f);
        make.width.height.mas_equalTo(14.0f);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-25.0f);
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

    self.isOnce = NO;
}

- (void)reloadWithData:(ESFormItem *)item {
    self.title.text = item.title;
    self.content.text = item.content;
    self.isCopyMove = item.isCopyMove;
    ESFileInfoPub *data = item.data;
    self.fileMetadata = data;

    self.category = item.category;
        
    if (data.searchKey.length > 0) {
        
        NSString *searchStr = data.searchKey;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:item.title];
        NSRange searchRange = NSMakeRange(0, item.title.length);
        NSRange foundRange;
        while ((foundRange = [item.title rangeOfString:searchStr options:0 range:searchRange]).location != NSNotFound) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:ESColor.primaryColor range:foundRange];
            searchRange = NSMakeRange(NSMaxRange(foundRange), item.title.length - NSMaxRange(foundRange));
        }
        self.title.attributedText = attributedString;
    }

    if ([self.category isEqual:@"RecycleBin"]) {
        [self.selectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(0.0f);
            make.left.mas_equalTo(self.contentView.mas_left).offset(0.0f);
            make.top.mas_equalTo(self.contentView.mas_top).offset(0.0f);
            make.height.mas_equalTo(76);
        }];
    }
    if (!data.isDir.boolValue && data.mime) {
        UIImage *image = IconForFile(data);
        self.icon.image = image;
        if (IsMediaForFile(data)) {
            [self.icon es_setThumbImageWithFile:data placeholder:image];
        }
    } else {
        self.icon.image = IMAGE_FILE_FOLDER;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:data.operationAt.integerValue / 1000];
    NSString *time = [date stringFromFormat:@"YYYY-MM-dd HH:mm"];
    
    if (data.isDir.boolValue) {
        self.content.text = time;
    } else {
        self.content.text = [NSString stringWithFormat:@"%@ %@",time, FileSizeString(data.size.unsignedLongLongValue, YES) ];
    }
    self.isSelected = item.selected;
    
    if (self.isCopyMove) {
        self.selection.image = IMAGE_FILE_COPYBACK;
    }else{
        self.selection.image = item.selected ? IMAGE_FILE_SELECTED : nil;
        _selection.backgroundColor = [ESColor secondarySystemBackgroundColor];
        self.selectBtn.userInteractionEnabled = YES;
    }
    
    if (item.selected) {
        [self.selection mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-kESViewDefaultMargin);
            make.width.height.mas_equalTo(22.0f);
            make.centerY.mas_equalTo(self.contentView);
            
      
            NSDictionary *dic = @{@"isSelected" : @(1),
                                 @"uuid" : data.uuid};

        }];
    } else {
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
    if (self.isCopyMove) {
        return;
    }

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
    [dic setValue:self.fileMetadata.uuid forKey:@"uuid"];

    NSString *notificationName = [NSString stringWithFormat:@"cellSelectedNSNotification%@", self.category];
    if ([notificationName isEqual:@"cellSelectedNSNotificationsearch"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:dic];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:dic];
    }
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self.contentView addSubview:_line];
    }
    return _line;
}

//-(void)lpGR:(UILongPressGestureRecognizer *)lpGR
//{
//    if([self.category isEqual:@"v2FileListVC"] && self.isOnce == NO){
//        self.isOnce = YES;
//        [self didClickSelection];
//    }
//}

@end
