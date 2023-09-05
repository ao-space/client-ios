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
//  ESAppInstallPageVC.m
//  EulixSpace
//
//  Created by qu on 2022/11/17.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppInstallPageVC.h"
#import <SDWebImage/SDWebImage.h>
#import "ESGradientButton.h"
#import "ESAppletViewController.h"
#import "ESAppletInfoModel.h"
#import "ESAppletManager.h"
#import "ESSmarPhotoCacheManager.h"
#import "ESNetworkRequestManager.h"
#import "ESToast.h"
#import "ESAppletManager.h"
#import "ESAppletManager+ESCache.h"
#import "NSString+LeeLabelAddtion.h"
#import "ESFileDefine.h"
#import "NSError+ESTool.h"
#import "ESAgreementWebVC.h"
#import "ESAppWelcome.h"
#import "ESCommonToolManager.h"
#import "ESCache.h"


#define FONT(__SIZE)       [UIFont fontWithName:YRY_FONT_TEXT_Regular size: __SIZE]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
//大标题标题黑色
#define     Color_label_DataTitle        RGBA(52, 52, 52, 1)
//平方字体
#define     YRY_FONT_TEXT_Regular       @"PingFangSC-Regular"

@interface ESAppInstallPageVC ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *name;

@property (nonatomic, strong) UILabel *desc;

@property (nonatomic, strong) UIView *frameView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UILabel *pageTitle;

@property (nonatomic, strong) UILabel *pageText;

@property (nonatomic, strong) UILabel *installNum;

@property (nonatomic, strong) UILabel *installNumText;

@property (nonatomic, strong) UILabel *sizeLabel;

@property (nonatomic, strong) UILabel *sizeLabelText;

@property (nonatomic, strong) UILabel *lastUpdated;

@property (nonatomic, strong) UILabel *lastUpdatedText;

@property (nonatomic, strong) UILabel *introduce;

@property (nonatomic, strong) UILabel *introduceText;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *appTitle;

@property (nonatomic, strong) UIView *navView;

@property (nonatomic, strong) ESGradientButton *openBtn;

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIView *line1;

@property (nonatomic, strong) UIView *line2;

@property (nonatomic, strong) UIView *line3;

@property (nonatomic, strong) UIView *line4;

@property (nonatomic, strong) UIView *line5;

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) dispatch_source_t timer;

@property (strong, nonatomic) NSMutableArray *dataResponse;

@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) NSMutableDictionary *installDic;

@end

@implementation ESAppInstallPageVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getManagementServiceApi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    self.navigationBarBackgroundColor = ESColor.systemBackgroundColor;
    [self initUI];
    self.title = self.appStoreModel.name;

}

