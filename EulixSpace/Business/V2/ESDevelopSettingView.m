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
//  ESDevelopSettingView.m
//  EulixSpace
//
//  Created by qu on 2021/11/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESDevelopSettingView.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, ESSortSelected) {
    ESSortClassNameSelected,
    ESSortClassTimeSelected,
    ESSortClassTypeSelected
};

@interface ESDevelopSettingView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *typeLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *nameArrowBtn;

@property (nonatomic, strong) UIButton *timeArrowBtn;

@property (nonatomic, strong) UIButton *typeArrowBtn;

@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, assign) ESSortSelected selectedType;

@property (nonatomic, assign) BOOL actionLock;

@property (nonatomic, strong) NSString *strValue;

@property (nonatomic, strong) UILabel *title1;

@property (nonatomic, strong) UILabel *title2;




@end

@implementation ESDevelopSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        _actionLock = NO;
    }
    return self;
}

- (void)initUI {
    [self.programView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(380.0f);
        make.width.mas_equalTo(ScreenWidth);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.programView.mas_top).offset(20);
        make.height.mas_equalTo(25.0f);
        make.width.mas_equalTo(200.0f);
    }];
    
    [self.delectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.right.mas_equalTo(self.programView.mas_right).offset(-20);
        make.height.mas_equalTo(48.0f);
        make.width.mas_equalTo(48.0f);
    }];
    
    UIView *nameSort = [self creatCellViewTitleClass:ESSortClassName iconImage:IMAGE_FILE_SORT_NAME];
    [self.programView addSubview:nameSort];

    UITapGestureRecognizer *nameSortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameSortTag)];
    [nameSort addGestureRecognizer:nameSortTap];
    [nameSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(81.0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(62.0f);
    }];
    
    UIView *timeSort = [self creatCellViewTitleClass:ESSortClassTime iconImage:IMAGE_MAIN_SORT_TIME_SELECTED];
    [self.programView addSubview:timeSort];
    UITapGestureRecognizer *timeSortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSortTap)];
    [timeSort addGestureRecognizer:timeSortTap];
    [timeSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameSort.mas_bottom).offset(0.0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(62.0f);
    }];

}

- (void)hiddenWithAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.alpha = 1;
            self.hidden = YES;
            self.actionLock = NO;
        }];
    });
}

#pragma mark - Lazy Load

- (UIView *)programView {
    if (!_programView) {
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 380, ScreenWidth, 380)];
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

- (UIButton *)delectBtn {
    if (nil == _delectBtn) {
        _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delectBtn addTarget:self action:@selector(didClickDelectBtn) forControlEvents:UIControlEventTouchUpInside];
        [_delectBtn setImage:IMAGE_COMMON_CLOSE forState:UIControlStateNormal];
        [self.programView addSubview:_delectBtn];
    }
    return _delectBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = ESColor.labelColor;
        _titleLabel.text = NSLocalizedString(@"port_forward_type", @"端口转发类型");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        [self.programView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = ESColor.separatorColor;
        [self addSubview:_line];
    }
    return _line;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [UIImageView new];
        _arrowImageView.image = IMAGE_FILE_COPYBACK;
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIView *)creatCellViewTitleClass:(ESSortClass)class iconImage:(UIImage *)iconImage {
    UIView *cellView = [[UIView alloc] init];

    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    title.textColor = [ESColor labelColor];
    [cellView addSubview:title];
    
    UIButton *arrowBtn = [UIButton new];
    arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:18]];
    [arrowBtn addTarget:self action:@selector(sortCompleteBtn) forControlEvents:UIControlEventTouchUpInside];
    arrowBtn.selected = NO;
    [arrowBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
    [cellView addSubview:arrowBtn];
    

    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellView.mas_left).offset(23.0);
        make.right.mas_equalTo(cellView.mas_right).offset(-60.0);
        make.top.mas_equalTo(cellView.mas_top).offset(20.0);
        make.height.equalTo(@(22.0f));
    }];
    
    [arrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cellView.mas_top).offset(10.0);
        make.right.mas_equalTo(cellView.mas_right).offset(-29.0);
        make.width.equalTo(@(44.0f));
        make.height.equalTo(@(44.0f));
    }];
    
    if (class == ESSortClassName) {
        title.text = NSLocalizedString(@"internal_port", @"内部端口");
        self.title1 = title;
//        title.textColor = ESColor.labelColor;
        title.textColor = ESColor.primaryColor;
        self.selectedType = ESSortClassTimeSelected;
        self.nameLabel = title;
        arrowBtn.hidden = NO;
        arrowBtn.tag = 100021;
        self.nameArrowBtn = arrowBtn;
        [arrowBtn setImage:[UIImage imageNamed:@"v2_xuanze"] forState:UIControlStateNormal];
    } else if (class == ESSortClassTime) {
        title.text = NSLocalizedString(@"lan_access_port", @"局域网可访问端口");
        self.title2 = title;
        title.textColor = ESColor.labelColor;
//        self.selectedType = ESSortClassTimeSelected;
        arrowBtn.hidden = YES;
        arrowBtn.tag = 100022;
        self.timeLabel = title;
        self.timeArrowBtn = arrowBtn;
        [arrowBtn setImage:[UIImage imageNamed:@"v2_xuanze"] forState:UIControlStateNormal];
    }
    
    return cellView;
}

