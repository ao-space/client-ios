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
//  ESFileSortView.m
//  EulixSpace
//
//  Created by qu on 2021/11/29.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESFileSortView.h"
#import "ESColor.h"
#import "ESThemeDefine.h"
#import <Masonry/Masonry.h>
#import "ESRecycleBinVC.h"
#import "UIWindow+ESVisibleVC.h"

typedef NS_ENUM(NSUInteger, ESSortSelected) {
    ESSortClassNameSelected,
    ESSortClassTimeSelected,
    ESSortClassTypeSelected
};

@interface ESFileSortView ()

@property (nonatomic, strong) UIView *programView;

@property (nonatomic, strong) UIButton *delectBtn;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *typeLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *nameArrowBtn;

@property (nonatomic, strong) UIButton *timeArrowBtn;

@property (nonatomic, strong) UIButton *typeArrowBtn;

@property (nonatomic, strong) UIImageView *nameIconImageView;

@property (nonatomic, strong) UIImageView *timeIconImageView;

@property (nonatomic, strong) UIImageView *typeIconImageView;

@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, assign) ESSortSelected selectedType;

@property (nonatomic, assign) BOOL actionLock;

@end

@implementation ESFileSortView

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
        make.height.mas_equalTo(444);
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
    
    UIView *more = [self creatCellViewTitleClass:5 iconImage:[UIImage imageNamed:@"sort_sed"]];
    [self.programView addSubview:more];
    UITapGestureRecognizer *moreTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreTag)];
    [more addGestureRecognizer:moreTap];
    [more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.programView.mas_top).offset(55.0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(62.0f);
    }];
    
    UIView * recycleView = [self creatCellViewTitleClass:ESSortClassRecycle iconImage:[UIImage imageNamed:@"me_recycle_blank 1"]];
    [self.programView addSubview:recycleView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRecycle)];
    [recycleView addGestureRecognizer:tap];
    [recycleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(more.mas_bottom).offset(0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(62.0f);
    }];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = ESColor.secondarySystemBackgroundColor;
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"file_sort_order_title", @"排序方式");
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [ESColor secondaryLabelColor];
    [bgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_top).offset(6.0);
        make.left.mas_equalTo(bgView.mas_left).offset(26);
        make.height.mas_equalTo(17.0f);
    }];
    [self.programView addSubview:bgView];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(recycleView.mas_bottom).offset(0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(30.0f);
    }];
    
    
    UIView *nameSort = [self creatCellViewTitleClass:ESSortClassName iconImage:IMAGE_FILE_SORT_NAME];
    [self.programView addSubview:nameSort];
    UITapGestureRecognizer *nameSortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameSortTag)];
    [nameSort addGestureRecognizer:nameSortTap];
    [nameSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView.mas_bottom).offset(0);
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
    
    UIView *typeSort = [self creatCellViewTitleClass:ESSortClassType iconImage:IMAGE_FILE_SORT_CLASS];
    [self.programView addSubview:typeSort];
    UITapGestureRecognizer *typeSortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeSortTap)];
    [typeSort addGestureRecognizer:typeSortTap];
    
    [typeSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeSort.mas_bottom).offset(0.0);
        make.right.mas_equalTo(self.programView.mas_right).offset(0);
        make.left.mas_equalTo(self.programView.mas_left).offset(0);
        make.height.mas_equalTo(62.0f);
    }];
}