- (void)initUI {
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.height.mas_equalTo(ScreenHeight);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.scrollView setUserInteractionEnabled:YES];
    [self.frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(86.0f);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(26.0);
        make.height.mas_equalTo(70.0f);
        make.width.mas_equalTo(70.0f);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.frameView.center);
        make.height.mas_equalTo(50.0f);
        make.width.mas_equalTo(50.0f);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(95.0f);
        make.left.mas_equalTo(self.frameView.mas_right).offset(20.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-20.0);
        make.height.mas_equalTo(26.0f);
    }];
    
    [self.desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(128.0f);
        make.left.mas_equalTo(self.frameView.mas_right).offset(20.0);
        make.right.mas_equalTo(self.view.mas_right).offset(-20.0);
        make.height.mas_equalTo(18.0f);
    }];
    
    [self.installNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(186.0f);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(52.0);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.installNumText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.installNum.mas_bottom).offset(6.0f);
        make.centerX.mas_equalTo(self.installNum.mas_centerX);
        make.height.mas_equalTo(18.0f);
    }];
    
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView.mas_left).offset(ScreenWidth/3-1);
        make.width.mas_equalTo(1.0f);
        make.top.mas_equalTo(self.scrollView.mas_top).offset(186.0f);
        make.height.mas_equalTo(40.5f);
    }];
    
    [self.pageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(186.0f);
        make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.pageText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageTitle.mas_bottom).offset(6.0f);
        make.centerX.mas_equalTo(self.pageTitle.mas_centerX);
        make.height.mas_equalTo(18.0f);
    }];
    int space = ScreenWidth/3;
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView.mas_left).offset(space*2-1);
        make.width.mas_equalTo(1.0f);
        make.top.mas_equalTo(self.scrollView.mas_top).offset(186.0f);
        make.height.mas_equalTo(40.5f);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(186.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-47.0);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.sizeLabelText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pageTitle.mas_bottom).offset(6.0f);
        make.centerX.mas_equalTo(self.sizeLabel.mas_centerX);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0f);
        make.top.mas_equalTo(self.sizeLabelText.mas_bottom).offset(29.0f);
        make.height.mas_equalTo(1.0f);
    }];
    
    [self.openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
    }];
    
    [self.lastUpdated mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.top.mas_equalTo(self.line4.mas_bottom).offset(19.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    
    [self.lastUpdatedText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0f);
        make.top.mas_equalTo(self.lastUpdated.mas_bottom).offset(13.0f);
    }];
    
    [self.line5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0f);
        make.top.mas_equalTo(self.lastUpdatedText.mas_bottom).offset(19.0f);
        make.height.mas_equalTo(1.0f);
    }];
    
    self.introduce.text = NSLocalizedString(@"appstore_app_introduction", @"应用介绍");
    [self.introduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.top.mas_equalTo(self.line5.mas_bottom).offset(19.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    
    [self.introduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.top.mas_equalTo(self.line5.mas_bottom).offset(19.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.introduceText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(26.0f);
        make.top.mas_equalTo(self.introduce.mas_bottom).offset(13.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0f);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(60.0f);
        make.right.mas_equalTo(self.view.mas_right).offset(-26.0f);
        make.bottom.mas_equalTo(self.lastUpdatedText.mas_bottom);
    }];
    
    self.hideNavigationBar = YES;
    self.appTitle.text = self.appStoreModel.name;
    [self.view bringSubviewToFront:self.appTitle];
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(100.0f);
        make.width.mas_equalTo(ScreenWidth);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0f);
        make.top.mas_equalTo(self.view.mas_top).offset(0);
    }];
    
    [self.appTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20.0f);
        make.left.mas_equalTo(self.navView.mas_left).offset(64.0f);
        make.top.mas_equalTo(self.navView.mas_top).offset(45 + 20);
    }];

    if(self.appStoreModel.downloadCount > 99 && self.appStoreModel.downloadCount < 1000){
        self.installNum.text = [NSString stringWithFormat:@"%ld百+",self.appStoreModel.downloadCount/100];
    }else if(self.appStoreModel.downloadCount > 999 && self.appStoreModel.downloadCount < 10000){
        self.installNum.text = [NSString stringWithFormat:@"%ld千+",self.appStoreModel.downloadCount/1000];
    }else if(self.appStoreModel.downloadCount > 9999 && self.appStoreModel.downloadCount < 99999999){
        self.installNum.text = [NSString stringWithFormat:@"%ld万+",self.appStoreModel.downloadCount/10000];
    }else if(self.appStoreModel.downloadCount > 99999999){
        self.installNum.text = [NSString stringWithFormat:@"%ld亿+",self.appStoreModel.downloadCount/100000000];
    }else{
        self.installNum.text = [NSString stringWithFormat:@"%ld",(long)self.appStoreModel.downloadCount];
    }

    self.pageTitle.text = self.appStoreModel.provider;
    if(self.appStoreModel.shortDesc.length > 0){
        self.introduceText.text = self.appStoreModel.bundle;
    }else{
        self.introduceText.text = NSLocalizedString(@"appstore_detail_no_content", @"暂无内容。");
    }
    if(self.appStoreModel.details.length > 0){
        self.lastUpdatedText.text = self.appStoreModel.details;
        self.lastUpdatedText.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        self.lastUpdatedText.numberOfLines = 6;
        CGFloat height = [self.lastUpdatedText.text heightWithStrAttri:@{NSFontAttributeName:FONT(14), NSForegroundColorAttributeName: Color_label_DataTitle,NSParagraphStyleAttributeName:[self paragraphStyle]} withLabelWidth:ScreenWidth-2*26];
        if (height < 150) {
            self.moreBtn.hidden = YES;
        }else{
            self.moreBtn.hidden = NO;
        }
    }else{
        self.lastUpdatedText.text = NSLocalizedString(@"appstore_detail_no_content", @"暂无内容。");
        self.moreBtn.hidden = YES;
    }
    
    if(self.appStoreModel.stateCode == ESUNINSTALL){
        [_openBtn setTitle:NSLocalizedString(@"appstore_state_install", @"安装") forState:UIControlStateNormal];
    }else if(self.appStoreModel.stateCode == ESINSTALLED){
        if([self.appStoreModel.curVersion isEqual:self.appStoreModel.version]){
            [_openBtn setTitle:NSLocalizedString(@"Open", @"打开") forState:UIControlStateNormal];
        }else{
            [_openBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
        }
    }else if(self.appStoreModel.stateCode == ESINSTALLING){
        [_openBtn startLoading:NSLocalizedString(@"appstore_state_installing", @"安装中…")];
        [self creatTimer];
    }else if(self.appStoreModel.stateCode == ESUPDATING){
        [_openBtn startLoading:NSLocalizedString(@"Updating", @"更新中...")];
        [self creatTimer];
    }else if(self.appStoreModel.stateCode == ESINSTALLFAIL){
        [_openBtn setTitle:NSLocalizedString(@"Install", @"安装") forState:UIControlStateNormal];
    }else if(self.appStoreModel.stateCode == ESUPDATEFAIL){
        [_openBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
    }else if(self.appStoreModel.stateCode == ESUPGRADE){
        [_openBtn setTitle:NSLocalizedString(@"me_upgrade", @"更新") forState:UIControlStateNormal];
    }
    
    NSURL *imageurl = [NSURL URLWithString:self.appStoreModel.iconUrl];
    NSData *imagedata = [NSData dataWithContentsOfURL:imageurl];
    self.headImageView.image = [UIImage imageWithData:imagedata];
    self.sizeLabel.text = [self convertFileSize:self.appStoreModel.appSize];
  //  self.sizeLabel.text = [NSString stringWithFormat:@"%@",FileSizeString(self.appStoreModel.appSize, YES)];
    self.name.text = self.appStoreModel.name;
    self.appTitle.text = self.appStoreModel.name;
    //self.desc.text = self.appStoreModel.bundle;
    self.desc.text = self.appStoreModel.shortDesc;
    if(self.btnStr.length > 0){
        if([self.btnStr isEqual:NSLocalizedString(@"appstore_state_installing", @"安装中…")])
            [_openBtn startLoading:NSLocalizedString(@"appstore_state_installing", @"安装中…")];
        [self creatTimer];
    }else if([self.btnStr isEqual:NSLocalizedString(@"appstore_state_updating", @"更新中…")]){
        [_openBtn startLoading:NSLocalizedString(@"appstore_state_updating", @"更新中…")];
        [self creatTimer];
    }
    
    [self.scrollView layoutIfNeeded];
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = CGSizeMake(ScreenWidth, self.introduceText.frame.size.height + self.introduceText.frame.origin.y +200);
    });
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.scrollView addSubview:_titleLabel];
    }
    return _titleLabel;
}


