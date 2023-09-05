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
//  ESActionSheetController.m
//  EulixSpace
//
//  Created by dazhou on 2023/5/26.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESActionSheetController.h"
#import "AAPLCustomPresentationController.h"
#import "UILabel+ESTool.h"
#import "UIColor+ESHEXTransform.h"
#import "UIButton+ESTouchArea.h"

@implementation ESActionSheetModel

@end

@interface ESActionSheetCell1 : UITableViewCell
@property (nonatomic, strong) UILabel * mTitleLabel;
@property (nonatomic, strong) UIImageView * mSelectIv;
@property (nonatomic, strong) UIView * lineView;

@property (nonatomic, strong) ESActionSheetModel * model;
@end

@implementation ESActionSheetCell1
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)reloadCell:(ESActionSheetModel *)data {
    self.mTitleLabel.text = data.title;
    self.mTitleLabel.textColor = data.isSelected ? [UIColor es_colorWithHexString:@"#337AFF"] : [UIColor es_colorWithHexString:@"#333333"];
    self.mSelectIv.hidden = !data.isSelected;
    self.lineView.hidden = data.hiddenLineView;
}

- (void)initViews {
    self.mTitleLabel = [UILabel createLabel:ESFontPingFangRegular(16) color:@"#337AFF"];
    [self.contentView addSubview:self.mTitleLabel];
    [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(24);
        make.top.mas_equalTo(self.contentView).offset(19);
        make.bottom.mas_equalTo(self.contentView).offset(-19);
    }];
    
    self.mSelectIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sort_selected"]];
    [self.contentView addSubview:self.mSelectIv];
    [self.mSelectIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-24);
        make.centerY.mas_equalTo(self.mTitleLabel);
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor es_colorWithHexString:@"#F7F7F9"];
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(23);
        make.trailing.mas_equalTo(self.contentView).offset(-23);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

@end
@interface ESActionSheetController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UIViewController * srcCtl;
@property (nonatomic, strong) NSString * mTitle;
@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, copy) void (^selectBlock)(long index);
@end

@implementation ESActionSheetController

+ (void)showActionSheetView:(UIViewController *)srcCtl
                      title:(NSString *)title
                       data:(NSMutableArray *)dataArr
                      block:(void(^)(long index))selectBlock
{
    ESActionSheetController * dstCtl = [[ESActionSheetController alloc] init];
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    dstCtl.srcCtl = srcCtl;
    dstCtl.mTitle = title;
    dstCtl.dataArr = dataArr;
    dstCtl.selectBlock = selectBlock;
    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self.tableView reloadData];
}

- (void)onCloseBtn {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor es_colorWithHexString:@"#00000050"];
    UIView * mConView = [[UIView alloc] init];
    mConView.backgroundColor = [UIColor whiteColor];
    mConView.layer.masksToBounds = YES;
    mConView.layer.cornerRadius = 10;
    [self.view addSubview:mConView];
    CGFloat tmpHeight = self.dataArr.count * 60 + 2 * 60;
    CGFloat mConViewHeight = tmpHeight < ScreenHeight ? tmpHeight : ScreenHeight;
    [mConView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(kBottomHeight);
        make.height.mas_equalTo(mConViewHeight + kBottomHeight);
    }];
    
    UILabel * titleLabel = [UILabel createLabel:self.mTitle font:ESFontPingFangMedium(18) color:@"#333333"];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [mConView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(mConView).offset(60);
        make.trailing.mas_equalTo(mConView).offset(-60);
        make.top.mas_equalTo(mConView).offset(20);
    }];
    
    UIButton * closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"common_close_1"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setEnlargeEdge:UIEdgeInsetsMake(10, 20, 10, 10)];
    [mConView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mConView).offset(20);
        make.trailing.mas_equalTo(mConView).offset(-20);
        make.width.height.mas_equalTo(18);
    }];
    
    [mConView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(closeBtn.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(mConView);
        make.bottom.mas_equalTo(mConView).offset(-kBottomHeight);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESActionSheetModel * cellModel = [self.dataArr objectAtIndex:indexPath.row];
    ESActionSheetCell1 * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ESActionSheetCell1.class)];
    [cell reloadCell:cellModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESActionSheetModel * cellModel = [self.dataArr objectAtIndex:indexPath.row];
    if (cellModel.isSelected) {
        return;
    }
    
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.backgroundColor = [UIColor es_colorWithHexString:@"#ffffff"];
        [tableView registerClass:ESActionSheetCell1.class forCellReuseIdentifier:NSStringFromClass(ESActionSheetCell1.class)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        _tableView = tableView;
    }
    return _tableView;
}

@end
