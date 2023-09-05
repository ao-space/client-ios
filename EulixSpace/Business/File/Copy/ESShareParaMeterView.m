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
//  ESShareParaMeterView.m
//  EulixSpace
//
//  Created by qu on 2022/6/12.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareParaMeterView.h"
#import "UIButton+Extension.h"
#import "ESShareView.h"
#import "ESColor.h"
#import "ESCommonToolManager.h"
#import "ESCopyMoveFolderListVC.h"
#import "ESShreParaMeterViewCell.h"
#import "ESShareApi.h"

@interface ESShareParaMeterView()

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIImageView *promptImageView;
@property (nonatomic, strong) UILabel *selectNumLable;

@property (nonatomic, strong) UIButton *buildFolderBtn;
@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) ESCopyMoveFolderListVC *folderList;

@property (nonatomic, strong) NSString *pathUpLoadStr;
@property (nonatomic, strong) NSString *pathUpLoadUUID;

@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NSMutableArray *cellSelectedArray;

@property (nonatomic, strong) UIView *titlePointView;

@end

@implementation ESShareParaMeterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      //  [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }
}

///  返回
- (void)returnBtnClick:(UIButton *)returnBtn {
    self.hidden = YES;
   
}

- (void)didClickCompleteBtn:(UIButton *)delectBtn {
    
    if (self.actionBlock) {
        self.actionBlock(self.value);
        [[[UIApplication sharedApplication].keyWindow viewWithTag:self.tag] removeFromSuperview];
    }
    self.hidden = YES;
}

- (void)initUI {
    [super updateConstraints];
    self.pathUpLoadStr = @"";
    self.cellSelectedArray =[[NSMutableArray alloc] init];
    self.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(ScreenHeight - 400);
        make.left.equalTo(self.mas_left).offset(0.0f);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(400));
    }];

    [self.returnBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.programView.mas_left).offset(23.0f);
        make.top.equalTo(self.programView.mas_top).offset(24.0f);
        make.width.equalTo(@(18.0f));
        make.height.equalTo(@(18.0f));
    }];
    
    if([ESCommonToolManager isEnglish]){
        [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.programView.mas_right).offset(-20.0f);
            make.top.equalTo(self.programView.mas_top).offset(20.0f);
            make.height.equalTo(@(25.0f));
            make.width.equalTo(@(50.0f));
        }];
    }else{
        [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.programView.mas_right).offset(-20.0f);
            make.top.equalTo(self.programView.mas_top).offset(20.0f);
            make.height.equalTo(@(25.0f));
            make.width.equalTo(@(40.0f));
        }];
    }
 

    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.programView.mas_centerX);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.right.equalTo(self.delectBtn.mas_left).offset(-10.0f);
        make.height.equalTo(@(25.0f));
    }];
    
    if(self.tag == 30011){
        self.titleLabel.text = NSLocalizedString(@"Extraction Code", @"提取码");
        UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        UIView *autoView =  [self cellViewWithTitleStr:NSLocalizedString(@"Auto Generation", NSLocalizedString(@"Auto Generation", @"自动生成")) valueText:@""];
        autoView.tag = 20011;
        [autoView addGestureRecognizer:autoViewTap];
        [autoView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(80);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
//        "None" = "无";
//        NSLocalizedString(@"None", "无");
        UIView *date =  [self cellViewWithTitleStr:NSLocalizedString(@"None", @"无") valueText:@""];
        autoView.tag = 20012;
        UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [date addGestureRecognizer:dateTap];

         [date mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(160);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        
        [self.cellSelectedArray addObject:autoView];
        [self.cellSelectedArray addObject:date];
        
    }else if(self.tag == 30012){

        UIView *autoView =  [self cellViewWithTitleStr:NSLocalizedString(@"1 day", @"一天") valueText:@""];
        autoView.tag = 20011;
        self.titleLabel.text = NSLocalizedString(@"file_to_share_date", @"有效期");
        UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [autoView addGestureRecognizer:autoViewTap];
         [autoView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(80);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        
        UIView *date =  [self cellViewWithTitleStr:NSLocalizedString(@"7 Days", @"7天") valueText:@""];
        autoView.tag = 20012;
        UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [date addGestureRecognizer:dateTap];

         [date mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(160);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        
        UIView *shareNum =  [self cellViewWithTitleStr:NSLocalizedString(@"30 Days", @"30天") valueText:@""];
        shareNum.tag = 20013;
        UITapGestureRecognizer *shareNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [shareNum addGestureRecognizer:shareNumTap];
        [shareNum mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(240);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        [self.cellSelectedArray addObject:autoView];
        [self.cellSelectedArray addObject:date];
        [self.cellSelectedArray addObject:shareNum];
        
    }else if(self.tag == 30013){
        ESShreParaMeterViewCell *autoView =  [self cellViewWithTitleStr:NSLocalizedString(@"1 person", @"1人") valueText:@""];
        self.titleLabel.text = NSLocalizedString(@"file_to_share_people_num", @"分享人数");
        UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [autoView addGestureRecognizer:autoViewTap];
        [autoView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(80);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
        }];
        
        UIView *date =  [self cellViewWithTitleStr:NSLocalizedString(@"5 person", @"5人") valueText:@""];
        autoView.tag = 20012;
        UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [date addGestureRecognizer:dateTap];

        [date mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(160);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        
        UIView *shareNum =  [self cellViewWithTitleStr:NSLocalizedString(@"10 person", NSLocalizedString(@"10 person", @"10人")) valueText:@""];
        shareNum.tag = 20013;
        UITapGestureRecognizer *shareNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [shareNum addGestureRecognizer:shareNumTap];
        [shareNum mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(240);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];
        [self.cellSelectedArray addObject:autoView];
        [self.cellSelectedArray addObject:date];
        [self.cellSelectedArray addObject:shareNum];
        
        UIView *titlePointView =  [self cellViewWithTitleStr:NSLocalizedString(@"Share to more than one person", @"分享至多人，请注意遵循相关法律法规及司法解释等规定")  valueText:@""];
        titlePointView.tag = 20014;

        self.titlePointView= titlePointView;

        UITapGestureRecognizer *titlePointViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
        [titlePointView addGestureRecognizer:titlePointViewTap];
        [titlePointView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(320);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(80);
             make.width.mas_equalTo(ScreenWidth);
         }];

    }
}

-(void)titleTapShre{
    self.promptImageView.hidden = NO;
}

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 400, ScreenWidth, 300 + 100)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        [self addSubview:_programView];
    }
    return _programView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}