- (UIView *)pageTitle {
    if (!_pageTitle) {
        _pageTitle = [[UILabel alloc] init];
        _pageTitle.textColor = ESColor.labelColor;
        _pageTitle.textAlignment = NSTextAlignmentCenter;
        _pageTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.scrollView addSubview:_pageTitle];
    }
    return _pageTitle;
}

- (UIView *)frameView {
    if (!_frameView) {
        _frameView = [[UIView alloc] init];
        _frameView.layer.cornerRadius = 6;
        _frameView.layer.masksToBounds = YES;
        _frameView.backgroundColor = ESColor.iconBg;
        [self.scrollView addSubview:_frameView];
    }
    return _frameView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        //self.tableView.tableHeaderView = _scrollView;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}


- (UILabel *)pageText {
    if (!_pageText) {
        _pageText = [[UILabel alloc] init];
        _pageText.textColor = ESColor.secondaryLabelColor;
        _pageText.textAlignment = NSTextAlignmentLeft;
        _pageText.text = NSLocalizedString(@"app_developer", @"开发者");
        _pageText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.scrollView addSubview:_pageText];
    }
    return _pageText;
}

- (UILabel *)installNum {
    if (!_installNum) {
        _installNum = [[UILabel alloc] init];
        _installNum.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        _installNum.textColor = ESColor.labelColor;
        _installNum.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:_installNum];
    }
    return _installNum;
}

