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
//  ESShareView.m
//  EulixSpace
//
//  Created by qu on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareView.h"
#import "UIButton+Extension.h"
#import "ESShareView.h"
#import "ESColor.h"
#import "ESCopyMoveFolderListVC.h"
#import "ESShareParaMeterView.h"
#import "ESFileInfoPub.h"
#import "ESMainBtnView.h"
#import "ESShareApi.h"
#import "ESShareAgainReq.h"
#import "ESShareBtnView.h"
#import "ESBoxManager.h"
#import "ESBoxItem.h"
#import "ESCommonToolManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@interface ESShareView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;
 
@property (nonatomic, strong) UIButton *delectBtnHidden;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) ESShareBtnView *weiXinShareBtn;
@property (nonatomic, strong) ESShareBtnView *qqShareBtn;

@property (nonatomic, strong) ESShareBtnView *linkCopyBtn;

@property (nonatomic, strong) ESShareBtnView *otherShareBtn;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, strong) UIView *fileView;

@property (nonatomic, strong) UILabel *dayLabel;

@property (nonatomic, strong) UILabel *switchTitle;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UIView *paraMeterView;

@property (nonatomic, strong) UIView *autoView;

@property (nonatomic, strong) UIView *switchViewUI;

@property (nonatomic, strong) UIView *dataView;

@property (nonatomic, strong) UIView *shareNumView;


@property (nonatomic, strong) UILabel *shareAutoTitle;

@end

@implementation ESShareView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
    if(hidden){
        [self removeFromSuperview];
    }else{
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}