- (UIButton *)returnBtn {
    if (nil == _returnBtn) {
        _returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnBtn addTarget:self action:@selector(returnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_returnBtn setImage:IMAGE_SHARE_BACK_LEFT forState:UIControlStateNormal];
        [_returnBtn.layer setCornerRadius:3.0]; //设置矩圆角半径
        [self addSubview:_returnBtn];
    }
    return _returnBtn;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_delectBtn addTarget:self action:@selector(delectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
       // [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];
        [_delectBtn setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        [self addSubview:_delectBtn];
    }
    return _delectBtn;
}


- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line];
    }
    return _line;
}


- (ESShreParaMeterViewCell *)cellViewWithTitleStr:(NSString *)titleStr valueText:(NSString *)valueText {
    ESShreParaMeterViewCell *cellView = [[ESShreParaMeterViewCell alloc] init];

    self.value = titleStr;
    //"Share to more than one person" = "Share to more than one person, please be careful to follow relevant laws, regulations and judicial interpretations";
    if([titleStr containsString:NSLocalizedString(@"Share to more than one person", @"分享至多人，请注意遵循相关法律法规及司法解释等规定")]){
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleStr];

        if ([ESCommonToolManager isEnglish]) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(titleStr.length - 57, 57)];//字体颜色
 
        }else{
            [attributedString addAttribute:NSForegroundColorAttributeName value:[ESColor primaryColor] range:NSMakeRange(11, 11)];//字体颜色
        }

        cellView.isPointOut = YES;
        cellView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        cellView.titleLabel.textColor = ESColor.secondaryLabelColor;
        cellView.pointOutImageView.hidden = NO;
        cellView.titleLabel.attributedText = attributedString;
        [self addSubview:cellView];
        return cellView;
    }
    cellView.titleLabel.text = titleStr;
    cellView.isPointOut = NO;
    cellView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    cellView.titleLabel.textColor = ESColor.labelColor;
    [self addSubview:cellView];

    return cellView;
}

