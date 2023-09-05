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
//  ESPhotoBasePageVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/24.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESPhotoBasePageVC.h"
#import "ESSmartPhotoListModule.h"
#import "ESBottomSelectedOperateVC.h"
#import "ESSortSheetVC.h"
#import "ESSelectedTopToolVC.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESToast.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"
#import "ESTimeSlider.h"
#import "ESBoxManager.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESSmarPhotoCacheManager.h"
#import "MJRefreshStateHeader.h"
#import "UIScrollView+MJRefresh.h"
#import "ESMJHeader.h"

@interface ESPhotoBasePageVC () <ESSmartPhotoListModuleProtocol, ESSmartPhotoAsyncUpdateProtocol>

@property (nonatomic, strong) UICollectionView *listView;
@property (nonatomic, strong) ESSmartPhotoListModule *listModule;

@property (nonatomic, strong) ESBottomSelectedOperateVC *bottomMoreToolVC;
@property (nonatomic, strong) ESSelectedTopToolVC *topSelecteToolVC;

@property (nonatomic, assign) BOOL sliderIsTracking;
@property (nonatomic, copy) dispatch_block_t timeSliderFadeBlock;
@property (nonatomic, strong) NSIndexPath *lastAccessed;
@property (nonatomic, assign) CGRect firstAccessedRect;

@property (nonatomic, assign) BOOL isSelectedPanSelectStartCell;
@property (nonatomic, strong) NSMutableArray *preSelectIndexList;

@end

@implementation ESPhotoBasePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ESColor.systemBackgroundColor;
    [self setupViews];
    [self setupListModule];
    [self setupListModuleAction];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(boxChanged:) name:@"switchBoxNSNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(boxChanged:) name:kESBoxActiveMessage object:nil];

    [self setupPullRefresh];
    
    [self setupAsyncCallback];
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer shouldBeRequiredToFailByGestureRecognizer:gestureRecognizer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect listRect = self.listView.frame;
    self.timeSlider.frame = CGRectMake(listRect.size.width - 40, listRect.origin.y, 40, listRect.size.height);
    [self.timeSlider setValue:0];
    [self.timeSlider setShowStyle:ESTimeSliderShowStyleHideen];
}

- (void)setupPullRefresh {
    self.listView.mj_header = [ESMJHeader headerWithRefreshingBlock:^{
        [[ESSmartPhotoAsyncManager shared] tryAsyncData];
    }];
}

- (void)removePullRefresh {
    self.listView.mj_header = nil;
}

- (void)setupAsyncCallback {
    [[ESSmartPhotoAsyncManager shared] addAsyncUpdateObserver:self];
    
    if ([[ESSmartPhotoAsyncManager shared] isFirstLoaded]) {
        [self reloadDataByType];
    } else {
        ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    }
}

- (void)setupListModuleAction {
    self.listModule.timeLineType = ESTimelineFrameItemTypeDay;

    __weak typeof (self) weakSelf = self;
    self.listModule.scrollActionUpdateBlock = ^(BOOL isScrollingUp) {
        __strong typeof (weakSelf) self = weakSelf;
        if ([self needShowTimeLineSlider] &&
            !self.sliderIsTracking ) {
            self.timeSliderFadeBlock = nil;
            if (isScrollingUp && self.timeSlider.showStyle == ESTimeSliderShowStyleHideen) {
                [self.timeSlider setShowStyle:ESTimeSliderShowStyleNormal];
            }
          
            if (self.timeSlider.showStyle != ESTimeSliderShowStyleHideen) {
                CGFloat offsetY = self.listView.contentOffset.y;
                CGFloat height = self.listView.frame.size.height;
                CGFloat contentY = self.listView.contentSize.height;
                [self.timeSlider setValue:(offsetY / (contentY - height) * 100 )];
            }
        }
    };
    
    self.listModule.scrollActionEndBlock = ^() {
        __strong typeof (weakSelf) self = weakSelf;
        if (![self needShowTimeLineSlider]) {
            return;
        }
        self.timeSliderFadeBlock = ^() {
            __strong typeof (weakSelf) self = weakSelf;
            [self.timeSlider setShowStyle:ESTimeSliderShowStyleHideen];
        };
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.timeSliderFadeBlock) {
                self.timeSliderFadeBlock();
                self.timeSliderFadeBlock = nil;
            }
        });
    };
}

