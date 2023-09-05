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
//  ESV2PhotoVC.m
//  EulixSpace
//
//  Created by qu on 2022/12/14.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESV2PhotoVC.h"
#import "ESColor.h"
#import "ESEmptyView.h"
#import "ESFileDefine.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import "ESMoveCopyView.h"
#import "ESPhotoManger.h"
#import "ESSelectPhotoModel.h"
#import "ESThemeDefine.h"
#import "ESToast.h"
#import "ESTransferManager.h"
#import "ESUploadMetadata.h"
#import "PHAsset+ESTool.h"
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ESCache.h"
#import <YCEasyTool/NSArray+YCTools.h>
#import <YYModel/YYModel.h>
#import "ESBoxManager.h"
#import "ESV2PhotoCell.h"
#import "ESNetworkRequestManager.h"
#import "ESSmartPhotoPreviewVC.h"
#import "UIButton+Extension.h"
#import "ESFileBottomBtnView.h"
#import "ESFileBottomView.h"
#import "ESShareView.h"
#import "ESRecyclePopUpView.h"
#import "ESFileApi.h"
#import "UIView+Status.h"
#import "ESCommonProcessStatusVC.h"

static NSString *v2PhotoCell = @"v2PhotoCell";

@interface ESV2PhotoVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,ESShareViewDelegate,ESFileDelectViewDelegate,UIGestureRecognizerDelegate>

/// 显示相册按钮
@property (nonatomic, strong) UIButton *showAlbumButton;
/// 显示相册按钮
@property (nonatomic, strong) UILabel *showIsUploadLabel;

@property (nonatomic, strong) UILabel *sizePointOutLabel;
/// 取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

/// 确定按钮
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIButton *uploadBtn;

@property (nonatomic, strong) UIButton *setButton;

/// 相册列表
@property (nonatomic, strong) UICollectionView *albumCollectionView;
///// 相册数组
//@property (nonatomic, strong) NSMutableArray<LYFAlbumModel *> *assetCollectionList;

@property (nonatomic, strong) UILabel *uploadPositionLabel;

@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@property (nonatomic, copy) NSString *pathUpLoadUUID;

@property (nonatomic, copy) NSString *localIdentifier;

@property (nonatomic, copy) NSString *asset;

@property (nonatomic, assign) BOOL isUpload;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isLog;

@property (nonatomic, assign) uint64_t maxFileSize;

@property (nonatomic, strong) ESEmptyView *blankSpaceView;

@property (nonatomic, strong) UIView *bottomToolView;

@property (nonatomic, strong) ESFileBottomBtnView *downBtn;

@property (nonatomic, strong) ESShareView *shareView;

@property (nonatomic, strong) ESRecyclePopUpView *popView;

@end

@implementation ESV2PhotoVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self getDataServiceApi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isLog = NO;
    [self setupViewController];
    [self.confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
    self.isSelected = NO;
    self.confirmButton.hidden = YES;

    [self.showAlbumButton setTitle:self.name forState:UIControlStateNormal];

    self.bottomToolView = [self createBottomToolView];
    self.bottomToolView.hidden = YES;
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0.0);
        make.left.mas_equalTo(self.view.mas_left).offset(0.0);
        make.height.mas_equalTo(54.0f + kBottomHeight);
    }];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
#pragma mark - 设置控制器
- (void)setupViewController {
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
//    self.navigationItem.leftBarButtonItem = backItem;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    self.navigationItem.titleView = titleView;
    [titleView addSubview:self.showAlbumButton];

  
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
//  
  
    // 创建一个空白 UIBarButtonItem 对象
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                            target:nil
                                                            action:nil];
    // 将其宽度设置为负值，使其在左侧移动一些
    negativeSpacer.width = -10;

    // 将 Cancel 按钮添加到导航栏左侧
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton]];
    //创建返回按钮