- (UILabel *)installNumText {
    if (!_installNumText) {
        _installNumText = [[UILabel alloc] init];
        _installNumText.textColor = ESColor.secondaryLabelColor;
        _installNumText.text = NSLocalizedString(@"app_install_times", @"次安装");
        _installNumText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _installNumText.textAlignment = NSTextAlignmentLeft;
        [self.scrollView addSubview:_installNumText];
    }
    return _installNumText;
}


- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.textColor = ESColor.labelColor;
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        _sizeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.scrollView addSubview:_sizeLabel];
    }
    return _sizeLabel;
}

- (UILabel *)sizeLabelText {
    if (!_sizeLabelText) {
        _sizeLabelText = [[UILabel alloc] init];
        _sizeLabelText.textColor = ESColor.secondaryLabelColor;
        _sizeLabelText.textAlignment = NSTextAlignmentLeft;
        _sizeLabelText.text = NSLocalizedString(@"size", @"大小");
        _sizeLabelText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.view addSubview:_sizeLabelText];
    }
    return _sizeLabelText;
}


- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:@"app_store_def"];
        [self.frameView addSubview:_headImageView];
    }
    return _headImageView;
}

- (UIView *)line1 {
    if (!_line1) {
        _line1 = [UIView new];
        _line1.backgroundColor = ESColor.separatorColor;
        [self.scrollView addSubview:_line1];
    }
    return _line1;
}

- (UIView *)line2 {
    if (!_line2) {
        _line2 = [UIView new];
        _line2.backgroundColor = ESColor.separatorColor;
        [self.scrollView addSubview:_line2];
    }
    return _line2;
}

- (UIView *)line3 {
    if (!_line3) {
        _line3 = [UIView new];
        _line3.backgroundColor = ESColor.separatorColor;
        [self.scrollView addSubview:_line3];
    }
    return _line3;
}

- (UIView *)line4 {
    if (!_line4) {
        _line4 = [UIView new];
        _line4.backgroundColor = ESColor.separatorColor;
        [self.scrollView addSubview:_line4];
    }
    return _line4;
}

- (UIView *)line5 {
    if (!_line5) {
        _line5 = [UIView new];
        _line5.backgroundColor = ESColor.separatorColor;
        [self.scrollView addSubview:_line5];
    }
    return _line5;
}

-(void)setAppStoreModel:(ESAppStoreModel *)model{
    _appStoreModel = model;
}

- (UILabel *)lastUpdated {
    if (!_lastUpdated) {
        _lastUpdated = [[UILabel alloc] init];
        _lastUpdated.textColor = ESColor.labelColor;
        _lastUpdated.textAlignment = NSTextAlignmentLeft;
        _lastUpdated.text = NSLocalizedString(@"appstore_recent_update", @"最近更新");
        _lastUpdated.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.scrollView addSubview:_lastUpdated];
    }
    return _lastUpdated;
}

- (UILabel *)lastUpdatedText {
    if (!_lastUpdatedText) {
        _lastUpdatedText = [[UILabel alloc] init];
        _lastUpdatedText.textColor = ESColor.labelColor;
        _lastUpdatedText.textAlignment = NSTextAlignmentLeft;
        _lastUpdatedText.numberOfLines = 0;
        _lastUpdatedText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.scrollView addSubview:_lastUpdatedText];
    }
    return _lastUpdatedText;
}