- (ESTimeSlider *)timeSlider {
    if (!_timeSlider) {
        _timeSlider = [[ESTimeSlider alloc] initWithFrame:CGRectZero];
        __weak typeof (self) weakSelf = self;
        _timeSlider.valueChangedBlock = ^(CGFloat value) {
            __strong typeof (weakSelf) self = weakSelf;
            CGFloat height = self.listView.frame.size.height;
            CGFloat contentY = self.listView.contentSize.height;
            
            CGFloat offsetY =  value / 100  * (contentY - height);
            [self.listView setContentOffset:CGPointMake(0, offsetY)];
           
            NSArray<NSIndexPath *> *indexPaths = [self.listView indexPathsForVisibleSupplementaryElementsOfKind:UICollectionElementKindSectionHeader];
            if (indexPaths.count > 0) {
                __block NSInteger minSection = indexPaths[0].section;
                [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                    minSection = MIN(minSection, indexPath.section);
                }];
                NSString *time = [self.listModule sectionSubTitleWithIndex:minSection];
                NSArray *timeSplitList = [time componentsSeparatedByString:@" "];
                if (timeSplitList.count > 0) {
                    time = timeSplitList[0];
                }
                [self.timeSlider updateTimeText:time];
            }
        };
        _timeSlider.trackingBlock = ^() {
            __strong typeof (weakSelf) self = weakSelf;
            self.sliderIsTracking = YES;
            [self.timeSlider setShowStyle:ESTimeSliderShowStyleTimeLine];
            self.timeSliderFadeBlock = nil;
        };
        
        _timeSlider.endTrackingBlock = ^() {
            __strong typeof (weakSelf) self = weakSelf;
            [self.timeSlider setShowStyle:ESTimeSliderShowStyleNormal];
            self.sliderIsTracking = NO;
            
            self.timeSliderFadeBlock = ^() {
                __strong typeof (weakSelf) self = weakSelf;
                self.sliderIsTracking = NO;
                [self.timeSlider setShowStyle:ESTimeSliderShowStyleHideen];
            };
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.timeSliderFadeBlock) {
                    self.timeSliderFadeBlock();
                    self.timeSliderFadeBlock = nil;
                }
            });
        };
    }
    return _timeSlider;
}

- (BOOL)needShowTimeLineSlider {
    return self.listModule.timeLineType != ESTimelineFrameItemTypeYear &&
           self.listModule.showStyle != ESSmartPhotoPageShowStyleSelecte;
}


- (void)asyncUpdate:(ESSmartPhotoAsyncType)type asyncFinish:(BOOL)asyncFinish hasNewContent:(BOOL)hasNewContent {
    if (hasNewContent) {
        [self reloadDataByType];
        [ESToast dismiss];
    }
    if (asyncFinish) {
        [self.listView.mj_header endRefreshing];
    }
}

- (void)setupListModule {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
    
    __weak typeof (self) weakSelf = self;
    self.listModule.selectedUpdateBlock = ^() {
        __strong typeof (weakSelf) self = weakSelf;
        [self updateShowStyle];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ESSmartPhotoAsyncManager shared] tryAsyncData];
    [self updateShowStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topSelecteToolVC hidden];
    [self.bottomMoreToolVC hidden];
}

- (void)setupViews {
    [self.view addSubview:self.listView];
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(4.0f + kTopHeight);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-4.0f);
    }];
    
    [self.view addSubview:self.timeSlider];
}

- (UICollectionView *)listView {
    if (!_listView) {
        _listView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.listViewLayout];
        _listView.dataSource = self.listModule;
        _listView.delegate = self.listModule;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.backgroundColor = ESColor.systemBackgroundColor;
    }
    return _listView;
}

- (ESSmartPhotoListModule *)listModule {
    if (!_listModule) {
        _listModule = [[self.listModuleClass alloc] initWithListView:_listView];
        _listModule.delegate = self;
        _listModule.parentVC = self;
    }
    return _listModule;
}

- (Class)listModuleClass {
    return ESSmartPhotoListModule.class;
}

- (UICollectionViewFlowLayout *)listViewLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return layout;
}

- (ESBottomSelectedOperateVC *)bottomMoreToolVC {
    if (!_bottomMoreToolVC) {
        _bottomMoreToolVC = [[ESBottomSelectedOperateVC alloc] init];
    }
    return _bottomMoreToolVC;
}

