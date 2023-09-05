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
//  ESFilePageTitleView.m
//  EulixSpace
//
//  Created by qu on 2021/7/12.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#define kScrollLineH 2

#define kTitleW 40
#define kTitleH 40

#import "ESFilePageTitleView.h"
#import "ESColor.h"
#import "ESImageDefine.h"

#import "ESCommonToolManager.h"
#import "ESColor.h"
#import <Masonry/Masonry.h>


@interface ESFilePageTitleView ()

@property (copy, nonatomic) NSArray *titles;
@property (nonatomic, strong) NSMutableArray<UIView *> * hintList;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *scrollLine;

@property (copy, nonatomic) NSMutableArray *titleLabels;

@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation ESFilePageTitleView

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIImageView *)scrollLine {
    if (!_scrollLine) {
        _scrollLine = [[UIImageView alloc] init];
        _scrollLine.image = IMAGE_FILE_TITLE_MENU;
    }
    return _scrollLine;
}

- (NSMutableArray *)titleLabels {
    if (!_titleLabels) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (NSMutableArray<UIView *> *)hintList {
    if (!_hintList) {
        _hintList = [NSMutableArray array];
    }
    return _hintList;
}

+ (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)array {
    ESFilePageTitleView *pageTitleView = [[ESFilePageTitleView alloc] initWithFrame:frame];

    pageTitleView.titles = array;
    [pageTitleView setTitleLabels];
    [pageTitleView setupUI];
    [pageTitleView setupBottomLineAndScrollLine];
    pageTitleView.currentIndex = 0;
    return pageTitleView;
}

+ (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)array titleW:(CGFloat)titleW titleH:(CGFloat)titleH leftDistance:(CGFloat)leftDistance titleSpacing:(CGFloat)titleSpacing fontOfSize:(CGFloat)fontOfSize {
    ESFilePageTitleView *pageTitleView = [[ESFilePageTitleView alloc] initWithFrame:frame];
    pageTitleView.titleW = titleW;
    pageTitleView.titleH = titleH;
    pageTitleView.leftDistance = leftDistance;
    pageTitleView.titleSpacing = titleSpacing;
    pageTitleView.fontOfSize = fontOfSize;
    pageTitleView.titles = array;
    [pageTitleView setTitleLabels];
    [pageTitleView setupUI];
    [pageTitleView setupBottomLineAndScrollLine];
    pageTitleView.currentIndex = 0;
    return pageTitleView;
}

- (void)setupUI {
    [self addSubview:self.scrollView];
    self.scrollView.frame = self.bounds;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMainPhotoBtn:) name:@"topToolViewPhotoBtnNSNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMainVideoBtn:) name:@"topToolViewViedoBtnNSNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickMainFileBtn:) name:@"topToolViewFileBtnNSNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickOtherFileBtn:) name:@"topToolViewOtherBtnNSNotification" object:nil];
}

- (void)didClickMainPhotoBtn:(NSNotification *)notifi {
    [self titleLabelClickedWithView:self.titleLabels[1]];
}

- (void)didClickMainVideoBtn:(NSNotification *)notifi {
    [self titleLabelClickedWithView:self.titleLabels[2]];
}

- (void)didClickMainFileBtn:(NSNotification *)notifi {
    [self titleLabelClickedWithView:self.titleLabels[0]];
}

- (void)didClickOtherFileBtn:(NSNotification *)notifi {
    [self titleLabelClickedWithView:self.titleLabels[4]];
}