- (UILabel *)appTitle {
    if (!_appTitle) {
        _appTitle = [[UILabel alloc] init];
        _appTitle.textColor = ESColor.labelColor;
        _appTitle.textAlignment = NSTextAlignmentLeft;
        _appTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
      //  [self.navigationController.view addSubview:_appTitle];
        [self.navView addSubview:_appTitle];
    }
    return _appTitle;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = ESColor.labelColor;
        _name.textAlignment = NSTextAlignmentLeft;
        _name.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
        [self.scrollView addSubview:_name];
    }
    return _name;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = ESColor.systemBackgroundColor;
        UIImageView *returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 45 + 20, 18, 18)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 45 + 20, 44, 44)];
        returnImageView.image = [UIImage imageNamed:@"ic_back_chevron"];
        [_navView addSubview:returnImageView];
        _navView.userInteractionEnabled = YES;
        [self.view addSubview:_navView];
        
        [btn addTarget:self action:@selector(returnBtn) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:btn];
    }
    return _navView;
}


- (UILabel *)desc {
    if (!_desc) {
        _desc = [[UILabel alloc] init];
        _desc.textColor = ESColor.secondaryLabelColor;
        _desc.textAlignment = NSTextAlignmentLeft;
        _desc.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.scrollView addSubview:_desc];
    }
    return _desc;
}

- (UILabel *)introduce {
    if (!_introduce) {
        _introduce = [[UILabel alloc] init];
        _introduce.textColor = ESColor.labelColor;
        _introduce.text = NSLocalizedString(@"appstore_app_introduction", @"应用介绍");
        _introduce.textAlignment = NSTextAlignmentLeft;
        _introduce.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        [self.scrollView addSubview:_introduce];
    }
    return _introduce;
}

- (UILabel *)introduceText {
    if (!_introduceText) {
        _introduceText = [[UILabel alloc] init];
        _introduceText.textColor = ESColor.labelColor;
        _introduceText.textAlignment = NSTextAlignmentLeft;
        _introduceText.numberOfLines = 0;
        _introduceText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.scrollView addSubview:_introduceText];
    }
    return _introduceText;
}

- (ESGradientButton *)openBtn {
    if (!_openBtn) {
        _openBtn = [[ESGradientButton alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_openBtn setCornerRadius:10];
        _openBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_openBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [self.view addSubview:_openBtn];
        _openBtn.alpha = 1;
        [_openBtn addTarget:self action:@selector(openBtnAct:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_moreBtn setTitle:NSLocalizedString(@"View_more", @"查看更多") forState:UIControlStateNormal];
        [_moreBtn setBackgroundColor:ESColor.systemBackgroundColor];
        [_moreBtn addTarget:self action:@selector(moreAct) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
        [self.scrollView addSubview:_moreBtn];
    }
    return _moreBtn;
}

-(void)openBtnAct:(UIButton *)btn{
    if([btn.titleLabel.text isEqual:NSLocalizedString(@"appstore_state_install", @"安装")]){
        [_openBtn startLoading:NSLocalizedString(@"Installing", @"安装中") ];
        [self getManagementServiceDownApi];
    }else if(([btn.titleLabel.text isEqual:NSLocalizedString(@"Open", @"打开")])){
    
            NSDictionary *dicApp = [[ESCache defaultCache] objectForKey:@"v2_app_sel_status"];
            NSString *key = [ESCommonToolManager miniAppKey:self.appStoreModel.appId];
            NSString *appStatus = dicApp[key];
        
        if([appStatus isEqual:@"YES"]){
            if([self.appStoreModel.deployMode isEqual:@"service"] ||[self.appStoreModel.deployMode isEqual:@"frontService"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    ESAgreementWebVC *vc = [ESAgreementWebVC new];
                    vc.agreementType = ESAppOpen;
                    vc.urlStr = self.appStoreModel.containerWebUrl;
                    ESAppletInfoModel *info = [ESAppletInfoModel new];
                    info.appletId =self.appStoreModel.appId;
                    info.name = self.appStoreModel.name;
                    info.iconUrl =self.appStoreModel.iconUrl;
                    info.deployMode =self.appStoreModel.deployMode;
                    info.appletVersion =self.appStoreModel.curVersion;
                    info.type = @"dockApp";
                    vc.appletInfo =info;
                    [self.navigationController pushViewController:vc animated:YES];
                    // [SVProgressHUD dismiss];
                });
        }else{
            [self down];
        }
        }else{
            ESAppWelcome *vc = [ESAppWelcome new];
            ESFormItem *info = [self infoToFormItem:self.appStoreModel];
            vc.stateCode = self.appStoreModel.stateCode;
            vc.item = info;
            [self.navigationController pushViewController:vc animated:YES];
        }

    }else if([btn.titleLabel.text isEqual:NSLocalizedString(@"appstore_state_update", @"更新")]){
        [_openBtn startLoading:NSLocalizedString(@"Updating", @"更新中")];
        [self getManagementServiceUpdeApi];
    }
}


- (void)getManagementServiceDownApi{
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_install"
                                                queryParams:@{@"appid" : self.appStoreModel.appId,
                                                              @"packageid":self.appStoreModel.packageId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self creatTimer];
        });
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([[error codeString] isEqualToString:@"GW-5006"]) {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        } else {
            [ESToast toastError:NSLocalizedString(@"applet_dialog_fail_install_title", @"安装失败")];
        }
        [self.openBtn stopLoading:NSLocalizedString(@"appstore_state_install", @"安装")];
    }];
}

