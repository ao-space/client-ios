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
//  ESWebShareView.m
//  EulixSpace
//
//  Created by KongBo on 2023/6/14.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESWebShareView.h"
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
#import "UIWindow+ESVisibleVC.h"

@interface ESWebShareView ()

@property (nonatomic, strong) UIView *programView;
@property (nonatomic, strong) UIButton *delectBtn;
@property (nonatomic, strong) UIButton *delectBtnHidden;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ESShareBtnView *weiXinShareBtn;
@property (nonatomic, strong) ESShareBtnView *qqShareBtn;

@property (nonatomic, strong) ESShareBtnView *linkCopyBtn;
@property (nonatomic, strong) ESShareBtnView *otherShareBtn;

@end

@implementation ESWebShareView

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
        [self initUI];
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
    }
}

- (void)initUI {
    [super updateConstraints];
    self.titleLabel.text = @"立即邀请"; //NSLocalizedString(@"Send & Share", @"发送与分享");
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
        UITapGestureRecognizer *otherShareBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(otherShareBtnTap)];
        [_otherShareBtn addGestureRecognizer:otherShareBtnTap];
        [self addSubview:_otherShareBtn];
    }
    return _otherShareBtn;
}

- (void)weiXinShareBtnTap{
    [self shareVXWithShareUrl:self.linkShareUrl title:self.title description:self.descriptionMessage];
}

- (void)qqlinkCopyBtnTap{
    [self shareQQWithLink:self.linkShareUrl title:self.title description:self.descriptionMessage];
}

- (void)otherShareBtnTap{
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        [self.delegate shareView:self didClicCancelBtn:nil];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewShareOther:)]) {
        [self.delegate shareViewShareOther:self];
    }
}

/// 复制连接
- (void)linkCopyBtnTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(linkCopyBtnTap)]) {
        [self.delegate linkCopyBtnTap];
    }
}

- (void)shareVXWithShareUrl:(NSString *)shareUrl title:(NSString *)title description:(NSString *)description {
//    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = title;
//    message.description = description;
//    [message setThumbImage:[UIImage imageNamed:@"app_logo"]];
//
//    // 多媒体消息中包含的网页数据对象
//    WXWebpageObject *webpageObject = [WXWebpageObject object];
//    // 网页的url地址
//    webpageObject.webpageUrl = shareUrl;
//    message.mediaObject = webpageObject;
//
//    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneSession;
//    [WXApi sendReq:req
//        completion:^(BOOL success) {
//            self.hidden = YES;
//    }];
}

- (void)shareQQWithLink:(NSString *)shareUrl title:(NSString *)title description:(NSString *)description {
//   NSData *previewImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"app_logo"],1);
//   QQApiNewsObject *newsObj = [QQApiNewsObject
//                                  objectWithURL:[NSURL URLWithString:shareUrl]
//                                  title:title
//                                  description:description
//                                  previewImageData:previewImageData];
//  SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
//  [QQApiInterface sendReq:req];
}


-(void)delectBtnClick{
    [self shareView:self didClicCancelBtn:nil];
    self.hidden = YES;
}

/// 取消
- (void)shareView:(ESWebShareView *)shareView didClicCancelBtn:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:didClicCancelBtn:)]) {
        [self.delegate shareView:self didClicCancelBtn:button];
    }
}

- (void)shareFileLinkSelf:(NSString *)linkSrr {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[linkSrr] applicationActivities:nil];
    [[UIWindow getCurrentVC] presentViewController:vc animated:YES completion:nil];
}

@end