- (void)setTitleLabels {
    NSInteger index = 0;
    for (NSString *title in self.titles) {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.tag = index;
        label.textColor = [ESColor secondaryLabelColor];
        if (index == self.currentIndex) {
            label.textColor = [ESColor labelColor];
        }
        label.textAlignment = NSTextAlignmentCenter;
        
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        if([title isEqual: NSLocalizedString(@"home_all", @"全部")]){
            label.textColor = ESColor.labelColor;
        }
        if (!(self.leftDistance > 0)) {
            if ([ESCommonToolManager isEnglish]) {
                self.leftDistance = 12;
            }else{
                self.leftDistance = 22;
            }
        }

        if (!(self.titleW > 0)) {
            if ([ESCommonToolManager isEnglish]) {
                self.titleW = 65;
            }else{
                self.titleW = 40;
            }
        }

        if (!(self.titleSpacing > 0)) {
            if ([ESCommonToolManager isEnglish]) {
                self.titleSpacing = 10;
            }else{
                self.titleSpacing = 32;
            }
        }

        if (!(self.titleH > 0)) {
            self.titleH = 22;
        }

        CGFloat labelX = self.leftDistance + self.titleW * index + self.titleSpacing * index;
        label.frame = CGRectMake(labelX, 18, self.titleW, self.titleH);

        [self.scrollView addSubview:label];
        [self.titleLabels addObject:label];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelClickedWithGes:)];
        [label addGestureRecognizer:tapGes];
        
        
        UIView * hint = [[UIView alloc] init];
        hint.backgroundColor = [ESColor colorWithHex:0xF6222D];
        hint.tag = index;
        hint.layer.masksToBounds = YES;
        hint.layer.cornerRadius = 4;
        [label addSubview:hint];
        [hint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(8);
            make.top.mas_equalTo(label).offset(0);
            make.right.mas_equalTo(label).offset(0);
        }];
        hint.hidden = YES;
        [self.hintList addObject:hint];
        
        index++;
    }
}

- (void)setupBottomLineAndScrollLine {
    if (self.titleLabels != nil) {
        UILabel *firstLabel = [self.titleLabels firstObject];
        self.scrollLine.frame = CGRectMake(firstLabel.frame.origin.x + self.titleW / 2 - 10, firstLabel.frame.origin.y + 22 + 6, 20, 4.0);
        [self.scrollView addSubview:self.scrollLine];
    } else {
        return;
    }
}
#pragma mark - listening to click label

- (void)titleLabelClickedWithGes:(UITapGestureRecognizer *)ges {
    if (ges.view) {
        UILabel *currentLabel = (UILabel *)ges.view;
        UILabel *oldLabel = self.titleLabels[self.currentIndex];
        self.currentIndex = currentLabel.tag;
        currentLabel.textColor = [ESColor labelColor];
        oldLabel.textColor = [ESColor secondaryLabelColor];
        CGFloat scrollLineX = currentLabel.tag * self.titleW + self.leftDistance + currentLabel.tag * self.titleSpacing;
        [UIView animateWithDuration:0.15
                         animations:^{
                             self.scrollLine.frame = CGRectMake(scrollLineX + self.titleW / 2 - 10, currentLabel.frame.origin.y + 22 + 6, self.titleH, 4.0);
                         }];
        [self.delegate pageTitletView:self selectedIndex:self.currentIndex];
    } else {
        return;
    }
}

#pragma mark - public method of setting title View with Progress
- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    UILabel *souceLabel = self.titleLabels[self.currentIndex];
    UILabel *targetLabel = self.titleLabels[targetIndex];
    souceLabel.textColor = [ESColor secondaryLabelColor];
    targetLabel.textColor = [ESColor labelColor];
    [UIView animateWithDuration:0.15
                     animations:^{
                         self.scrollLine.frame = CGRectMake(targetLabel.frame.origin.x + self.titleW / 2 - 10, souceLabel.frame.origin.y + 22 + 6, self.titleH, 4.0);
                     }];
    self.currentIndex = targetIndex;
}

- (void)showHintPoint:(int)index show:(BOOL)show {
    if (index < 0 || index >= self.hintList.count) {
        return;
    }
    UIView * view = [self.hintList objectAtIndex:index];
    view.hidden = !show;
}


- (void)titleLabelClickedWithView:(UILabel *)labelView {
    if (labelView) {
        if(self.currentIndex == 0 && [labelView.text isEqual:NSLocalizedString(@"home_all", @"全部")]){
            return;
        }
        UILabel *currentLabel = labelView;

        UILabel *oldLabel = self.titleLabels[self.currentIndex];
        self.currentIndex = currentLabel.tag;
        
        currentLabel.textColor = [ESColor labelColor];
        
        oldLabel.textColor = [ESColor secondaryLabelColor];
        CGFloat scrollLineX = currentLabel.tag * self.titleW + self.leftDistance + currentLabel.tag * self.titleSpacing;
        [UIView animateWithDuration:0.15
                         animations:^{
                             self.scrollLine.frame = CGRectMake(scrollLineX + self.titleW / 2 - 10, currentLabel.frame.origin.y + 22 + 6, self.titleH, 4.0);
                         }];
        [self.delegate pageTitletView:self selectedIndex:self.currentIndex];
    } else {
        return;
    }
}
@end