- (void)onRecycle {
    self.hidden = YES;
    ESRecycleBinVC *vc = [[ESRecycleBinVC alloc] init];
    [[UIWindow getCurrentVC].navigationController pushViewController:vc animated:YES];
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
        _programView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 444, ScreenWidth, 444)];
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
        _titleLabel.text = NSLocalizedString(@"common_more", @"更多");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
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
    
    UIImageView *headImage = [UIImageView new];
    headImage.image = iconImage;
    [cellView addSubview:headImage];
    
    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    title.textColor = [ESColor labelColor];
    [cellView addSubview:title];
    
    UIButton *arrowBtn = [UIButton new];
    arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:18]];
    [arrowBtn addTarget:self action:@selector(sortCompleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    arrowBtn.selected = NO;
    [arrowBtn setTitleColor:ESColor.systemBackgroundColor forState:UIControlStateNormal];
    [cellView addSubview:arrowBtn];
    
    [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cellView.mas_left).offset(26.0);
        make.top.mas_equalTo(cellView.mas_top).offset(19.0);
        make.width.equalTo(@(24.0f));
        make.height.equalTo(@(24.0f));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headImage.mas_right).offset(10.0);
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
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ESColor.separatorColor;
    [cellView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(cellView.mas_right).offset(-24.0);
        make.bottom.mas_equalTo(cellView.mas_bottom).offset(-1.0f);
        make.left.mas_equalTo(cellView.mas_left).offset(24.0);
        make.height.equalTo(@(1.0f));
    }];
    
    if (class == ESSortClassName) {
        title.text = NSLocalizedString(@"file_sort_name", @"按名称排序");
        title.textColor = ESColor.labelColor;
        self.nameLabel = title;
        arrowBtn.hidden = YES;
        arrowBtn.tag = 100021;
        self.nameArrowBtn = arrowBtn;
        self.nameIconImageView = headImage;
        [arrowBtn setImage:IMAGE_FILE_SORT_UP forState:UIControlStateNormal];
    } else if (class == ESSortClassTime) {
        title.text =   NSLocalizedString(@"file_sort_time", @"按修改时间排序");
        title.textColor = ESColor.primaryColor;
        self.selectedType = ESSortClassTimeSelected;
        arrowBtn.hidden = NO;
        arrowBtn.tag = 100022;
        self.timeLabel = title;
        self.timeArrowBtn = arrowBtn;
        self.timeIconImageView = headImage;
        [arrowBtn setImage:IMAGE_FILE_SORT_DOWN forState:UIControlStateNormal];
        
    } else if(class == ESSortClassType){
        title.text = NSLocalizedString(@"file_sort_type", @"按文件类型排序");
        title.textColor = ESColor.labelColor;
        lineView.hidden = YES;
        arrowBtn.hidden = YES;
        self.typeLabel = title;
        arrowBtn.tag = 100023;
        self.typeArrowBtn = arrowBtn;
        self.typeIconImageView = headImage;
        [arrowBtn setImage:IMAGE_FILE_SORT_DOWN forState:UIControlStateNormal];
    } else if (class == ESSortClassRecycle) {
        title.text = NSLocalizedString(@"main_recycleBinBtn", @"回收站");
        lineView.hidden = YES;
        arrowBtn.hidden = YES;
    }
    else{
        title.text = NSLocalizedString(@"Select", @"选择");
        title.textColor = ESColor.labelColor;
//        lineView.hidden = YES;
        arrowBtn.hidden = YES;
//        self.typeLabel = title;
        arrowBtn.tag = 100025;
//        self.typeArrowBtn = arrowBtn;
     //   self.typeIconImageView = headImage;
        
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
    
    if (self.selectedType == ESSortClassNameSelected) {
        //切换排序方式
        [self sortCompleteBtn:[self getSortButtonBySortClass:ESSortClassName]];
        return;
    }
    
    self.selectedType = ESSortClassNameSelected;
    self.timeLabel.textColor = [ESColor labelColor];
    self.nameLabel.textColor = [ESColor primaryColor];
    self.typeLabel.textColor = [ESColor labelColor];
    self.nameArrowBtn.hidden = NO;
    self.timeArrowBtn.hidden = YES;
    self.typeArrowBtn.hidden = YES;
    self.nameIconImageView.image = IMAGE_FILE_SORT_NAME_SELECTED;
    self.timeIconImageView.image = IMAGE_MAIN_SORT_TIME;
    self.typeIconImageView.image = IMAGE_FILE_SORT_CLASS;
    
    self.nameArrowBtn.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassName isUpSort:self.nameArrowBtn.selected];
    }
    [self.nameArrowBtn setImage: self.nameArrowBtn.selected ? IMAGE_FILE_SORT_UP : IMAGE_FILE_SORT_DOWN
                       forState:UIControlStateNormal];
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
    if (self.selectedType == ESSortClassTimeSelected) {
        //切换排序方式
        [self sortCompleteBtn:[self getSortButtonBySortClass:ESSortClassTime]];
        return;
    }
    
    self.selectedType = ESSortClassTimeSelected;
    self.timeLabel.textColor = [ESColor primaryColor];
    self.nameLabel.textColor = [ESColor labelColor];
    self.typeLabel.textColor = [ESColor labelColor];
    self.nameArrowBtn.hidden = YES;
    self.timeArrowBtn.hidden = NO;
    self.typeArrowBtn.hidden = YES;
    
    self.nameIconImageView.image = IMAGE_FILE_SORT_NAME;
    self.timeIconImageView.image = IMAGE_MAIN_SORT_TIME_SELECTED;
    self.typeIconImageView.image = IMAGE_FILE_SORT_CLASS;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassTime isUpSort:self.timeArrowBtn.selected];
    }
    [self.timeArrowBtn setImage:self.timeArrowBtn.selected ? IMAGE_FILE_SORT_UP : IMAGE_FILE_SORT_DOWN
                       forState:UIControlStateNormal];
}




