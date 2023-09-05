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
//  ESEmailSSLModifyController.m
//  EulixSpace
//
//  Created by dazhou on 2022/9/16.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESEmailSSLModifyController.h"
#import "AAPLCustomPresentationController.h"
#import "ESSelectCell.h"
#import "NSArray+ESTool.h"
#import "UIFont+ESSize.h"

@interface ESEmailSSLModifyController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, assign) BOOL enableSSL;
@property (nonatomic, copy) void (^doneBlock)(BOOL enableSSL);

@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * doneBtn;

@end

@implementation ESEmailSSLModifyController

+ (void)showSSLModifyView:(UIViewController *)srcCtl ssl:(BOOL)enableSSL done:(void(^)(BOOL enableSSL))doneBlock {
    ESEmailSSLModifyController * dstCtl = [[ESEmailSSLModifyController alloc] init];
    dstCtl.enableSSL = enableSSL;
    dstCtl.doneBlock = doneBlock;
    dstCtl.preferredContentSize = CGSizeMake(ScreenWidth, 300);

    AAPLCustomPresentationController *presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:dstCtl presentingViewController:srcCtl];
    dstCtl.transitioningDelegate = presentationController;
    [srcCtl presentViewController:dstCtl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self initData];
    [self.tableView reloadData];
}

- (void)setupViews {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(10);
        make.height.mas_equalTo(kNavBarHeight);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(kNavBarHeight);
        make.left.mas_equalTo(self.view).offset(10);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(0);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.view).offset(-29);
    }];
}

- (void)initData {
    self.dataArr = [NSMutableArray array];
    weakfy(self)
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"SSL", @"SSL");
        model.isSelected = self.enableSSL;
        model.onClick = ^{
            weak_self.enableSSL = YES;
            [weak_self resetSelectData:0];
        };
        [self.dataArr addObject:model];
    }
    {
        ESCellModel * model = [[ESCellModel alloc] init];
        model.title = NSLocalizedString(@"None", @"无");
        model.lastCell = YES;
        model.isSelected = !self.enableSSL;
        model.onClick = ^{
            weak_self.enableSSL = NO;
            [weak_self resetSelectData:1];
        };
        [self.dataArr addObject:model];
    }
}

- (void)resetSelectData:(int)index {
    [self.dataArr enumerateObjectsUsingBlock:^(ESCellModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = idx == index;
    }];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ESCellModel * model = [self.dataArr getObject:indexPath.row];;
    cell.model = model;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESCellModel * model = [self.dataArr getObject:indexPath.row];;
    if (model.onClick) {
        model.onClick();
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] init];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[ESSelectCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

- (void)onBackBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDoneBtn {
    if (self.doneBlock) {
        self.doneBlock(self.enableSSL);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel * l = [[UILabel alloc] init];
        [self.view addSubview:l];
        l.textAlignment = NSTextAlignmentCenter;
        l.font = ESFontPingFangMedium(18);
        l.textColor = [ESColor colorWithHex:0x333333];
        l.text = NSLocalizedString(@"Security type", @"安全类型");

        _titleLabel = l;
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"photo_back"] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(onBackBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _backBtn = btn;
    }
    return _backBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton * btn = [[UIButton alloc] init];
        [self.view addSubview:btn];
        [btn setTitle:NSLocalizedString(@"done", @"完成") forState:UIControlStateNormal];
        [btn setTitleColor:[ESColor colorWithHex:0x337AFF] forState:UIControlStateNormal];
        btn.titleLabel.font = ESFontPingFangRegular(18);
        [btn addTarget:self action:@selector(onDoneBtn) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = btn;
    }
    return _doneBtn;
}

- (void)dealloc {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