- (void)didClickDelectBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didClicCancelBtn:)]) {
        [self.delegate fileSortView:self didClicCancelBtn:nil];
    }
}
/// 切换名称
- (void)nameSortTag {

    self.selectedType = ESSortClassNameSelected;
    self.timeLabel.textColor = [ESColor labelColor];
    self.nameLabel.textColor = [ESColor primaryColor];
    self.strValue = self.nameLabel.text;

    if([self.type isEqual:@"http"]){
        self.actionHttpBlock(self.strValue,self.tag);
    }else{
        self.actionPostBlock(self.strValue,self.tag);
    }
 
    self.typeLabel.textColor = [ESColor labelColor];
    self.nameArrowBtn.hidden = NO;
    self.timeArrowBtn.hidden = YES;
    self.typeArrowBtn.hidden = YES;
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassName isUpSort:self.nameArrowBtn.selected];
    }
//    [self.nameArrowBtn setImage: self.nameArrowBtn.selected ? IMAGE_FILE_SORT_UP : IMAGE_FILE_SORT_DOWN
//                       forState:UIControlStateNormal];
    [self.nameArrowBtn setImage:[UIImage imageNamed:@"v2_xuanze"] forState:UIControlStateNormal];
}

- (UIButton *)getSortButtonBySortClass:(ESSortClass)sortClass {
    NSDictionary *map = [self sortTagMap];
    
    if (map[@(sortClass)]) {
        NSInteger viewTag = [map[@(sortClass)] intValue];
        UIButton *bt = [self viewWithTag:viewTag];
        return bt;
    }
    return nil;
}

- (NSDictionary <NSNumber *, NSNumber *> *)sortTagMap {
    return @{ @(ESSortClassName) : @(100021),
              @(ESSortClassTime) : @(100022),
              @(ESSortClassType) : @(100023)
    };
}

- (void)timeSortTap {
    self.selectedType = ESSortClassTimeSelected;
    self.timeLabel.textColor = [ESColor primaryColor];
    self.strValue = self.timeLabel.text;
//    self.actionPostBlock(self.strValue);
    if([self.type isEqual:@"http"]){
        self.actionHttpBlock(self.strValue,self.tag);
    }else{
        self.actionPostBlock(self.strValue,self.tag);
    }
    self.nameLabel.textColor = [ESColor labelColor];
    self.typeLabel.textColor = [ESColor labelColor];
    self.nameArrowBtn.hidden = YES;
    self.timeArrowBtn.hidden = NO;
    self.typeArrowBtn.hidden = YES;
  
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassTime isUpSort:self.timeArrowBtn.selected];
    }
//    [self.timeArrowBtn setImage:self.timeArrowBtn.selected ? IMAGE_FILE_SORT_UP : IMAGE_FILE_SORT_DOWN
//                       forState:UIControlStateNormal];
    
    [self.timeArrowBtn setImage:[UIImage imageNamed:@"v2_xuanze"] forState:UIControlStateNormal];
}



- (void)moreTag {
//    self.actionPostBlock(self.strValue);
    if([self.type isEqual:@"http"]){
        self.actionHttpBlock(self.strValue,self.tag);
    }else{
        self.actionPostBlock(self.strValue,self.tag);
    }
    self.hidden = YES;
}

- (void)typeSortTap {

//    if (self.selectedType == ESSortClassTypeSelected) {
//        //切换排序方式
//        [self sortCompleteBtn:[self getSortButtonBySortClass:ESSortClassType]];
//        return;
//    }
    
    self.selectedType = ESSortClassTypeSelected;
    self.timeLabel.textColor = [ESColor labelColor];
    self.nameLabel.textColor = [ESColor labelColor];
    self.typeLabel.textColor = [ESColor primaryColor];
    self.strValue = self.typeLabel.text;

    if([self.type isEqual:@"http"]){
        self.actionHttpBlock(self.strValue,self.tag);
    }else{
        self.actionPostBlock(self.strValue,self.tag);
    }
    self.nameArrowBtn.hidden = YES;
    self.timeArrowBtn.hidden = YES;
    self.typeArrowBtn.hidden = NO;

    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassType isUpSort:self.typeArrowBtn.selected];
    }

    [self.typeArrowBtn setImage:[UIImage imageNamed:@"v2_xuanze"] forState:UIControlStateNormal];
}


-(void)setType:(NSString *)type{
    _type = type;
    if([type isEqual:@"http"]){
        self.title1.text = NSLocalizedString(@"http_request_forward", @"http请求转发");
        self.title2.text = NSLocalizedString(@"home_other", @"其他");
    }else {
        self.title1.text = NSLocalizedString(@"internal_port", @"内部端口");
        self.title2.text = NSLocalizedString(@"lan_access_port", @"局域网可访问端口");
    }
}


-(void)setValue:(NSString *)value{
    _value = value;
    if([value isEqual:NSLocalizedString(@"http_request_forward", @"http请求转发")]){
        self.title1.textColor = ESColor.primaryColor;
        self.title2.textColor = ESColor.labelColor;
        self.nameArrowBtn.hidden = NO;
        self.timeArrowBtn.hidden = YES;
     
    }else if(([value isEqual:NSLocalizedString(@"home_other", @"其他")])){
         self.title2.textColor = ESColor.primaryColor;
         self.title1.textColor = ESColor.labelColor;
         self.nameArrowBtn.hidden = YES;
         self.timeArrowBtn.hidden = NO;
    }else if([value isEqual:NSLocalizedString(@"internal_port", @"内部端口")]){
        self.title1.textColor = ESColor.primaryColor;
        self.title2.textColor = ESColor.labelColor;
        self.nameArrowBtn.hidden = NO;
        self.timeArrowBtn.hidden = YES;
    }else if([value isEqual:NSLocalizedString(@"lan_access_port", @"局域网可访问端口")]){
        self.title2.textColor = ESColor.primaryColor;
        self.title1.textColor = ESColor.labelColor;
        self.nameArrowBtn.hidden = YES;
        self.timeArrowBtn.hidden = NO;
    }
}



-(void)sortCompleteBtn{
    
}

@end