- (ESSelectedTopToolVC *)topSelecteToolVC {
    if (!_topSelecteToolVC) {
        _topSelecteToolVC = [[ESSelectedTopToolVC alloc] init];
        _topSelecteToolVC.limitSelectStyle = YES;

        __weak typeof (self) weakSelf = self;
        _topSelecteToolVC.cancelActionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            [self.topSelecteToolVC hidden];
            [self.bottomMoreToolVC hidden];
            [self.listModule cleanAllSeleted];
            [self.listModule setShowStyle:ESSmartPhotoPageShowStyleNormal];
            [self updateShowStyle];
            [self topSelecteToolCancel];
        };
        
        _topSelecteToolVC.selecteAllActionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            if ([self.topSelecteToolVC isAllSelected]) {
                [self.listModule selectedAll];
                [self updateShowStyle];
            } else {
                [self.listModule cleanAllSeleted];
                [self updateShowStyle];
            }
        };
    }
    return _topSelecteToolVC;
}

- (void)topSelecteToolCancel {
    
}

- (void)boxChanged:(NSNotification *)notification {
//    [self reloadDataByType];
}

- (void)reloadDataByType {
    
}

- (void)tryAsyncData {
    [[ESSmartPhotoAsyncManager shared] tryAsyncData];
}

- (void)tryAsyncDataWithRename:(NSString *)newName uuid:(NSString *)uuid {
    ESPicModel *pic = [[ESSmartPhotoDataBaseManager shared] getPicByUuid:uuid];
    if (!pic) {
        return;
    }
    NSString *oldPath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
    
    pic.name = newName;
    if ([[ESSmartPhotoDataBaseManager shared] insertOrUpdatePicsToDB:@[pic]]) {
        NSString *newPath = [ESSmarPhotoCacheManager cachePathWithPic:pic];
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    }
}


#pragma mark - showStyle
- (void)finishActionAndStaySelecteStyleWithCleanSelected {
    [self.listModule cleanAllSeleted];
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
}

- (void)finishActionAndStaySelecteStyle {
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
    [self updateShowStyle];
}

- (void)finishActionShowNormalStyleWithCleanSelected {
    [self.listModule cleanAllSeleted];
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
    [self updateShowStyle];
}

- (void)showViewNormalStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.listModule.showStyle = ESSmartPhotoPageShowStyleNormal;
}

- (void)showSelectStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
}

- (void)showSelectedStyle {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat toolHeight = 50 + kBottomHeight;
    self.view.frame = CGRectMake(0, 0, size.width, size.height - toolHeight);
    self.listModule.showStyle = ESSmartPhotoPageShowStyleSelecte;
}

- (void)showSelectToolView {
    [self.topSelecteToolVC showFrom:self];
    [self.topSelecteToolVC updateSelectdCount:0 isAllSelected:NO];
}

- (void)actionSheetDidSelectCancel:(ESBaseActionSheetVC *)actionSheet {
    
}

#pragma mark -
- (void)didSelectPic:(ESPicModel *)pic indexPath:(NSIndexPath *)index {
    [self updateShowStyle];
}

- (void)updateShowStyle {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        [self showViewNormalStyle];
        [self.listModule cleanAllSeleted];
        [self updateSelectedToolStatus];
        return;
    }
    NSInteger selectedCount = [self.listModule selectedCount];
    if (selectedCount > 0) {
        [self showSelectedStyle];
    } else {
        [self showSelectStyle];
    }
    [self updateSelectedToolStatus];
}

- (void)updateSelectedToolStatus {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        [self.topSelecteToolVC updateSelectdCount:0 isAllSelected:NO];
        [self.topSelecteToolVC hidden];
        [self.bottomMoreToolVC hidden];
        return;
    }
    
    NSInteger selectedCount = [self.listModule selectedCount];
    if (selectedCount > 0) {
        [self.topSelecteToolVC showFrom:self];
        [self.bottomMoreToolVC showFrom:self];
    } else {
        [self.topSelecteToolVC showFrom:self];
        [self.bottomMoreToolVC hidden];
    }
    
    [self updateTopSelectedStatus];
    [self updateBottomSeletedStatus];
}
- (void)updateTopSelectedStatus {
    BOOL isAllSelected = [self.listModule isAllSelected];
    [self.topSelecteToolVC updateSelectdCount:[self.listModule selectedCount] isAllSelected:isAllSelected];
}