-(void)down{
    
    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:self.appStoreModel.appId];
    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
    NSFileManager *file = [NSFileManager new];
    if([file fileExistsAtPath:path]){
        ESAppletViewController *appletVC = [[ESAppletViewController alloc] init];
        ESAppletInfoModel *viewModel =  [ESAppletInfoModel new];
        viewModel.name = self.appStoreModel.name;
        viewModel.appletId = self.appStoreModel.appId;
        viewModel.appletVersion = self.appStoreModel.version;
        viewModel.installedAppletVersion = self.appStoreModel.version;
        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:self.appStoreModel.appId];
        NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
        viewModel.localCacheUrl = path;
        viewModel.iconUrl = self.appStoreModel.iconUrl;
   
        [appletVC loadWithAppletInfo:viewModel];
        [self.navigationController pushViewController:appletVC animated:YES];
       }
    else{
        ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:self.appStoreModel.appId];
        [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:nil];
        NSString *picZipCachePath = [ESSmarPhotoCacheManager cacheZipPathWithDate:@"12"];
        [ESNetworkRequestManager sendCallDownloadRequest:@{ @"serviceName" : @"eulixspace-appstore-service",
                                                            @"apiName" : @"appstore_down"}
                                                queryParams:@{@"appid" : self.appStoreModel.appId
                                                             }
                                                  header:@{}
                                                    body:@{}
                                              targetPath:picZipCachePath
                                                  status:^(NSInteger requestId, ESNetworkRequestServiceStatus status) {
                                                   }
                                            successBlock:^(NSInteger requestId, NSURL * _Nonnull location) {
            BOOL unZipSuccess = [ESAppletManager.shared addAppletCacheWithId:self.appStoreModel.appId
                                                                appletVerion:self.appStoreModel.version
                                                            downloadFilePath:picZipCachePath];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESToast dismiss];
                if(unZipSuccess){
                    NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:self.appStoreModel.appId];
                    NSString *path = [NSString stringWithFormat:@"%@/index.html",unzipPath];
                    NSFileManager *file = [NSFileManager new];
                    if([file fileExistsAtPath:path]){
                        ESAppletViewController *appletVC = [[ESAppletViewController alloc] init];
                        ESAppletInfoModel *viewModel =  [ESAppletInfoModel new];
                        viewModel.name = self.appStoreModel.name;
                        viewModel.appletId = self.appStoreModel.appId;
                        viewModel.iconUrl = self.appStoreModel.iconUrl;
                        [appletVC loadWithAppletInfo:viewModel];
                        [self.navigationController pushViewController:appletVC animated:YES];
                    }else{
                       [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                    }
                }else{
                    [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                }
            });
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESToast dismiss];
               [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
            });
        }];
    }
}

- (void)getManagementServiceUpdeApi{
  //  ESAppStoreModel *model  = self.dataList[0];
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_update"
                                                queryParams:@{@"appid" : self.appStoreModel.appId,
                                                              @"packageid":self.appStoreModel.packageId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self creatTimer];
        });
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];

            if ([[error codeString] isEqualToString:@"GW-5006"]) {
                [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
            } else {
                [ESToast toastError:NSLocalizedString(@"applet_dialog_fail_update_title", @"更新失败")];
            }
        });
    }];
}

- (NSMutableParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.lineSpacing = 5.f;
    return para;
}