//    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    leftBtn.frame = CGRectMake(0, 0, 25,25);
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [leftBtn addTarget:self action:@selector(leftBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc]initWithCustomView:self.cancelButton];
//    //创建UIBarButtonSystemItemFixedSpace
//    UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    //将宽度设为负值
//    spaceItem.width = -15;
    
//    //将两个BarButtonItem都返回给NavigationItem
//    self.navigationItem.leftBarButtonItems = @[spaceItem,leftBarBtn];
    
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
    self.navigationItem.rightBarButtonItem = confirmItem;
    self.view.backgroundColor = [UIColor whiteColor];
    self.albumCollectionView.hidden = NO;
    self.showIsUploadLabel.hidden = NO;

    [self.blankSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.top.mas_equalTo(self.view.mas_top).offset(180);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
    }];
    
    [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-26);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-43);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(100);
    }];

    [self.uploadPositionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).inset(26);
        make.centerY.mas_equalTo(self.uploadBtn.mas_centerY).inset(26);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(60);
    }];

    [self.uploadPositionTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.uploadPositionLabel.mas_right).inset(10);
        make.centerY.mas_equalTo(self.uploadBtn.mas_centerY).inset(26);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.uploadBtn.mas_left).offset(-20);
    }];

    [self.showIsUploadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).inset(24);
        make.top.mas_equalTo(self.view.mas_top).inset(124);
        make.height.mas_equalTo(20);
    }];

    if ([self.category isEqual:@"photo"]) {
        self.sizePointOutLabel.hidden = YES;
    } else {
        self.sizePointOutLabel.hidden = NO;
    }
}

#pragma mark - Set方法
- (void)setAlbumModel:(ESPhotoModel *)albumModel {
    _albumModel = albumModel;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray<PHAsset *> *newAssets = NSMutableArray.array;
        [albumModel.assets enumerateObjectsUsingBlock:^(PHAsset *_Nonnull asset, NSUInteger idx, BOOL *_Nonnull stop) {
            ESDLog(@"Album showed file: %@-%@", asset.es_originalFilename, @((NSInteger)asset.creationDate.timeIntervalSince1970 * 1000));
            [newAssets addObject:asset];
        }];

        self.albumModel.photoAssets = newAssets;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.albumCollectionView reloadData];
        });
    });
}

- (uint64_t)maxFileSize {
    if (_maxFileSize == 0) {
        _maxFileSize = 300 * kPerByteInKilo * kPerByteInKilo;
    }
    return _maxFileSize;
}