- (void)initUI {
    [super updateConstraints];
    self.titleLabel.text =  NSLocalizedString(@"Send & Share", @"发送与分享"); 
    if([self.className isEqual:@"shareLink"]){
        [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(ScreenHeight - 250);
            make.left.equalTo(self.mas_left).offset(0.0f);
            make.width.equalTo(@(ScreenWidth));
            make.height.equalTo(@(250));
        }];
        [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.programView.mas_right).offset(-20.0f);
            make.top.equalTo(self.programView.mas_top).offset(20.0f);
            make.width.equalTo(@(44.0f));
            make.height.equalTo(@(44.0f));
        }];

        CGFloat btnSpacing = (ScreenWidth - 30 * 2 - 46 * 4) / 3;

        [self.weiXinShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.programView.mas_top).offset(70.0f);
            make.left.mas_equalTo(self).offset(30.0f);
            make.height.mas_equalTo(78.0f);
            make.width.mas_equalTo(46.0f);
        }];

        [self.qqShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.weiXinShareBtn);
            make.left.mas_equalTo(self.weiXinShareBtn.mas_right).offset(btnSpacing);
            make.height.mas_equalTo(78.0f);
            make.width.mas_equalTo(46.0f);
        }];

        [self.linkCopyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.qqShareBtn);
            make.left.mas_equalTo(self.qqShareBtn.mas_right).offset(btnSpacing);
            make.height.mas_equalTo(78);
            make.width.mas_equalTo(46.0f);
        }];

        [self.otherShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.linkCopyBtn);
            make.left.mas_equalTo(self.linkCopyBtn.mas_right).offset(btnSpacing);
            make.height.mas_equalTo(78);
            make.width.mas_equalTo(46.0f);
        }];
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.programView.mas_centerX);
            make.top.equalTo(self.programView.mas_top).offset(20.0f);
            make.right.equalTo(self.delectBtn.mas_left).offset(-10.0f);
            make.height.equalTo(@(25.0f));
        }];
        self.fileView.hidden = YES;
        
        return;
    }
    
    self.fileView.hidden = NO;
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(ScreenHeight - 550);
        make.left.equalTo(self.mas_left).offset(0.0f);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(550));
    }];
    
    [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-20.0f);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.width.equalTo(@(18.0f));
        make.height.equalTo(@(18.0f));
    }];

    [self.delectBtnHidden mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-10.0f);
        make.top.equalTo(self.programView.mas_top).offset(10.0f);
        make.width.equalTo(@(50.0f));
        make.height.equalTo(@(50.0f));
    }];
    
    CGFloat btnSpacing = (ScreenWidth - 30 * 2 - 46 * 4) / 3;

    [self.weiXinShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(70.0f);
        make.left.mas_equalTo(self).offset(30.0f);
        make.height.mas_equalTo(78.0f);
        make.width.mas_equalTo(46.0f);
    }];

    [self.qqShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.weiXinShareBtn);
        make.left.mas_equalTo(self.weiXinShareBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(78.0f);
        make.width.mas_equalTo(46.0f);
    }];

    [self.linkCopyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.qqShareBtn);
        make.left.mas_equalTo(self.qqShareBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(78);
        make.width.mas_equalTo(46.0f);
    }];

    [self.otherShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.linkCopyBtn);
        make.left.mas_equalTo(self.linkCopyBtn.mas_right).offset(btnSpacing);
        make.height.mas_equalTo(78);
        make.width.mas_equalTo(46.0f);
    }];

    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.programView.mas_centerX);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.right.equalTo(self.delectBtn.mas_left).offset(-10.0f);
        make.height.equalTo(@(25.0f));
    }];
    
    [self.line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(194);
        make.left.mas_equalTo(self.programView.mas_left).offset(29.0f);
        make.height.mas_equalTo(1);
        make.right.equalTo(self.delectBtn.mas_left).offset(-29.0f);
    }];
    if(self.fileIds.count == 1){
        self.fileView.hidden = NO;
        if(nil == self.fileView){
            self.fileView =  [self cellViewWithTitleStr:NSLocalizedString(@"Send this File", @"发送该文件") valueText:@""];
            self.fileView.tag = 10010;
            UITapGestureRecognizer *fileViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(otherShareBtnTap)];
            [self.fileView addGestureRecognizer:fileViewTap];

        }

        [self.fileView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.programView.mas_top).offset(194);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(60);
             make.width.mas_equalTo(ScreenWidth);
        }];

        if(nil == self.autoView){
            self.autoView =  [self cellViewWithTitleStr:NSLocalizedString(@"Extraction Code", @"提取码") valueText:NSLocalizedString(@"None", @"无")];
            self.autoView.tag = 10011;
            UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
            [self.autoView addGestureRecognizer:autoViewTap];
        }

        [self.autoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.fileView.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];

        if(nil == self.switchViewUI){
            self.switchViewUI =  [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_auto_code", @"分享链接自动填充提取码") valueText:NSLocalizedString(@"None", @"无")];
            self.switchViewUI.tag = 10014;
            UITapGestureRecognizer *switchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewTap:)];
            [self.switchViewUI addGestureRecognizer:switchViewTap];
        }

        [self.switchViewUI mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.autoView.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];

  
        [self.dataView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.switchViewUI.mas_bottom).offset(0);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(60);
             make.width.mas_equalTo(ScreenWidth);
        }];

        if(nil == self.dataView){
            self.dataView =  [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_date", @"有效期") valueText:NSLocalizedString(@"7 Days", @"7天")];
            self.dataView.tag = 10012;
            UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
            [self.dataView addGestureRecognizer:dateTap];
        }

        [self.dataView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.switchViewUI.mas_bottom).offset(0);
             make.left.mas_equalTo(self).offset(0);
             make.height.mas_equalTo(60);
             make.width.mas_equalTo(ScreenWidth);
        }];
        if(nil == self.shareNumView){
            self.shareNumView =  [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_people_num", @"分享人数") valueText:NSLocalizedString(@"5 person", @"5人")];
            self.shareNumView.tag = 10013;
            UITapGestureRecognizer *shareNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
             [self.shareNumView addGestureRecognizer:shareNumTap];
        }
        [self.shareNumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.dataView.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];
    }else{
        self.fileView.hidden = YES;
        if(nil == self.autoView){
            self.autoView =  [self cellViewWithTitleStr:NSLocalizedString(@"Extraction Code", @"提取码") valueText:NSLocalizedString(@"None", @"无")];
            self.autoView.tag = 10011;
            UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
            [self.autoView addGestureRecognizer:autoViewTap];
        }
        
        [self.autoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.programView.mas_top).offset(194);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];
        if(nil == self.switchViewUI){
            self.switchViewUI = [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_auto_code", @"分享链接自动填充提取码") valueText:NSLocalizedString(@"None", @"无")];
            self.switchViewUI.tag = 10014;
            UITapGestureRecognizer *switchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewTap:)];
            [self.switchViewUI addGestureRecognizer:switchViewTap];
        }
        [self.switchViewUI mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.autoView.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];
        
        if(nil == self.dataView){
            self.dataView =  [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_date", @"有效期") valueText:NSLocalizedString(@"7 Days", @"7天")];
            self.dataView.tag = 10012;
            UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
            [self.dataView  addGestureRecognizer:dateTap];
        }
        
        [self.dataView  mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.switchViewUI.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];
        
        if(nil == self.shareNumView){
            self.shareNumView = [self cellViewWithTitleStr:NSLocalizedString(@"file_to_share_people_num", @"分享人数") valueText:NSLocalizedString(@"5 person", @"5人")];
            self.shareNumView.tag = 10013;
            UITapGestureRecognizer *shareNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTap:)];
            [self.shareNumView addGestureRecognizer:shareNumTap];
        }
        [self.shareNumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.dataView.mas_bottom).offset(0);
            make.left.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(ScreenWidth);
        }];
        //}
        // self.autuCodeStr = [self randomCaptcha];
        //  self.autoCode.text = self.autuCodeStr;
        [self layoutIfNeeded];
    }
}


- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 900, ScreenWidth, 900)];
        _programView.backgroundColor = ESColor.systemBackgroundColor;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_programView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _programView.bounds;
        maskLayer.path = maskPath.CGPath;
        _programView.layer.mask = maskLayer;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(programViewBackViewTag)];
        [_programView addGestureRecognizer:tap];
        [self addSubview:_programView];
    }
    return _programView;
}

-(void)programViewBackViewTag{
    //self.hidden = YES;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        //_titleLabel.text = @"移动到“最近项目…";
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(delectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];

        [self addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UIButton *)delectBtnHidden  {
    if (nil == _delectBtnHidden) {
        _delectBtnHidden = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtnHidden addTarget:self action:@selector(delectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_delectBtnHidden];
    }
    return _delectBtnHidden;
}

- (ESShareBtnView *)weiXinShareBtn {
    if (nil == _weiXinShareBtn) {
        _weiXinShareBtn = [ESShareBtnView new];
        _weiXinShareBtn.btnLabel.text = TEXT_FILE_SHARE_WEIXIN;
        _weiXinShareBtn.btnImageView.image = IMAGE_SHARE_WEIXIN;
        UITapGestureRecognizer *autoViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weiXinShareBtnTap)];
        [_weiXinShareBtn addGestureRecognizer:autoViewTap];
        [self addSubview:_weiXinShareBtn];
    }
    return _weiXinShareBtn;
}

- (ESMainBtnView *)qqShareBtn {
    if (nil == _qqShareBtn) {
        _qqShareBtn = [ESShareBtnView new];
        _qqShareBtn.btnLabel.text = TEXT_FILE_SHARE_QQ;
        _qqShareBtn.btnImageView.image = IMAGE_SHARE_QQ;
        [self addSubview:_qqShareBtn];
        UITapGestureRecognizer *qqBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qqlinkCopyBtnTap)];
        [_qqShareBtn addGestureRecognizer:qqBtnTap];
    }
    return _qqShareBtn;
}

- (ESMainBtnView *)linkCopyBtn {
    if (nil == _linkCopyBtn) {
        _linkCopyBtn = [ESShareBtnView new];
        _linkCopyBtn.btnLabel.text = TEXT_FILE_SHARE_COPYLINK;
        _linkCopyBtn.btnImageView.image = IMAGE_SHARE_LINK;
        [self addSubview:_linkCopyBtn];
 
        UITapGestureRecognizer *linkCopyBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkCopyBtnTap)];
        [_linkCopyBtn addGestureRecognizer:linkCopyBtnTap];
        [self addSubview:_linkCopyBtn];
    }
    return _linkCopyBtn;
}