-(void)delectBtnClick{
    if (self.actionBlock) {
        self.actionBlock(self.value);
        self.hidden = YES;
    }
}

-(void)cellViewTap:(UITapGestureRecognizer *)sender{
    long int tag = sender.view.tag;
 
    if(tag == 20014){
        for (ESShreParaMeterViewCell *cellView in self.cellSelectedArray) {
            if ([cellView.titleLabel.text isEqual:NSLocalizedString(@"10 person", @"10人")]) {
                cellView.titleLabel.hidden = YES;
            }
        }
        if(!self.promptImageView){
            UIImageView *promptImageView = [[UIImageView alloc] init];
            if ([ESCommonToolManager isEnglish]) {
                promptImageView.image = [UIImage imageNamed:@"shuoming_en"];
            }else{
                promptImageView.image = IMAGE_SHARE_PEOPLE_PROMPT;
            }
   
            [self.programView addSubview:promptImageView];
            [self.programView bringSubviewToFront:promptImageView];
            self.promptImageView = promptImageView;
            self.promptImageView.hidden = NO;
            
      
            if ([ESCommonToolManager isEnglish]) {
                [promptImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                     make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-33-kBottomHeight);
                     make.left.mas_equalTo(self).offset(38);
                     make.height.mas_equalTo(98);
                     make.width.mas_equalTo(300);
                 }];
            }else{
                [promptImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                     make.bottom.mas_equalTo(self.programView.mas_bottom).offset(-33-kBottomHeight);
                     make.left.mas_equalTo(self).offset(38);
                     make.height.mas_equalTo(68);
                     make.width.mas_equalTo(300);
                 }];
            }
       
        }else{
            [self.programView bringSubviewToFront:self.promptImageView];
            self.promptImageView.hidden = NO;
        }
        return;
    }
    self.promptImageView.hidden = YES;
    for (ESShreParaMeterViewCell *cellView in self.cellSelectedArray) {
        cellView.titleLabel.hidden = NO;
        if(cellView.tag == tag){
            cellView.titleLabel.textColor = ESColor.primaryColor;
            cellView.iconImageView.hidden = NO;
            self.value = cellView.titleLabel.text;
        }else{
            cellView.titleLabel.textColor = ESColor.labelColor;
            cellView.iconImageView.hidden = YES;
        }
    }
    
    if([self.value isEqual:@"1 人"] || [self.value isEqual:@"1 person"]){
        self.titlePointView.hidden = YES;
    }else{
        self.titlePointView.hidden = NO;
    }
}

-(void)setShareValue:(NSString *)shareValue{
    if([shareValue containsString:NSLocalizedString(@"Day", @"天")]){
    self.tag = 30012;
    [self initUI];
    _shareValue = shareValue;
        for (ESShreParaMeterViewCell *cellView in self.cellSelectedArray) {
            if(cellView.titleLabel.text == shareValue){
                cellView.titleLabel.textColor = ESColor.primaryColor;
                cellView.iconImageView.hidden = NO;
                self.value = cellView.titleLabel.text;
            }else{
                cellView.titleLabel.textColor = ESColor.labelColor;
                cellView.iconImageView.hidden = YES;
            }
        }
    }else if([shareValue containsString:NSLocalizedString(@"person", @"人")]){
        self.tag = 30013;
        [self initUI];
        _shareValue = shareValue;
        for (ESShreParaMeterViewCell *cellView in self.cellSelectedArray) {
            if(cellView.titleLabel.text == shareValue){
                cellView.titleLabel.textColor = ESColor.primaryColor;
                cellView.iconImageView.hidden = NO;
                self.value = cellView.titleLabel.text;
            }else{
                cellView.titleLabel.textColor = ESColor.labelColor;
                cellView.iconImageView.hidden = YES;
            }
        }
    }else{
        self.tag = 30011;
        [self initUI];
        _shareValue = shareValue;
        for (ESShreParaMeterViewCell *cellView in self.cellSelectedArray) {
            if(cellView.titleLabel.text == shareValue){
                cellView.titleLabel.textColor = ESColor.primaryColor;
                cellView.iconImageView.hidden = NO;
                self.value = cellView.titleLabel.text;
            }else{
                cellView.titleLabel.textColor = ESColor.labelColor;
                cellView.iconImageView.hidden = YES;
            }
        }
    }
}


@end




