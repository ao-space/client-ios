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
//  ESShareLinkView.m
//  EulixSpace
//
//  Created by qu on 2022/7/5.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESShareLinkView.h"

#import "ESShareView.h"
#import "UIButton+Extension.h"
#import "ESShareView.h"
#import "ESColor.h"
#import "ESCopyMoveFolderListVC.h"
#import "ESShareParaMeterView.h"
#import "ESFileInfoPub.h"
#import "ESMainBtnView.h"
#import "ESShareApi.h"
#import "ESShareBtnView.h"
#import "ESBoxManager.h"
#import "ESBoxItem.h"


//
//  ESShareView.m
//  EulixSpace
//
//  Created by qu on 2022/6/8.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//


@interface ESShareLinkView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;
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

@end

@implementation ESShareLinkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.programView.hidden = hidden;
}

- (void)initUI {
    [super updateConstraints];
    self.titleLabel.text = NSLocalizedString(@"Send & Share", @"发送与分享");
    [self.programView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(ScreenHeight - 250);
        make.left.equalTo(self.mas_left).offset(0.0f);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(250));
    }];
    
    [self.delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.programView.mas_right).offset(-20.0f);
        make.top.equalTo(self.programView.mas_top).offset(20.0f);
        make.width.equalTo(@(18.0f));
        make.height.equalTo(@(18.0f));
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
        //_titleLabel.text = @"移动到“最近项目…";
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_delectBtn addTarget:self action:@selector(delectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];

        [self addSubview:_delectBtn];
    }
    return _delectBtn;
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
        UITapGestureRecognizer *otherShareBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(otherShareBtnTap)];
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
    if([self.className isEqual:@"shareLink"]){
        [self didClicknShareVXWithShareUrl:self.linkShareUrl name:self.linkName];
        return;
    }
    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];
    req.autoFill = self.switchView.on;
    //if(self.switchView.on){
        req.extractedCode = self.autuCodeStr;
//    }else{
//        req.extractedCode = @"";
//    }
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

-(void)qqlinkCopyBtnTap{
    
    if([self.className isEqual:@"shareLink"]){
        [self didClickQQShareBtn:self.linkShareUrl name:self.linkName];
        return;
    }
    
    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];
    req.autoFill = self.switchView.on;
    if(self.switchView.on){
        req.extractedCode = self.autuCodeStr;
    }else{
        req.extractedCode = @"";
    }
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

- (void)shareFileLinkSelf:(NSString *)linkSrr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[linkSrr] applicationActivities:nil];
    [[self getCurrentVC] presentViewController:vc animated:YES completion:nil];
}

-(void)otherShareBtnTap{
    
    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];
    
    if([self.className isEqual:@"shareLink"]){
        req.extractedCode = self.autuCodeStr;
        req.autoFill = self.switchView.on;
        NSString *str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@\n提取码:%@\n",self.linkName,self.linkShareUrl,self.linkAutuCodeStr];
        [self shareFileLinkSelf:str];
        self.hidden = YES;
        return;
    }else{
        req.autoFill = self.switchView.on;
        if(self.switchView.on){
            req.extractedCode = self.autuCodeStr;
        }else{
            req.extractedCode = @"";
        }
    }
      
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
                NSString *str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@\n提取码:%@\n",output.results.fileName,output.results.shareUrl,self.autoCode.text];
                [self shareFileLinkSelf:str];
                self.hidden = YES;
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
}

-(void)linkCopyBtnTap{
    ESShareApi *api =  [ESShareApi new];
    ESShareLinkReq *req = [ESShareLinkReq new];
    
    if([self.className isEqual:@"shareLink"]){
        req.extractedCode = self.autuCodeStr;
        req.autoFill = self.switchView.on;
        NSString *str;
        if(self.linkAutuCodeStr.length > 0){
            str = [NSString stringWithFormat:@"来自「傲空间」文件 %@等 的分享链接： %@\n提取码:%@",self.linkName,self.linkShareUrl,self.linkAutuCodeStr];
        }else{
            str = [NSString stringWithFormat:@"来自「傲空间」文件 %@等 的分享链接： %@",self.linkName,self.linkShareUrl];
        }
      
        UIPasteboard.generalPasteboard.string = str;
        [ESToast toastInfo:TEXT_ME_WEB_COPY];
        return;
    }else{
        req.autoFill = self.switchView.on;
        if(self.switchView.on){
            req.extractedCode = self.autuCodeStr;
        }else{
            req.extractedCode = @"";
        }
    }
      
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
                NSString *str = [NSString stringWithFormat:@"「%@等」来自傲空间的分享文件。\n链接%@\n提取码:%@\n",output.results.fileName,output.results.shareUrl,self.autoCode.text];
                UIPasteboard.generalPasteboard.string = str;
                [ESToast toastInfo:TEXT_ME_WEB_COPY];
            }else{
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            }
        }];
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
    [self shareLinkView:self didClicCancelBtn:nil];
    self.hidden = YES;
}


- (UIView *)cellViewWithTitleStr:(NSString *)titleStr valueText:(NSString *)valueText {
    UIView *cellView = [[UIView alloc] init];
    if([titleStr isEqual:NSLocalizedString(@"Send this File", @"发送该文件")] || [titleStr isEqual:NSLocalizedString(@"file_to_share_date", @"有效期")] || [titleStr isEqual:NSLocalizedString(@"file_to_share_people_num", @"分享人数")]  ){
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
        title = [[UILabel alloc] initWithFrame:CGRectMake(59, 20, 100, 22)];
        title.text = titleStr;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        value = [[UILabel alloc] initWithFrame:CGRectMake(317, 20, 14, 20)];
        value.text = valueText;
        [cellView addSubview:value];
        value.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        value.textColor = ESColor.primaryColor;
        [value mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellView.mas_top).offset(19.0f);
            make.right.mas_equalTo(cellView.mas_right).offset(-44);
            make.height.mas_equalTo(20);
        }];
    }else if([titleStr isEqual:NSLocalizedString(@"file_to_share_auto_code", @"分享链接自动填充提取码")]){
        title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 180, 22)];
        title.text = titleStr;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        UISwitch *autoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(317, 20, 40, 24)];
        [cellView addSubview:autoSwitch];
        self.switchView = autoSwitch;
    }
    else{
        
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(29, 20, 100, 22)];
        title.text = titleStr;
        [cellView addSubview:title];
        title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        value = [[UILabel alloc] initWithFrame:CGRectMake(317, 20, 14, 20)];
        value.text = valueText;
        [cellView addSubview:value];
        value.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        value.textColor = ESColor.primaryColor;
        [value mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cellView.mas_top).offset(19.0f);
            make.right.mas_equalTo(cellView.mas_right).offset(-44);
            make.height.mas_equalTo(20);
        }];
    }

    self.titleStr = titleStr;
    if([titleStr isEqual:NSLocalizedString(@"Extraction Code", @"提取码")]){
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

    

- (void)shareLinkView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        [self.delegate shareLinkView:self didClicCancelBtn:button];
    }
}

-(void)setFileIds:(NSArray<NSString *> *)fileIds{
    _fileIds = fileIds;
    [self initUI];
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