- (ESMainBtnView *)otherShareBtn {
    if (nil == _otherShareBtn) {
        _otherShareBtn = [ESShareBtnView new];
        _otherShareBtn.btnLabel.text = TEXT_FILE_SHARE_OTHER;
        _otherShareBtn.btnImageView.image = IMAGE_SHARE_OTHER;
        [self addSubview:_otherShareBtn];
        UITapGestureRecognizer *otherShareBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(otherShareLinkBtnTap)];
        [_otherShareBtn addGestureRecognizer:otherShareBtnTap];
        [self addSubview:_otherShareBtn];
    }
    return _otherShareBtn;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line];
    }
    return _line;
}

-(void)weiXinShareBtnTap{
    
    if([self.className isEqual:@"shareLink"]){
        [self didClicknShareVXWithShareUrl:self.linkShareUrl name:self.linkName];
        return;
    }
    if([self.className isEqual:@"onceShare"]){
        ESShareApi *api =  [ESShareApi new];
        ESShareAgainReq *req = [ESShareAgainReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.shareId = self.shareId;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        
        [api spaceV1ApiShareAgainPostWithShareAgainReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if (!error) {
                [self didClicknShareVXWithShareUrl:output.results.shareUrl name:output.results.fileName];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
     
    }else{
        ESShareApi *api =  [ESShareApi new];
        ESShareLinkReq *req = [ESShareLinkReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.fileIds = self.fileIds;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        
        [api spaceV1ApiShareLinkPostWithShareLinkReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if (!error) {
                [self didClicknShareVXWithShareUrl:output.results.shareUrl name:output.results.fileName];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}

-(void)qqlinkCopyBtnTap{
    
    if([self.className isEqual:@"shareLink"]){
        [self didClickQQShareBtn:self.linkShareUrl name:self.linkName];
        return;
    }
    if([self.className isEqual:@"onceShare"]){
        ESShareApi *api =  [ESShareApi new];
        ESShareAgainReq *req = [ESShareAgainReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.shareId = self.shareId;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        [api spaceV1ApiShareAgainPostWithShareAgainReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if (!error) {
                [self didClickQQShareBtn:output.results.shareUrl name:output.results.fileName];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }else{
        ESShareApi *api =  [ESShareApi new];
        ESShareLinkReq *req = [ESShareLinkReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.fileIds = self.fileIds;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        
        [api spaceV1ApiShareLinkPostWithShareLinkReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if (!error) {
                [self didClickQQShareBtn:output.results.shareUrl name:output.results.fileName];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}


-(void)otherShareBtnTap{

    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        [self.delegate shareView:self didClicCancelBtn:nil];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewShareOther:)]) {
        [self.delegate shareViewShareOther:self];
    }
    if([self.className isEqual:@"onceShare"]){
        [ESToast toastSuccess:@"请到文件列表使用此功能"];
    }
}


-(void)otherShareLinkBtnTap{

    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];

    if([self.className isEqual:@"shareLink"]){
        req.extractedCode = self.autoCode.text;
        req.autoFill = self.switchView.on;
        NSString *str;


        NSString *fileName = [self cutOutSizeStr:self.linkName];
        if(self.linkAutuCodeStr.length > 0){
            str = [NSString stringWithFormat:NSLocalizedString(@"share files from AO.space more", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@"),fileName,self.linkShareUrl,self.linkAutuCodeStr];
        }else{
            str = [NSString stringWithFormat:NSLocalizedString(@"hare files from AO.space more no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,self.linkShareUrl];
        }

        UIPasteboard.generalPasteboard.string = str;
        [ESToast toastInfo:TEXT_ME_WEB_COPY];
        return;
    }else{
        req.autoFill = self.switchView.on;
    }
    req.extractedCode = self.autoCode.text;
    if ([self.className isEqual:@"onceShare"]) {
        ESShareApi *api =  [ESShareApi new];
        ESShareAgainReq *req = [ESShareAgainReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.shareId = self.shareId;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        [api spaceV1ApiShareAgainPostWithShareAgainReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if(!error){
                NSLog(@"%@",output);
                NSString *fileName = [self cutOutSizeStr:output.results.fileName];
                NSString *str;

                if(output.results.extractedCode.length > 0){
                    if([output.results.fileCount intValue] > 1){
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code more", @"来自「傲空间」文件 %@等 的分享链接： %@ 提取码：%@") ,fileName,fileName,output.results.shareUrl,output.results.extractedCode];
                        UIPasteboard.generalPasteboard.string = str;
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@"),fileName,output.results.shareUrl,output.results.extractedCode];
                        UIPasteboard.generalPasteboard.string = str;
                    }
                }else{
                    if ([output.results.fileCount intValue] > 1) {
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code more", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }

                    UIPasteboard.generalPasteboard.string = str;
                }
                UIPasteboard.generalPasteboard.string = str;
                [self shareFileLinkSelf:str];
                self.hidden = YES;
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }else{
        req.extractedCode = self.autoCode.text;
        req.fileIds = self.fileIds;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        [api spaceV1ApiShareLinkPostWithShareLinkReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if(!error){
                NSLog(@"%@",output);
                NSString *str;
                NSString *fileName = [self cutOutSizeStr:output.results.fileName];
                if(self.autoCode.text.length > 0){
                    if(self.fileIds.count > 1){
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code more", @"来自「傲空间」文件 %@等 的分享链接： %@ 提取码：%@") ,fileName,output.results.shareUrl,self.autoCode.text];
                        UIPasteboard.generalPasteboard.string = str;
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@"),fileName,output.results.shareUrl,self.autoCode.text];
                        UIPasteboard.generalPasteboard.string = str;
                    }
                }else{
                    
                    if (self.fileIds.count > 1) {
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code more", @"来自「傲空间」文件 %@等 的分享链接： %@"),fileName,output.results.shareUrl];
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }
                  
                   // str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@",output.results.fileName,output.results.shareUrl];
                    UIPasteboard.generalPasteboard.string = str;
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(otherShareLinkBtnTap:)]) {
                    [self.delegate otherShareLinkBtnTap:str];
                }
                self.hidden = YES;
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
}

/// 复制连接
-(void)linkCopyBtnTap{
    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];
       // 来自「傲空间」文件 IMG_001.JPG 的分享链接： https://user.space.xxx/a/b............pwd=xYZ2 提取码：xYZ2
    NSArray *linkNameArray = [self.linkName componentsSeparatedByString:@"."];
    NSString *fileName;
    NSString *fileType;
    if(linkNameArray.count > 1){
        fileName = linkNameArray[0];
        fileType= linkNameArray[1];
    }
    if(fileName.length > 15){
        fileName = [fileName substringToIndex:15];
        fileName = [NSString stringWithFormat:@"%@...",fileName];
    }

    if([self.className isEqual:@"shareLink"]){
        req.extractedCode = self.autoCode.text;
        req.autoFill = self.switchView.on;
        NSString *str;
        if(self.linkAutuCodeStr.length > 0){
            str = [NSString stringWithFormat:NSLocalizedString(@"share files from AO.space more", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@"),fileName,self.linkShareUrl,self.linkAutuCodeStr];
        }else{
            str = [NSString stringWithFormat:NSLocalizedString(@"hare files from AO.space more no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,self.linkShareUrl];
        }
        UIPasteboard.generalPasteboard.string = str;
        [ESToast toastInfo:TEXT_ME_WEB_COPY];
        return;
    }else{
        req.autoFill = self.switchView.on;
    }
    req.extractedCode = self.autoCode.text;
    if ([self.className isEqual:@"onceShare"]) {
        ESShareApi *api =  [ESShareApi new];
        ESShareAgainReq *req = [ESShareAgainReq new];
        req.autoFill = self.switchView.on;
        req.extractedCode = self.autoCode.text;
        req.shareId = self.shareId;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        [api spaceV1ApiShareAgainPostWithShareAgainReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if(!error){
                NSString *fileName = [self cutOutSizeStr:output.results.fileName];
                NSString *str;
                if(output.results.extractedCode.length > 0){
                    if([output.results.fileCount intValue] > 1){
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code more", @"来自「傲空间」文件 %@等 的分享链接： %@ 提取码：%@") ,fileName,fileName,output.results.shareUrl,output.results.extractedCode];
                        UIPasteboard.generalPasteboard.string = str;
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@"),fileName,output.results.shareUrl,output.results.extractedCode];
                        UIPasteboard.generalPasteboard.string = str;
                    }
                }else{
                    if ([output.results.fileCount intValue] > 1) {
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code more", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }

                    UIPasteboard.generalPasteboard.string = str;
                }
            
                //NSString *str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@\n提取码:%@\n",output.results.fileName,output.results.shareUrl,self.autoCode.text];
                UIPasteboard.generalPasteboard.string = str;
                [ESToast toastInfo:TEXT_ME_WEB_COPY];
                self.hidden = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
                    UIButton *btn = [UIButton new];
                    [self.delegate shareView:self didClicCancelBtn:btn];
                }
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }else{
        req.extractedCode = self.autoCode.text;
        req.fileIds = self.fileIds;
        NSArray *personCodeArray = [self.pNum.text componentsSeparatedByString:NSLocalizedString(@"person", @"人")];
        NSString *pNumStr = personCodeArray[0];
        NSNumber *sharePersonNum = @([pNumStr longLongValue]);
        req.sharePerson = @([sharePersonNum longLongValue]);
        NSArray *inviteCodeArray = [self.dayLabel.text componentsSeparatedByString:NSLocalizedString(@"Day", @"天")];
        NSString *day = inviteCodeArray[0];
        req.validDay = @([day longLongValue]);
        [api spaceV1ApiShareLinkPostWithShareLinkReq:req completionHandler:^(ESRspShareLinkRsp *output, NSError *error) {
            if(!error){
                NSString *str;
                NSString *fileName = [self cutOutSizeStr:output.results.fileName];
                if(self.autoCode.text.length > 0 ){
                    if (self.fileIds.count > 1) {
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code more", @"来自「傲空间」文件 %@等 的分享链接： %@ 提取码：%@"),fileName,output.results.shareUrl,self.autoCode.text];
                    }else{
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from have code", @"来自「傲空间」文件 %@ 的分享链接： %@ 提取码：%@") ,fileName,output.results.shareUrl,self.autoCode.text];
                    }
            
                  //  str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@\n提取码:%@\n",output.results.fileName,output.results.shareUrl,self.autoCode.text];
                    UIPasteboard.generalPasteboard.string = str;
                }else{
                    if (self.fileIds.count > 1) {
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code more", @"来自「傲空间」文件 %@等 的分享链接： %@"),fileName,output.results.shareUrl];
                    }else{
                       
                        str = [NSString stringWithFormat:NSLocalizedString(@"Shared links from no code", @"来自「傲空间」文件 %@ 的分享链接： %@"),fileName,output.results.shareUrl];
                    }
            
                   // str = [NSString stringWithFormat:@"来自「傲空间」文件 %@ 的分享链接： %@",output.results.fileName,output.results.shareUrl];
                   // str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@",output.results.fileName,output.results.shareUrl];
                    UIPasteboard.generalPasteboard.string = str;
                }
                [ESToast toastInfo:TEXT_ME_WEB_COPY];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
    }
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        UIButton *btn = [UIButton new];
        [self.delegate shareView:self didClicCancelBtn:btn];
    }
}

-(NSString *)cutOutSizeStr:(NSString *)str{
    if(str.length > 15){
        NSArray *linkNameArray = [str componentsSeparatedByString:@"."];
        NSString *fileName;
        if(linkNameArray.count > 1){
            fileName = linkNameArray[0];
            if(fileName.length > 15){
                fileName = [fileName substringToIndex:15];
            }
            str = [NSString stringWithFormat:@"%@...",fileName];
        }
    }
    return str;
}

- (void)didClicknShareVXWithShareUrl:(NSString *)shareUrl name:(NSString *)name {
    
}

-(void)didClickQQShareBtn:(NSString *)shareUrl name:(NSString *)name {


}

-(void)didClicklinkCopyBtn{
 
    [ESToast toastInfo: NSLocalizedString(@"Copy Link to Clipboard", @"复制链接到剪贴板")];
    self.hidden = YES;
}

-(void)delectBtnClick{
    [self shareView:self didClicCancelBtn:nil];
    self.hidden = YES;
}


- (UIView *)cellViewWithTitleStr:(NSString *)titleStr valueText:(NSString *)valueText {
    UIView *cellView = [[UIView alloc] init];
    if([titleStr isEqual:NSLocalizedString(@"Send this File", @"发送该文件")] || [titleStr isEqual:NSLocalizedString(@"file_to_share_date", @"有效期")] || [titleStr isEqual:NSLocalizedString(@"file_to_share_people_num", @"分享人数")] || [titleStr isEqual:NSLocalizedString(@"Extraction Code", @"提取码")]){
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20 -24, 22, 16, 16)];
        headImageView.image = IMAGE_SHARE_BACK;
        [cellView addSubview:headImageView];
    }
    UILabel *title;
    UILabel *value;
    
    if([titleStr isEqual:NSLocalizedString(@"Send this File", @"发送该文件")]){
        UIImageView *fileIconView = [[UIImageView alloc] initWithFrame:CGRectMake(29, 19, 20, 20)];
        fileIconView.image = IMAGE_SHARE_FILE_ICON;
        [cellView addSubview:fileIconView];
        if ([ESCommonToolManager isEnglish]) {
            title = [[UILabel alloc] initWithFrame:CGRectMake(59, 20, 150, 22)];
        }else {
            title = [[UILabel alloc] initWithFrame:CGRectMake(59, 20, 100, 22)];
        }

        title.text = titleStr;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];;
        value = [[UILabel alloc] initWithFrame:CGRectMake(317, 20, 14, 20)];
        value.text = valueText;
        [cellView addSubview:value];
        value.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        value.textColor = ESColor.primaryColor;
        [value mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellView.mas_top).offset(19.0f);
            make.right.mas_equalTo(cellView.mas_right).offset(-44);
            make.height.mas_equalTo(20);
        }];
    }else if([titleStr isEqual:NSLocalizedString(@"file_to_share_auto_code", @"分享链接自动填充提取码")]){
        if ([ESCommonToolManager isEnglish]) {
            title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 280, 22)];
        }else {
            title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 180, 22)];
        }
     
        
        title.text = titleStr;
        title.textColor = ESColor.grayColor;
        self.shareAutoTitle = title;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        UISwitch *autoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(317, 20, 40, 24)];
        [cellView addSubview:autoSwitch];
        autoSwitch.enabled = NO;
        self.switchView = autoSwitch;
        [self.switchView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellView.mas_top).offset(19.0f);
            make.right.mas_equalTo(cellView.mas_right).offset(-20);
            make.height.mas_equalTo(20);
        }];
        [autoSwitch addTarget:self action:@selector(switchViewTap:)
         forControlEvents:UIControlEventValueChanged];
    }
    else{
        
        if ([ESCommonToolManager isEnglish]) {
            title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 240, 22)];
        }else{
            title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 100, 22)];
        }
    
        title.text = titleStr;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];;
        value = [[UILabel alloc] initWithFrame:CGRectMake(317, 20, 14, 20)];
        value.text = valueText;
        [cellView addSubview:value];
        value.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        value.textColor = ESColor.primaryColor;
        [value mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellView.mas_top).offset(19.0f);
            make.right.mas_equalTo(cellView.mas_right).offset(-44);
            make.height.mas_equalTo(20);
        }];
    }

    self.titleStr = titleStr;
    if([titleStr isEqual:NSLocalizedString(@"Extraction Code", @"提取码")]){
        value.text = @"";
        self.autoCode = value;
    }
    
    if([titleStr isEqual:NSLocalizedString(@"file_to_share_date", @"有效期")]){
        self.dayLabel = value;
    }
    
    if([titleStr isEqual:NSLocalizedString(@"file_to_share_people_num", @"分享人数")]){
        self.pNum = value;
    }
 
    [self addSubview:cellView];
    return cellView;
}

-(void)switchViewTap:(UITapGestureRecognizer *)sender{
    
}
-(void)cellViewTap:(UITapGestureRecognizer *)sender{
    long int tag = sender.view.tag;
    [[[UIApplication sharedApplication].keyWindow viewWithTag:30012] removeFromSuperview];
    [[[UIApplication sharedApplication].keyWindow viewWithTag:30013] removeFromSuperview];
    [[[UIApplication sharedApplication].keyWindow viewWithTag:30011] removeFromSuperview];
//
    ESShareParaMeterView *paraMeterView  = [[ESShareParaMeterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.paraMeterView = paraMeterView;
    if(tag == 10012){
        paraMeterView.tag = 30012;
        paraMeterView.shareValue = self.dayLabel.text;
    }else if(tag == 10013){
        paraMeterView.tag = 30013;
        paraMeterView.shareValue = self.pNum.text;
  
    }else  if(tag == 10011){
        paraMeterView.tag = 30011;
        if(self.autoCode.text.length > 1){
            paraMeterView.shareValue = NSLocalizedString(@"Auto Generation", @"自动生成");
        }else{
            paraMeterView.shareValue = NSLocalizedString(@"None", @"无");
        }
    }
    
    paraMeterView.actionBlock = ^(NSString *value) {
        if([value containsString:NSLocalizedString(@"Day", @"天")]){
            self.dayLabel.text = value;
        }
        else if([value containsString:NSLocalizedString(@"person", @"人")]){
            self.pNum.text = value;
        }else {
            if([value isEqual:NSLocalizedString(@"None", @"无")]){
                self.switchView.on = NO;
                self.switchView.enabled = NO;
                self.autoCode.text = @"";
                self.shareAutoTitle.textColor = ESColor.grayColor;
            }else{
                self.switchView.enabled = YES;
                self.autuCodeStr = [self randomCaptcha];
                self.autoCode.text = self.autuCodeStr;
                self.shareAutoTitle.textColor = ESColor.labelColor;
         
            }
        }
    };
    paraMeterView.tag = tag;
    if(self.paraMeterView){
        [self addSubview:paraMeterView];
    }
}
    
/// 取消
- (void)shareView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        [self.delegate shareView:self didClicCancelBtn:button];
    }
}

-(void)setFileIds:(NSArray<NSString *> *)fileIds{
    _fileIds = fileIds;
    [self initUI];
}


- (NSString *)randomCaptcha {
    //数组中存放的是全部可选的字符，可以是字母，也可以是中文
    NSArray *characterArray = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:4];
    NSMutableString *captchaString = [[NSMutableString alloc] initWithCapacity:4]; //随机从数组中选取需要个数的字符，然后拼接为一个字符串
    for (int i = 0 ; i < 4; i ++) {
        int index = arc4random() % 61;
        getStr = [characterArray objectAtIndex:index];
        captchaString = [[captchaString stringByAppendingString:getStr] copy];
    }
    return captchaString;
}

-(void)setAutuCodeStr:(NSString *)autuCodeStr{
    _autuCodeStr = autuCodeStr;
    if (autuCodeStr.length > 0 || self.autoCode.text ) {
        self.switchView.enabled = YES;
    }
}


- (void)shareFileLinkSelf:(NSString *)linkSrr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[linkSrr] applicationActivities:nil];
    [[self getCurrentVC] presentViewController:vc animated:YES completion:nil];
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
 ///下文中有分析
 UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
 UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
 return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }

    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
 
    return currentVC;
}
@end