- (void)setShowTextWithDesc:(NSString *)desc
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@...收起",desc] attributes:@{ NSFontAttributeName:FONT(15), NSParagraphStyleAttributeName : [self paragraphStyle]}];
    self.lastUpdatedText.attributedText = text;
}

-(void)moreAct{
    self.lastUpdatedText.numberOfLines = 0;
}

- (void)getManagementServiceApi {
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_sort_list"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([response isKindOfClass:[NSArray class]]){
                self.dataResponse = [[NSMutableArray alloc] init];
                for (NSDictionary *dictData in response) {
                    self.dataList = [[NSMutableArray alloc] init];
                    NSArray *arrayAppDate= dictData[@"appStoreResList"];
                    for (NSDictionary *dict in arrayAppDate) {
                        ESAppStoreModel *model = [ESAppStoreModel yy_modelWithJSON:dict];
                        if([model.appId isEqual: self.appStoreModel.appId]){
                            if(model.stateCode == ESINSTALLED){
                                    if([self.openBtn.titleLabel.text containsString:NSLocalizedString(@"Installing", @"安装中")]){
                                         [self.openBtn stopLoading:NSLocalizedString(@"Open", @"打开")];
                                        self.appStoreModel = model;
                                        [ESToast toastSuccess:NSLocalizedString(@"app_install_success", @"安装成功")];
                                    }else if([self.openBtn.titleLabel.text containsString:NSLocalizedString(@"Updating", @"更新中")]){
                                        [self.openBtn stopLoading:NSLocalizedString(@"Open", @"打开")];
                                        [ESToast toastSuccess:NSLocalizedString(@"applet_update_success",@"更新成功")];
                                        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:model.appId];
                                        [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:nil];
                                    }
                                    [self timerStop];
                                
                            }else if(model.stateCode == ESINSTALLFAIL){
                                [self timerStop];
                                [self.openBtn stopLoading:NSLocalizedString(@"appstore_state_install", @"安装")];
                                [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
                            }else if(model.stateCode == ESUPDATEFAIL){
                                [self timerStop];
                                [self.openBtn stopLoading:NSLocalizedString(@"me_upgrade", @"更新")];
                                [ESToast toastError:NSLocalizedString(@"applet_install_fail", @"安装失败")];
                            }else if(model.stateCode == ESUNINSTALL){
                                [self timerStop];
                                [self.openBtn stopLoading:NSLocalizedString(@"appstore_state_install", @"安装")];
                            }
                        }
                    }
                }
            }
        });
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([[error codeString] isEqualToString:@"GW-5006"])  {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        }
        [self timerStop];
    }];
}


- (void)creatTimer {
    //0.创建队列
    if(!self.timer){
        dispatch_queue_t queue = dispatch_get_main_queue();

        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);

        //3.要调用的任务
        dispatch_source_set_event_handler(self.timer, ^{
            [self getManagementServiceApi];
        });
        //4.开始执行
        dispatch_resume(self.timer);
    }
}

- (void)timerStop {
    @synchronized (self){
        if (self.timer) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y > 40) {
        self.appTitle.hidden = NO;
    }else{
        self.appTitle.hidden = YES;
    }
}

-(void)returnBtn{
    [self.navigationController popViewControllerAnimated:YES];
    self.hideNavigationBar  = NO;
}

-(NSString *) convertFileSize:(long long)size {
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.2f G", (float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0f M", f];
        }else{
            return [NSString stringWithFormat:@"%.2f M", f];
        }
    } else if (size >= kb) {
        float f = (float) size / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0f K", f];
        }else{
            return [NSString stringWithFormat:@"%.2f K", f];
        }
    } else
        return [NSString stringWithFormat:@"%lld B", size];
}

-(void)dealloc{
    [self timerStop];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self timerStop];
}

-(ESFormItem *)infoToFormItem:(ESAppStoreModel *)item{
    ESFormItem *info = [ESFormItem new];
    info.appId = item.appId;
    info.title= item.name ;
    info.iconUrl = item.iconUrl;
    info.containerWebUrl = item.containerWebUrl;
    info.deployMode = item.deployMode;
    info.webUrl = item.webUrl;
    info.type = @"dockApp";
    return info;
}

@end