- (void)moreTag {
    self.actionBlock(@"moreTag");
    self.hidden = YES;
}
- (void)typeSortTap {

    if (self.selectedType == ESSortClassTypeSelected) {
        //切换排序方式
        [self sortCompleteBtn:[self getSortButtonBySortClass:ESSortClassType]];
        return;
    }
    
    self.selectedType = ESSortClassTypeSelected;
    self.timeLabel.textColor = [ESColor labelColor];
    self.nameLabel.textColor = [ESColor labelColor];
    self.typeLabel.textColor = [ESColor primaryColor];
    self.nameArrowBtn.hidden = YES;
    self.timeArrowBtn.hidden = YES;
    self.typeArrowBtn.hidden = NO;

    self.nameIconImageView.image = IMAGE_FILE_SORT_NAME;
    self.timeIconImageView.image = IMAGE_MAIN_SORT_TIME;
    self.typeIconImageView.image = IMAGE_FILE_SORT_CLASS_SELECTED;
    self.typeArrowBtn.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
        [self.delegate fileSortView:self didSortType:ESSortClassType isUpSort:self.typeArrowBtn.selected];
    }
    
    [self.typeArrowBtn setImage:self.typeArrowBtn.selected ? IMAGE_FILE_SORT_UP : IMAGE_FILE_SORT_DOWN
                       forState:UIControlStateNormal];
}

/// 点击箭头切换
- (void)sortCompleteBtn:(UIButton *)btn {
//    if (_actionLock) {
//        return;
//    }
    
    _actionLock = YES;
    if (btn.tag == 100021) {
        if (!self.nameArrowBtn.selected) {
            self.nameArrowBtn.selected = YES;
            [self.nameArrowBtn setImage:IMAGE_FILE_SORT_UP forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassName isUpSort:YES];
            }
        } else {
            self.nameArrowBtn.selected = NO;
            [self.nameArrowBtn setImage:IMAGE_FILE_SORT_DOWN forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassName isUpSort:NO];
            }
        }
    } else if (btn.tag == 100022) {
        if (!self.timeArrowBtn.selected) {
            self.timeArrowBtn.selected = YES;
            [self.timeArrowBtn setImage:IMAGE_FILE_SORT_UP forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassTime isUpSort:YES];
            }
        } else {
            self.timeArrowBtn.selected = NO;
            [self.timeArrowBtn setImage:IMAGE_FILE_SORT_DOWN forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassTime isUpSort:NO];
            }
        }
    } else if (btn.tag == 100023) {
        if (!self.typeArrowBtn.selected) {
            self.typeArrowBtn.selected = YES;
            [self.typeArrowBtn setImage:IMAGE_FILE_SORT_UP forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassType isUpSort:YES];
            }
        } else {
            self.typeArrowBtn.selected = NO;
            [self.typeArrowBtn setImage:IMAGE_FILE_SORT_DOWN forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(fileSortView:didSortType:isUpSort:)]) {
                [self.delegate fileSortView:self didSortType:ESSortClassType isUpSort:NO];
            }
        }
    }
}

@end