#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ESV2PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:v2PhotoCell forIndexPath:indexPath];
    cell.info = self.dataList[indexPath.row];
 
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(lpGR:)];
    longPressGR.minimumPressDuration = 1;
    longPressGR.view.tag = indexPath.row;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:longPressGR];
    
    if(cell.info.isSelected){
        cell.selectIcon.hidden = NO;
    }else{
        cell.selectIcon.hidden = YES;
    }

    if(self.selectBtn.hidden){
        cell.selectIcon.hidden = NO;
    }
    cell.selectPhotoAction = ^(ESFileInfoPub *info) {
        self.selectBtn.hidden = YES;
        if(!self.cancelButton.selected){
            ESPhotoPreviewWithFiles(self, self.dataList, info.uuid, @"", @"");
        }else{
            NSMutableArray *list = [NSMutableArray new];
            int j = 0;
            for (ESFileInfoPub *infoPub in self.dataList) {
                if(infoPub.uuid == info.uuid){
                    infoPub.isSelected = infoPub.isSelected ? NO:YES;
                }
                if(infoPub.isSelected){
                    j++;
                }

                [list addObject:infoPub];
            }
            
    
            self.dataList = list;
            if(j == self.dataList.count){
                self.confirmButton.selected = YES;
                [self.confirmButton setTitle:TEXT_UNSELECT_ALL forState:UIControlStateSelected];
            }else{
                self.confirmButton.selected = NO;
                [self.confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
            }
            [self.albumCollectionView reloadData];
            int i = 0;
            
            for (ESFileInfoPub *infoPub in self.dataList) {
                if(infoPub.isSelected){
                    i++;
                }
            }
            if(i >= 0){
                self.bottomToolView.hidden = NO;
                if(i == 0){
                    self.bottomToolView.hidden = YES;
                }
                [self.showAlbumButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"),i] forState:UIControlStateNormal];
                [self.cancelButton setImage:nil forState:UIControlStateNormal];
                [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
                self.cancelButton.selected = YES;
            }
        }
    };

    if (self.albumModel.selectRows.count > 0) {
        self.uploadBtn.enabled = YES;
    } else {
        
        self.uploadBtn.enabled = NO;
    }
    return cell;
}

- (void)tryAddSelectItemWithIndex:(NSInteger)index {
    if ([self.category isEqual:@"photo"]) {
        if (self.albumModel.selectRows.count < 100) {
            [self.albumModel.selectRows addObject:@(index)];
        }else{
            [ESToast toastError:@"手动上传，每次最多支持100张"];
        }
    }else{
        if (self.albumModel.selectRows.count < 10) {
            [self.albumModel.selectRows addObject:@(index)];
        }else{
            [ESToast toastError:@"手动上传，每次最多支持10个视频批量上传"];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (ScreenWidth - 4 * 2 - 2 * 3) / 4.f;
    width = floor(width);
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 4, 0, 4);
}

#pragma mark - 点击事件

- (void)showSelectionCountTitle {
    NSString *titleStr;
    NSInteger choiceCount = self.albumModel.selectRows.count;
    if ([self.category isEqual:@"photo"]) {
        titleStr = [NSString stringWithFormat:NSLocalizedString(@"file_image_select", @"已选择%lu个图片"), choiceCount];
    }
    else if ([self.category isEqual:@"video|picture"]) {
        titleStr = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), choiceCount];
    }else {
        titleStr = [NSString stringWithFormat:TEXT_ALBUM_VIDEO_SELECT_COUNT, @(choiceCount)];
    }
    [self.showAlbumButton setTitle:titleStr forState:UIControlStateNormal];
    if (choiceCount == 0) {
        [self.uploadBtn setTitle:[NSString stringWithFormat:TEXT_ALBUM_UPLOAD_NO_COUNT] forState:UIControlStateNormal];
    } else {
        [self.uploadBtn setTitle:[NSString stringWithFormat:TEXT_ALBUM_UPLOAD_WITH_COUNT, @(choiceCount)] forState:UIControlStateNormal];
    }
}

- (void)showAlbum:(UIButton *)button {
    button.selected = !button.selected;
}

/// 返回
- (void)backAction:(UIButton *)button {
    self.isLog = NO;
    [self.showAlbumButton setTitle:self.name forState:UIControlStateNormal];
    self.showAlbumButton.hidden = NO;
    if(self.cancelButton.selected){
        NSMutableArray *list = [NSMutableArray new];
        for (ESFileInfoPub *infoPub in self.dataList) {
            {
                infoPub.isSelected = NO;
                [list addObject:infoPub];
            }
        }
        self.dataList= list;
        self.cancelButton.hidden = NO;
        [self.albumCollectionView reloadData];
        [self.cancelButton setTitle:nil forState:UIControlStateNormal];
        [self.cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        self.bottomToolView.hidden = YES;
        self.cancelButton.selected = NO;
        self.selectBtn.hidden = NO;
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.navigationItem.rightBarButtonItem = confirmItem;
        [self.albumCollectionView reloadData];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// 全选
- (void)confirmAction:(UIButton *)button {
    self.selectBtn.hidden = YES;
    if(button.isSelected){
        
        NSMutableArray *list = [NSMutableArray new];
        [self.showAlbumButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"),(unsigned long)self.dataList.count] forState:UIControlStateNormal];
        [self.cancelButton setImage:nil forState:UIControlStateNormal];
        [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        self.cancelButton.selected  = YES;
        for (ESFileInfoPub *infoPub in self.dataList) {
            {
                infoPub.isSelected = NO;
                [list addObject:infoPub];
            }
        }
        self.dataList= list;
        self.cancelButton.hidden = NO;
        self.confirmButton.selected  = NO;
        self.bottomToolView.hidden = YES;
        [self.albumCollectionView reloadData];
    }else{
        button.selected = YES;
        self.confirmButton.selected  = YES;
        NSMutableArray *list = [NSMutableArray new];
        [self.showAlbumButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"),(unsigned long)self.dataList.count] forState:UIControlStateNormal];
        [self.cancelButton setImage:nil forState:UIControlStateNormal];
        [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        self.cancelButton.selected  = YES;
        for (ESFileInfoPub *infoPub in self.dataList) {
            {
                infoPub.isSelected = YES;
                [list addObject:infoPub];
            }
        }
        self.dataList= list;
        self.cancelButton.hidden = NO;
        self.bottomToolView.hidden = NO;
        [self.albumCollectionView reloadData];
    }

}

#pragma mark - Get方法
- (UICollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 2.f;
        layout.minimumInteritemSpacing = 2.f;
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, ScreenHeight  - kBottomHeight - kStatusBarHeight - kNavBarHeight) collectionViewLayout:layout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor whiteColor];
        _albumCollectionView.scrollEnabled = YES;
        _albumCollectionView.alwaysBounceVertical = YES;
        _albumCollectionView.showsVerticalScrollIndicator = NO;
        _albumCollectionView.showsHorizontalScrollIndicator = NO;
        [_albumCollectionView registerClass:[ESV2PhotoCell class] forCellWithReuseIdentifier:v2PhotoCell];
        [self.view addSubview:_albumCollectionView];
    }

    return _albumCollectionView;
}

- (UIButton *)showAlbumButton {
    if (!_showAlbumButton) {
        _showAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _showAlbumButton.frame = CGRectMake(0, 0, 180, 45);
        [_showAlbumButton setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
        _showAlbumButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:(UIFontWeightMedium)];
        [_showAlbumButton addTarget:self action:@selector(showAlbum:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showAlbumButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, 70, 50);
        //[_cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        [_cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _cancelButton.imageEdgeInsets = UIEdgeInsetsMake(3, -36, 0, 0);
        [_cancelButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.frame = CGRectMake(0, 0, 120, 45);
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
        [_confirmButton setTitle:TEXT_UNSELECT_ALL forState:UIControlStateSelected];
        [_confirmButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        self.uploadBtn.enabled = NO;
    }
    return _confirmButton;
}

- (UIButton *)setButton {
    if (!_setButton) {
        _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _setButton.frame = CGRectMake(0, 0, 100, 45);
        _setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _setButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_setButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
        [_setButton setTitle:TEXT_UNSELECT_ALL forState:UIControlStateSelected];
        [_setButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        self.uploadBtn.enabled = NO;
    }
    return _setButton;
}

- (ESEmptyView *)blankSpaceView {
    if (!_blankSpaceView) {
        _blankSpaceView = [ESEmptyView new];
        _blankSpaceView.hidden = YES;
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = IMAGE_EMPTY_NOFILE;
        item.content = TEXT_FILE_NO_DATA;
        [self.view addSubview:_blankSpaceView];
        [_blankSpaceView reloadWithData:item];
    }
    return _blankSpaceView;
}


- (void)getDataServiceApi {
    ESToast.showLoading(NSLocalizedString(@"waiting_operate", @"请稍后"), self.view);
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                apiName:@"history_record_detail"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID,
                                                                  @"recordId" :self.recordid}
                                                 header:@{}
                                                   body:@{}
                                              modelName:nil
                                           successBlock:^(NSInteger requestId, id  _Nullable response) {
        [ESToast dismiss];
        self.dataList = [NSMutableArray new];
        NSMutableArray * dataList = [NSMutableArray new];
        NSDictionary * dic = response;
        for (NSDictionary *dic1 in dic[@"recordList"]) {
            ESFileInfoPub *model = [ESFileInfoPub yy_modelWithJSON:dic1];
            [dataList addObject:model];
        }
        self.dataList = dataList;
        if(self.dataList.count > 0){
            self.blankSpaceView.hidden = YES;
        }else{
            self.blankSpaceView.hidden = NO;
        }
        [self.albumCollectionView reloadData];
  }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ESToast dismiss];
         [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
        self.blankSpaceView.hidden = NO;
 }];
}


- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.backgroundColor = ESColor.clearColor;
        _selectBtn.frame = CGRectMake(0, 0, 45, 45);
        [_selectBtn setImage:[UIImage imageNamed:@"xuanze"] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectBtn];
    }
    return _selectBtn;
}




-(void)selectBtnAction{
    self.selectBtn.hidden = YES;
    self.isSelected = YES;
    self.confirmButton.hidden = NO;
    self.confirmButton.selected = NO;
    [self.confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
    self.cancelButton.selected = YES;
    [self.cancelButton setImage:nil forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    self.navigationItem.rightBarButtonItem = confirmItem;
    [self.albumCollectionView reloadData];
    [self.showAlbumButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"file_select_zero", @"已选择0个文件")] forState:UIControlStateNormal];
}


-(UIView *)createBottomToolView {
    UIView *bottom = [[UIView alloc]init];
    bottom.backgroundColor = ESColor.systemBackgroundColor;
    self.bottomToolView = bottom;
    [self.view addSubview:bottom];
  //  [[UIApplication sharedApplication].keyWindow addSubview:bottom];
    UIButton *reductionBtn = [[UIButton alloc] initWithFrame:CGRectMake(110, 9, 44, 44)];
    [reductionBtn setTitle:NSLocalizedString(@"file_bottom_share", @"分享") forState:UIControlStateNormal];
    [reductionBtn setImage:IMAGE_FILE_BOTTOM_SHARE forState:UIControlStateNormal];
    [reductionBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [reductionBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [reductionBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:8];
    [reductionBtn addTarget:self action:@selector(shareAct:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:reductionBtn];
    [reductionBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.centerX.equalTo(bottom.mas_centerX);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    
 
    [bottom addSubview:self.downBtn];

    [self.downBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.left.equalTo(bottom.mas_left).offset(70);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    
    UIButton *delectBtn = [[UIButton alloc] initWithFrame:CGRectMake(110 + 44 + 100, 9, 44, 44)];
    [delectBtn setImage:IMAGE_FILE_BOTTOM_DEL forState:UIControlStateNormal];
    [delectBtn setTitle:TEXT_COMMON_DELETE forState:UIControlStateNormal];
    [delectBtn setTitleColor:ESColor.labelColor forState:UIControlStateNormal];
    [delectBtn sc_setLayout:SCEImageTopTitleBootomStyle spacing:2];
    [delectBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:10]];
    [delectBtn addTarget:self action:@selector(delect) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:delectBtn];
    
    [delectBtn mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bottom.mas_top).offset(9);
         make.right.equalTo(bottom.mas_right).offset(-70);
         make.width.mas_equalTo(44);
         make.height.mas_equalTo(44);
     }];
    return bottom;
}


- (ESFileBottomBtnView *)downBtn {
    if (nil == _downBtn) {
        _downBtn = [[ESFileBottomBtnView alloc] init];
        _downBtn.fileBottomBtnLabel.text = TEXT_FILE_BOTTOM_DOWN;
        _downBtn.fileBottomBtnImageView.image = IMAGE_FILE_BOTTOM_DOWN;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickDownBtn:)];
        [_downBtn addGestureRecognizer:tapGesture];
        [self.view addSubview:_downBtn];
    }
    return _downBtn;
}

-(void)didClickDownBtn:(UIButton *)downBtn{
    [ESToast toastSuccess:@"请稍后，将添加至传输列表"];
    NSMutableArray *list = [NSMutableArray new];
    self.bottomToolView.hidden = YES;

      for (ESFileInfoPub *infoPub in self.dataList) {
          if(infoPub.isSelected){
              [list addObject:infoPub];
          }
      }

      
    for (ESFileInfoPub *obj in list) {
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"history_record_add"                                  queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : obj.uuid,
                                                                  @"fileName" : obj.name,
                                                                  @"category" :obj.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
              NSLog(@"%@",response);
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
         }];
        
        [ESTransferManager.manager download:obj
                                   callback:^(NSURL *output, NSError *error){
                                        
                                   }];
        
    }
    [self backAction:nil];
}

-(void)delect{
    self.selectBtn.hidden = NO;
    self.popView.category = @"del";
    self.popView.hidden = NO;
}

-(void)shareAct:(UIButton *)shareBtn{
//    if(!self.shareView){
        self.shareView = [[ESShareView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        self.shareView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        self.shareView.delegate =self;
    NSMutableArray *list = [NSMutableArray new];
    for (ESFileInfoPub *infoPub in self.dataList) {
        {
            infoPub.isSelected = NO;
            [list addObject:infoPub.uuid];
        }
    }

    self.shareView.fileIds = list;
    self.shareView.hidden = NO;
    self.bottomToolView.hidden = YES;

}

- (void)shareView:(ESShareView *)shareView didClicCancelBtn:(UIButton *)button{
    self.bottomToolView.hidden = NO;
}


- (ESRecyclePopUpView *)popView {
    if (!_popView) {
        _popView = [[ESRecyclePopUpView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _popView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _popView.delegate = self;
        _popView.tag = 100104;
        //[self.view.window addSubview:_popView];
        [[UIApplication sharedApplication].keyWindow addSubview:_popView];
          UITapGestureRecognizer *delectActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delectTapGestureAction:)];
          [_popView addGestureRecognizer:delectActionTapGesture];
        _popView.userInteractionEnabled = YES;
    }
    return _popView;
}


// 点击图片改变imageView位置,打印图片信息  分享自己也可封装
- (void)delectTapGestureAction:(UITapGestureRecognizer *)tap {
    self.popView.hidden = YES;
}

- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCancelBtn:(UIButton *_Nullable)button{
    self.popView.hidden = YES;
}


- (void)fileBottomDelectView:(ESFileDelectView *_Nullable)fileBottomDelectView didClickCompleteBtn:(UIButton *_Nullable)button {
    NSMutableArray *list = [NSMutableArray new];
    for (ESFileInfoPub *infoPub in self.dataList) {
        if(infoPub.isSelected){
            [list addObject:infoPub.uuid];
        }
    }
    
    [self.view showLoading:YES message:NSLocalizedString(@"delete_loading_message", @"正在删除")];
    weakfy(self)
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-file-service"
                                                    apiName:@"delete_file"
                                                queryParams:@{}
                                                     header:@{}
                                                       body:@{@"uuids" : list ?: @""}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        [self.view showLoading:NO];
        [self deleteSuccess];
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        strongfy(self)
        [self.view showLoading:NO];
        //show 异步删除进度条
        if ([error.userInfo[@"code"] intValue] == 201) {
            NSDictionary *results = error.userInfo[ESNetworkErrorUserInfoResposeResultKey];
            if ([results[@"results"] isKindOfClass:[NSDictionary class]] && results[@"results"][@"taskId"] != nil) {
                NSString *taskId = results[@"results"][@"taskId"];
                ESCommonProcessStatusVC *processVC = [[ESCommonProcessStatusVC alloc] init];
                processVC.customProcessTitle = NSLocalizedString(@"delete_loading_message", @"正在删除");
                processVC.taskId = taskId;
                
                weakfy(processVC)
                processVC.processUpdateBlock = ^(BOOL success, BOOL isFinished, CGFloat process) {
                    strongfy(processVC)
                    if (isFinished) {
                        [processVC hidden:YES];
                        if (success) {
                            [self deleteSuccess];
                        } else {
                            [self deleteFail];
                        }
                    }
                };
                [processVC showFrom:self];
            }
            return;
        }
        [self deleteFail];
    }];
}

- (void)deleteSuccess {
   [ESToast toastSuccess:NSLocalizedString(@"Delete Success", @"删除成功")];
   [self getDataServiceApi];
   self.popView.hidden = YES;
   UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
   self.navigationItem.rightBarButtonItem = confirmItem;
   [self.cancelButton setTitle:nil forState:UIControlStateNormal];
   [self.cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
   self.cancelButton.selected = NO;
   self.popView.hidden = YES;
   self.bottomToolView.hidden = YES;
   [self.showAlbumButton setTitle:self.name forState:UIControlStateNormal];
}

- (void)deleteFail {
    [ESToast toastError:NSLocalizedString(@"Delete Fail", @"删除失败")];
    [self getDataServiceApi];
    self.popView.hidden = NO;
    self.bottomToolView.hidden = NO;
}

- (void)fileBottomToolView:(ESFileBottomView *)fileBottomToolView didClickDownBtn:(UIButton *)button {
    NSMutableArray *list = [NSMutableArray new];
    for (ESFileInfoPub *infoPub in self.dataList) {
        if(infoPub.isSelected){
            [list addObject:infoPub.uuid];
        }
    }
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:&error];
    if (dictionary) {
        NSNumber *free = dictionary[NSFileSystemFreeSize];
        long long int size = 0;
        for(int i = 0; i < list.count; i++){
            ESFileInfoPub *info = list[i];
            size = size + info.size.unsignedLongLongValue;
        }
        if(free.unsignedLongLongValue < size*2){
            [ESToast toastError:@"手机空间不足"];
            return;
        }
    }
    
    [list enumerateObjectsUsingBlock:^(ESFileInfoPub *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.isDir.boolValue) {
            return;
        }
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"history_record_add"                                  queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : obj.uuid,
                                                                  @"fileName" : obj.name,
                                                                  @"category" :obj.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
         }];
        
        [ESTransferManager.manager download:obj
                                   callback:^(NSURL *output, NSError *error){
                                        
                                   }];
    }];

}
-(void)lpGR:(UILongPressGestureRecognizer *)lpGR
{

    if(self.isLog == NO){
        self.bottomToolView.hidden = NO;
        NSMutableArray *array = [NSMutableArray new];
        ESFileInfoPub *info = self.dataList[lpGR.view.tag];
        int i = 0;
        for (ESFileInfoPub *model in self.dataList) {
            if([model.uuid isEqual:info.uuid]){
                model.isSelected = YES;
            }
            [array addObject:model];
        }
        
        for (ESFileInfoPub *model in self.dataList) {
            if(model.isSelected){
                i++;
            }
        }
        self.selectBtn.hidden = YES;
        self.dataList = array;
        
        [self.albumCollectionView reloadData];

        [self.showAlbumButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"),i] forState:UIControlStateNormal];
        [self.cancelButton setImage:nil forState:UIControlStateNormal];
        [self.cancelButton setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
        self.cancelButton.selected = YES;
        self.confirmButton.selected = NO;
        [self.confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
        UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
        self.navigationItem.rightBarButtonItem = confirmItem;
        self.confirmButton.hidden = NO;
        self.isLog = YES;
        self.selectBtn.hidden = YES;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.cancelButton.selected){
        ESFileInfoPub *info = self.dataList[indexPath.row];
        ESPhotoPreviewWithFiles(self, self.dataList, info.uuid, @"", @"");
    }
}
@end