- (void)updateBottomSeletedStatus {
    NSArray *uuidList = [self.listModule.selectedMap allKeys];
    NSArray<ESPicModel *> *picList = [[ESSmartPhotoDataBaseManager shared] getPicByUuids:uuidList];
    
    [self.bottomMoreToolVC updateSelectedList:picList];
}

#pragma mark - Empty

- (UIImage *)backgroudImageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_backgroud"];
}
- (UIImage *)imageForEmpty {
    return [UIImage imageNamed:@"smart_photo_empty_icon"];
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"file_none_photos", @"您还没有任何图片哦");
}

- (void)didBecomeActive:(id _Nullable)sender {
    if (self.viewLoaded && self.view.window) {
//        [self updateShowStyle];
    }
}

- (UIColor *)customBackgroudColor {
    return ESColor.systemBackgroundColor;
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.listModule.showStyle == ESSmartPhotoPageShowStyleNormal) {
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
           CGPoint  panSelectStartPoint = [gestureRecognizer locationInView:self.listView];
           NSIndexPath *indexPath = [self.listView indexPathForItemAtPoint:panSelectStartPoint];
            _isSelectedPanSelectStartCell = [self.listModule isCellItemSelectedWithIndex:indexPath];
            _firstAccessedRect = [self.listView cellForItemAtIndexPath:indexPath].frame;
            _preSelectIndexList = [NSMutableArray array];
        return;

       }
    
    float pointerX = [gestureRecognizer locationInView:self.listView].x;
    float pointerY = [gestureRecognizer locationInView:self.listView].y;

    for (UICollectionViewCell *cell in self.listView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [self.listView indexPathForCell:cell];
            if (_lastAccessed != touchOver) {
                CGRect lastAccessedRect = [self.listView cellForItemAtIndexPath:touchOver].frame;
                
                float canAccessCellSX = MIN(CGRectGetMinX(lastAccessedRect), CGRectGetMinX(_firstAccessedRect)) - 1.0;
                float canAccessCellEX = MAX(CGRectGetMaxX(lastAccessedRect), CGRectGetMaxX(_firstAccessedRect)) + 1.0;
                float canAccessCellSY = MIN(CGRectGetMinY(lastAccessedRect), CGRectGetMinY(_firstAccessedRect)) - 1.0;
                float canAccessCellEY = MAX(CGRectGetMaxY(lastAccessedRect), CGRectGetMaxY(_firstAccessedRect)) + 1.0;
                
                NSMutableArray *newSelectIndexList = [NSMutableArray array];
                for (UICollectionViewCell *cell in self.listView.visibleCells) {
                    NSIndexPath *index = [self.listView indexPathForCell:cell];
                    if (CGRectGetMinX(cell.frame) >= canAccessCellSX &&
                        CGRectGetMaxX(cell.frame) <= canAccessCellEX &&
                        CGRectGetMinY(cell.frame) >= canAccessCellSY &&
                        CGRectGetMaxY(cell.frame) <= canAccessCellEY ) {
                        [self.listModule collectionView:self.listView touchItemAtIndexPath:index didSelect:!_isSelectedPanSelectStartCell];
                        
                        [newSelectIndexList addObject:index];
                    } else if ([_preSelectIndexList containsObject:index]) {
                        [self.listModule collectionView:self.listView touchItemAtIndexPath:index didSelect:_isSelectedPanSelectStartCell];
                    }
                }
                
                _preSelectIndexList = newSelectIndexList;
                _lastAccessed = touchOver;
            }
        }
    }
    
    if ( pointerY >= (self.listView.contentOffset.y + self.listView.frame.size.height - 100) &&
        pointerY <= self.listView.contentOffset.y + self.listView.frame.size.height &&
        pointerY < self.listView.contentSize.height) {
        weakfy(self)
        [UIView animateWithDuration:0.1 animations:^{
            strongfy(self)
            self.listView.contentOffset =  CGPointMake(self.listView.contentOffset.x, MIN(self.listView.contentOffset.y + 16, self.listView.contentSize.height - self.listView.frame.size.height));

        }];
    }
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _preSelectIndexList = nil;
        self.listView.scrollEnabled = YES;
    }
}

@end
