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
//  ESPhotoCollectionVC.m
//  EulixSpace
//
//  Created by qu on 2021/9/5.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESPhotoCollectionVC.h"
#import "ESColor.h"
#import "ESEmptyView.h"
#import "ESFileDefine.h"
#import "ESGlobalMacro.h"
#import "ESImageDefine.h"
#import "ESMoveCopyView.h"
#import "ESPhotoCollectionCell.h"
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
#import "ESCommonToolManager.h"

static NSString *photoCollectionViewCell = @"photoCollectionViewCell";

@interface ESPhotoCollectionVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ESPhotoCollectionCellDelegate, ESMoveCopyViewDelegate>

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

/// 相册列表
@property (nonatomic, strong) UICollectionView *albumCollectionView;
///// 相册数组
//@property (nonatomic, strong) NSMutableArray<LYFAlbumModel *> *assetCollectionList;

@property (nonatomic, strong) UILabel *uploadPositionLabel;

@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

@property (nonatomic, strong) ESMoveCopyView *movecopyView;

@property (nonatomic, copy) NSString *pathUpLoadUUID;

@property (nonatomic, copy) NSString *localIdentifier;

@property (nonatomic, copy) NSString *asset;

@property (nonatomic, assign) BOOL isUpload;

@property (nonatomic, assign) uint64_t maxFileSize;

@property (nonatomic, strong) ESEmptyView *blankSpaceView;

@property (nonatomic, assign) CGPoint panGestureStartPoint;

@property (strong , nonatomic) NSIndexPath * m_lastAccessed;
@end

@implementation ESPhotoCollectionVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
    [self.confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
    if ([self.category isEqual:@"video"]) {
        [self.showAlbumButton setTitle:NSLocalizedString(@"video_select_zero", @"已选择0个视频") forState:UIControlStateNormal];
    } else if ([self.category isEqual:@"video|picture"]) {
        [self.showAlbumButton setTitle:NSLocalizedString(@"file_select_zero", @"已选择0个文件")  forState:UIControlStateNormal];
    }else {
        
        [self.showAlbumButton setTitle:NSLocalizedString(@"file_Picture_select_zero", @"已选择0个图片") forState:UIControlStateNormal];
    }
    if ([self.category isEqual:@"photo"]) {
        self.sizePointOutLabel.hidden = YES;
    } else {
        self.sizePointOutLabel.hidden = NO;
    }
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    // 设置 delaysTouchesBegan 属性，优先响应手势
    panGesture.delaysTouchesBegan = YES;
    [self.albumCollectionView addGestureRecognizer:panGesture];
}




- (void)panGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gestureRecognizer translationInView:self.albumCollectionView];
            if (fabs(translation.y) < fabs(translation.x)) {
                
                float pointerX = [gestureRecognizer locationInView:self.albumCollectionView].x;
                NSLog(@"pointerX = %f",pointerX);
                float pointerY = [gestureRecognizer locationInView:self.albumCollectionView].y;
                for(ESPhotoCollectionCell* cell1 in self.albumCollectionView.visibleCells) {
                    float cellLeftTop = cell1.frame.origin.x;
                    NSLog(@"cellLeftTop = %f",cellLeftTop);
                    float cellRightTop = cellLeftTop + cell1.frame.size.width;
                    float cellLeftBottom = cell1.frame.origin.y;
                    float cellRightBottom = cellLeftBottom + cell1.frame.size.height;

                    if (pointerX >= cellLeftTop && pointerX <= cellRightTop && pointerY >= cellLeftBottom && pointerY <= cellRightBottom) {
                        NSIndexPath* touchOver = [self.albumCollectionView indexPathForCell:cell1];
                        if (self.m_lastAccessed != touchOver) {
                            if (cell1.isSelected) {
                                // 取消
                                [self deselectCellForCollectionView:self.albumCollectionView atIndexPath:touchOver];
                            }
                            else
                            {
                                // 选中
                                [self selectCellForCollectionView:self.albumCollectionView atIndexPath:touchOver];
                            }
                        }
                        self.m_lastAccessed = touchOver;
                    }
                }
                [self.albumCollectionView reloadData];

                if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                    self.m_lastAccessed = nil;
                    self.albumCollectionView.scrollEnabled = YES;
                }
            } 
            break;
        }

        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ESPhotoCollectionCell* cell = (ESPhotoCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];

    cell.isSelected = YES;

   [self tryAddSelectItemWithIndex:indexPath.row];
   [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}


/*Cell已经选择时回调*/
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ESPhotoCollectionCell* cell = (ESPhotoCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
    
    if ([self.albumModel.selectRows containsObject:@(indexPath.row)]) {
        [self.albumModel.selectRows removeObject:@(indexPath.row)];
    }
        
}
/*Cell未选择时回调*/
-(void)selectCellForCollectionView:(UICollectionView*)collection atIndexPath:(NSIndexPath*)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}


-(void)deselectCellForCollectionView:(UICollectionView*)collection atIndexPath:(NSIndexPath*)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
    
}


#pragma mark - 设置控制器
- (void)setupViewController {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    self.navigationItem.leftBarButtonItem = backItem;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    self.navigationItem.titleView = titleView;
    [titleView addSubview:self.showAlbumButton];

    UIBarButtonItem *confirmItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    self.navigationItem.rightBarButtonItem = confirmItem;
    self.view.backgroundColor = [UIColor whiteColor];
    //self.confirmButton.hidden = YES;
    self.albumCollectionView.hidden = NO;
    self.showIsUploadLabel.hidden = NO;

    [self addSwitch];

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

    if ([ESCommonToolManager isEnglish]) {
        [self.uploadPositionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).inset(26);
            make.centerY.mas_equalTo(self.uploadBtn.mas_centerY).inset(26);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(120);
        }];
    }else{
        [self.uploadPositionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).inset(26);
            make.centerY.mas_equalTo(self.uploadBtn.mas_centerY).inset(26);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(60);
        }];
    }


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

//    [self.sizePointOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.showIsUploadLabel.mas_right).inset(8);
//        make.top.mas_equalTo(self.view.mas_top).inset(126);
//        make.height.mas_equalTo(17);
//        make.width.mas_equalTo(200);
//    }];


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
//            if (asset.es_fileSize > self.maxFileSize) {
//                ESDLog(@"Album skipped file: %@/%@, because file size is too large.", asset.creationDate, [asset es_originalFilename]);
//                return;
//            }
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
    if (!self.isUpload) {
        //  return self.albumModel.assets.count;
        return self.albumModel.photoAssets.count;
    } else {
        return self.albumModel.assetsUpload.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCollectionViewCell forIndexPath:indexPath];

    cell.row = indexPath.row;
    if (!self.isUpload) {
        cell.asset = self.albumModel.photoAssets[indexPath.row];
    } else {
        cell.asset = self.albumModel.assetsUpload[indexPath.row];
    }
    cell.delegate = self;
    [cell loadImage:indexPath];
    cell.isSelected = [self.albumModel.selectRows containsObject:@(indexPath.row)];

    weakfy(self);

    cell.selectPhotoAction = ^(PHAsset *asset) {
        strongfy(self);
        self.confirmButton.hidden = NO;
        // [self.cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        if ([self.albumModel.selectRows containsObject:@(indexPath.row)]) {
            [self.albumModel.selectRows removeObject:@(indexPath.row)];
        } else {
            [self tryAddSelectItemWithIndex:indexPath.row];
        }
        [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
  
    };
    [ESPhotoManger standardPhotoManger].choiceCount = self.albumModel.selectRows.count;
    self.confirmButton.selected = self.albumModel.selectRows.count == self.albumModel.assetsUpload.count;
    if (self.albumModel.selectRows.count == 0) {
        [self.cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        [self.cancelButton setTitle:nil forState:UIControlStateNormal];
        self.cancelButton.selected = NO;
    } else {
        [self.cancelButton setImage:nil forState:UIControlStateNormal];
        [self.cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        self.cancelButton.selected = YES;
    }

    [self showSelectionCountTitle];
    if (self.isUpload) {
        if (self.albumModel.selectRows.count == self.albumModel.assetsUpload.count) {
            self.confirmButton.selected = YES;
        } else {
            self.confirmButton.selected = NO;
        }
    } else {
        if (self.albumModel.selectRows.count == self.albumModel.assets.count) {
            self.confirmButton.selected = YES;
        } else {
            self.confirmButton.selected = NO;
        }
    }
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
        titleStr = [NSString stringWithFormat:NSLocalizedString(@"album_image_select_count", @"已选择0个图片"), @(choiceCount)];
    }
    else if ([self.category isEqual:@"video|picture"]) {
        titleStr = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), choiceCount];
    }else {
        titleStr = [NSString stringWithFormat:NSLocalizedString(@"album_video_select_count", @"已选择%@张视频"), @(choiceCount)];
    }
    [self.showAlbumButton setTitle:titleStr forState:UIControlStateNormal];
    if (choiceCount == 0) {
        [self.uploadBtn setTitle:[NSString stringWithFormat:TEXT_ALBUM_UPLOAD_NO_COUNT] forState:UIControlStateNormal];
    } else {
        [self.uploadBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"album_upload_with_count", @"上传(%@)"), @(choiceCount)] forState:UIControlStateNormal];
    }
}

- (void)showAlbum:(UIButton *)button {
    button.selected = !button.selected;
}
/// 返回
- (void)backAction:(UIButton *)button {
    [ESPhotoManger standardPhotoManger].choiceCount = 0;
    [self.albumModel.selectRows removeAllObjects];
    if (button.selected) {
        [self.albumModel.selectRows removeAllObjects];
    } else {
        [self.albumModel.selectRows removeAllObjects];
    }
    [self.albumCollectionView reloadData];

    if (!self.cancelButton.selected) {
        [self.navigationController popViewControllerAnimated:YES];

        if ([self.category isEqual:@"photo"]) {
            [self.showAlbumButton setTitle:NSLocalizedString(@"file_Picture_select_zero", @"已选择0个图片") forState:UIControlStateNormal];
        } else if ([self.category isEqual:@"video|picture"]) {
            [self.showAlbumButton setTitle:NSLocalizedString(@"file_select_zero", @"已选择0个文件")  forState:UIControlStateNormal];
        }
        else {
            [self.showAlbumButton setTitle:NSLocalizedString(@"video_select_zero", @"已选择0个视频") forState:UIControlStateNormal];
        }

     
    } else {
        [self.cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        [self.cancelButton setTitle:nil forState:UIControlStateNormal];
        UIButton *btn = [UIButton new];
        btn.selected = YES;
        [self confirmAction:btn];
    }
}
/// 全选
- (void)confirmAction:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.albumModel.selectRows removeAllObjects];
        if (!self.isUpload) {
            if ([self.category isEqual:@"photo"] || [self.category isEqual:@"video|picture"]) {
                if(self.albumModel.assets.count > 100){
                    for(int i = 0; i < 100; i++){
                        [self.albumModel.selectRows addObject:@(i)];
                    }
                }else{
                    [self.albumModel.assets enumerateObjectsUsingBlock:^(PHAsset *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        [self.albumModel.selectRows addObject:@(idx)];
                    }];
                }
            }else{
                if(self.albumModel.assets.count > 10){
                    for(int i = 0; i < 10; i++){
                        [self.albumModel.selectRows addObject:@(i)];
                    }
                }else{
                    [self.albumModel.assets enumerateObjectsUsingBlock:^(PHAsset *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        [self.albumModel.selectRows addObject:@(idx)];
                    }];
                }
            }
        } else {
            
            [self.albumModel.assetsUpload enumerateObjectsUsingBlock:^(PHAsset *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([self.category isEqual:@"photo"] || [self.category isEqual:@"video|picture"]) {
                    if (self.albumModel.assetsUpload.count > 100) {
                        for(int i = 0; i < 100; i++){
                            [self.albumModel.selectRows addObject:@(i)];
                        }
                    }else{
                        [self.albumModel.selectRows addObject:@(idx)];
                    }
                }else{
                    if (self.albumModel.assetsUpload.count > 10) {
                        for(int i = 0; i < 10; i++){
                            [self.albumModel.selectRows addObject:@(i)];
                        }
                    }else{
                        [self.albumModel.selectRows addObject:@(idx)];
                    }
                }
            }];
        }
        [self.cancelButton setImage:nil forState:UIControlStateNormal];
        [self.cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        self.cancelButton.selected = YES;
    } else {
        self.confirmButton.selected = NO;
        [self.cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        [self.cancelButton setTitle:nil forState:UIControlStateNormal];
        self.cancelButton.selected = NO;
        [self.albumModel.selectRows removeAllObjects];
    }

    [ESPhotoManger standardPhotoManger].choiceCount = self.albumModel.selectRows.count;
    [self showSelectionCountTitle];
    [self.albumCollectionView reloadData];
}

#pragma mark - Get方法
- (UICollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 2.f;
        layout.minimumInteritemSpacing = 2.f;
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 169, ScreenWidth, ScreenHeight - 269) collectionViewLayout:layout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor whiteColor];
        _albumCollectionView.scrollEnabled = YES;
        _albumCollectionView.alwaysBounceVertical = YES;
        _albumCollectionView.showsVerticalScrollIndicator = NO;
        _albumCollectionView.showsHorizontalScrollIndicator = NO;
        [_albumCollectionView registerClass:[ESPhotoCollectionCell class] forCellWithReuseIdentifier:photoCollectionViewCell];
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
        _cancelButton.frame = CGRectMake(0, 0, 60, 50);
        //[_cancelButton setTitle:TEXT_CANCEL forState:UIControlStateNormal];
        [_cancelButton setImage:IMAGE_PHOTO_BACK forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.frame = CGRectMake(0, 0, 90, 45);
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmButton setTitle:TEXT_SELECT_ALL forState:UIControlStateNormal];
        [_confirmButton setTitle:TEXT_UNSELECT_ALL forState:UIControlStateSelected];
        [_confirmButton setTitleColor:ESColor.primaryColor forState:UIControlStateNormal];
        self.uploadBtn.enabled = NO;
    }
    return _confirmButton;
}

- (UILabel *)showIsUploadLabel {
    if (!_showIsUploadLabel) {
        _showIsUploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 124, 84, 20)];
        _showIsUploadLabel.textColor = ESColor.labelColor;
        _showIsUploadLabel.text = NSLocalizedString(@"Only Show not Uploaded", @"仅显示未上传");
        _showIsUploadLabel.textAlignment = NSTextAlignmentLeft;
        _showIsUploadLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_showIsUploadLabel];
    }
    return _showIsUploadLabel;
}

- (UILabel *)sizePointOutLabel {
    if (!_sizePointOutLabel) {
        _sizePointOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(118, 126, 105, 17)];
        _sizePointOutLabel.textColor = ESColor.grayColor;
        _sizePointOutLabel.text = @"单个文件最大300M";
        _sizePointOutLabel.textAlignment = NSTextAlignmentLeft;
        _sizePointOutLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
   //     [self.view addSubview:_sizePointOutLabel];
    }
    return _sizePointOutLabel;
}

- (void)addSwitch {
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth - 50 - 30, 124, 50, 30)];
    [self.view addSubview:mySwitch];
    [mySwitch addTarget:self
                  action:@selector(switched:)
        forControlEvents:UIControlEventValueChanged];
    [mySwitch setOn:YES];
    [self switched:mySwitch];
}

- (UILabel *)uploadPositionLabel {
    if (!_uploadPositionLabel) {
        _uploadPositionLabel = [[UILabel alloc] init];
        _uploadPositionLabel.textColor = ESColor.labelColor;
        _uploadPositionLabel.text = NSLocalizedString(@"file_upload_place", @"上传位置:");
        _uploadPositionLabel.textAlignment = NSTextAlignmentLeft;
        _uploadPositionLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_uploadPositionLabel];
    }
    return _uploadPositionLabel;
}

- (UILabel *)uploadPositionTextLabel {
    if (!_uploadPositionTextLabel) {
        _uploadPositionTextLabel = [[UILabel alloc] init];
        _uploadPositionTextLabel.textColor = ESColor.primaryColor;
        _uploadPositionTextLabel.textAlignment = NSTextAlignmentLeft;
        _uploadPositionTextLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        [self.view addSubview:_uploadPositionTextLabel];
        UITapGestureRecognizer *tapRecognizerWeibo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPathClick:)];
        _uploadPositionTextLabel.userInteractionEnabled = YES;
        NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path"];

        NSString *mySpace = NSLocalizedString(@"me_space", @"我的空间");
        if (path.length > 0) {
            _uploadPositionTextLabel.text = [NSString stringWithFormat:@"%@%@",mySpace,path];
        } else {
            _uploadPositionTextLabel.text = NSLocalizedString(@"me_space", @"我的空间");
        }

        [_uploadPositionTextLabel addGestureRecognizer:tapRecognizerWeibo];
        

        self.dir = path;
    }
    return _uploadPositionTextLabel;
}

- (UIButton *)uploadBtn {
    if (nil == _uploadBtn) {
        _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_uploadBtn addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
        [_uploadBtn setTitle:TEXT_ALBUM_UPLOAD_NO_COUNT forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:ESColor.lightTextColor forState:UIControlStateNormal];
        [_uploadBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
        [_uploadBtn.layer setCornerRadius:10.0]; //设置矩圆角半径
        _uploadBtn.layer.masksToBounds = YES;
        [self.view addSubview:_uploadBtn];
        [self.view bringSubviewToFront:_uploadBtn];
    }
    return _uploadBtn;
}

- (void)selectPathClick:(UITapGestureRecognizer *)tag {
    self.movecopyView.hidden = NO;
    self.movecopyView.uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"select_up_path_uuid"];
    self.movecopyView.selectNum = [ESPhotoManger standardPhotoManger].choiceCount;
    //self.movecopyView.name = self.uploadPositionTextLabel.text;
    NSArray *array = [self.uploadPositionTextLabel.text componentsSeparatedByString:@"/"];
    if (array.count > 0) {
        NSString *str = array[array.count - 1];
        if (str.length < 1) {
            self.movecopyView.name = array[array.count - 2];
        } else {
            self.movecopyView.name = array[array.count - 1];
        }
    }
}

- (ESMoveCopyView *)movecopyView {
    if (!_movecopyView) {
        _movecopyView = [[ESMoveCopyView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _movecopyView.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5];
        _movecopyView.delegate = self;

        [self.view.window addSubview:_movecopyView];
    }
    return _movecopyView;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClicCancelBtn:(UIButton *_Nonnull)button {
    self.movecopyView.hidden = YES;
}

- (void)fileMoveCopyView:(ESMoveCopyView *_Nullable)fileBottomToolView didClickCompleteBtnWithPath:(NSString *_Nullable)pathName selectUUID:(NSString *_Nullable)uuid category:(NSString *)category {
    self.pathUpLoadUUID = uuid;
    self.dir = pathName;
    self.uploadPositionTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"me_space%@", @"我的空间%@"), pathName];
    self.movecopyView.hidden = YES;
}

- (void)uploadAction:(UIButton *)btn {
    self.uploadBtn.enabled = NO;
    [ESToast toastSuccess:NSLocalizedString(@"Please add to the transfer list later", @"请稍后，将添加至传输列表")];
    if (self.dir.length < 1) {
        self.dir = @"/";
    }
    NSString *dir = [self.dir substringFromIndex:self.dir.length - 1];
    if (![dir isEqual:@"/"]) {
        self.dir = [NSString stringWithFormat:@"%@/", self.dir];
    }
    if (!self.isUpload) {
    
        if ([ESPhotoManger standardPhotoManger].choiceCount > 0) {
            for (NSNumber *row in self.albumModel.selectRows) {
                if (row.integerValue < self.albumModel.assets.count) {
                    ESSelectPhotoModel *photoModel = [[ESSelectPhotoModel alloc] init];
                    __weak typeof(photoModel) weakPhotoModel = photoModel;
                  
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            photoModel.getPictureAction = ^{
                                if(![self isUploadingPhotoID:weakPhotoModel.asset.localIdentifier]){
                                ESUploadMetadata *metadata = [ESUploadMetadata fromAsset:weakPhotoModel.asset type:kESUploadMetadataTypeTransfer];
                                metadata.folderPath = self.dir;
                                metadata.multipart = YES;
                                metadata.category = self.category;
                                metadata.source = @"video";
                                metadata.photoNum = self.photoNumer;
                                metadata.photoID = weakPhotoModel.asset.localIdentifier;
                                if (![self.category isEqual:@"photo"]) {
                                    
                                }
                                    [ESTransferManager.manager upload:metadata
                                                             callback:^(ESRspUploadRspBody *result, NSError *error) {
                                        if(error){
                                             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                            return;
                                        }
                                    }];
                               // [self savePhotoData:weakPhotoModel.asset.localIdentifier];
                                }
                            };
                           });
                   // [ESToast toastSuccess:NSLocalizedString(@"Please add to the transfer list later", @"请稍后，将添加至传输列表")];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didHiddenSelfNSNotification" object:nil];
                    photoModel.asset = self.albumModel.assets[row.integerValue];
                }
            }
        }
    } else {
        if ([ESPhotoManger standardPhotoManger].choiceCount > 0) {
            for (NSNumber *row in self.albumModel.selectRows) {
                if (row.integerValue < self.albumModel.assetsUpload.count) {
                    ESSelectPhotoModel *photoModel = [[ESSelectPhotoModel alloc] init];
                    __weak typeof(photoModel) weakPhotoModel = photoModel;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    photoModel.getPictureAction = ^{
                        if(![self isUploadingPhotoID:weakPhotoModel.asset.localIdentifier]){
                        PHAsset *asset = self.albumModel.assetsUpload[row.integerValue];
                        ESDLog(@"[Upload] getPictureAction :%@", asset.es_originalFilename);
                        ESUploadMetadata *metadata = [ESUploadMetadata fromAsset:asset type:kESUploadMetadataTypeTransfer];
                        metadata.folderPath = self.dir;
                        metadata.category = self.category;
                        metadata.source = @"video";
                        metadata.photoNum = self.photoNumer;
                        metadata.photoID = weakPhotoModel.asset.localIdentifier;
                        [ESTransferManager.manager upload:metadata
                                                 callback:^(ESRspUploadRspBody *result, NSError *error) {
                            if(error){
                                 [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                return;
                            }
                        }];
        
                                }
                            };
                    });
               
//                    [ESToast toastSuccess:@"请稍后，将添加至传输列表"];
                  
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"didHiddenSelfNSNotification" object:nil];
                    photoModel.asset = self.albumModel.assetsUpload[row.integerValue];
                }
            }
        }
    }
}

- (void)switched:(UISwitch *)sender {
    UIButton *btn =  [UIButton new];
    self.cancelButton.selected = YES;
    self.uploadBtn.enabled = NO;
    [self backAction:btn];

    if ([self.category isEqual:@"photo"]) {
        [self.showAlbumButton setTitle:NSLocalizedString(@"file_Picture_select_zero", @"已选择0个图片") forState:UIControlStateNormal];
    } else if ([self.category containsString:@"video"]) {
        [self.showAlbumButton setTitle:NSLocalizedString(@"video_select_zero", @"已选择0个视频") forState:UIControlStateNormal];
    } else {
        [self.showAlbumButton setTitle:NSLocalizedString(@"file_select_zero", @"已选择0个文件")  forState:UIControlStateNormal];
    }
    [self.albumModel.selectRows removeAllObjects];
    
    
    if (sender.on) {
        self.isUpload = YES;
        /// 已上传/未上传
        NSMutableArray *upLoadArray = [NSMutableArray new];
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadPhotoIDDic"];
        NSString *str = [NSString stringWithFormat:@"%@",self.photoNumer];
        NSArray *uploadPhotoIDArray  = dic[str];
        for (PHAsset *asset in self.albumModel.assets) {
            [upLoadArray addObject:asset];
        }
        for (PHAsset *asset in self.albumModel.assets) {
            for (int i = 0; i < uploadPhotoIDArray.count; i++) {
                if (uploadPhotoIDArray.count > 0) {
                        NSString *localIdentifier = uploadPhotoIDArray[i];
                        if([asset.localIdentifier isEqual:localIdentifier]){
                            [upLoadArray removeObject:asset];
                        }
                    }
                }
        }
        self.albumModel.assetsUpload = upLoadArray;
    } else {
        self.isUpload = NO;
    }
    if (sender.on) {
        if (self.albumModel.assetsUpload.count < 1) {
            self.confirmButton.hidden = YES;
            self.blankSpaceView.hidden = NO;
        } else {
            self.confirmButton.hidden = NO;
            self.blankSpaceView.hidden = YES;
        }
    } else {
        self.blankSpaceView.hidden = YES;
        self.confirmButton.hidden = NO;
    }

    [self.albumCollectionView reloadData];
}

- (void)plistWriteDate:(NSMutableDictionary *)writeDate {
    NSString *plistPath = [self getPath];
    [writeDate writeToFile:plistPath atomically:YES];
}

- (NSDictionary *)getPlistData {
    NSString *plistPath = [self getPath];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return dic;
}

- (NSString *)getPath {
    // 获取应用程序沙盒的Documents目录
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // 也可以这样添加后缀，plistName是文件名
    NSString *plistName = [[NSString stringWithFormat:@"ESFileUploadComparison"] stringByAppendingPathExtension:@"plist"];
    // 得到完整的文件路径
    NSString *plistPath = [documentPath stringByAppendingPathComponent:plistName];
    return plistPath;
}

//- (void)savePhotoData:(NSString *)localIdentifier {
//    NSDictionary *dic = [self getPlistData];
//    NSMutableDictionary *mulDic;
//    if (localIdentifier) {
//        if (dic) {
//            mulDic = [dic mutableCopy];
//        } else {
//            mulDic = [NSMutableDictionary new];
//        }
//        [mulDic setValue:@"已存在" forKey:localIdentifier];
//    }
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//    [self.view addSubview:imageView];
//    [self plistWriteDate:mulDic];
//}

- (ESEmptyView *)blankSpaceView {
    if (!_blankSpaceView) {
        _blankSpaceView = [ESEmptyView new];
        ESEmptyItem *item = [ESEmptyItem new];
        item.icon = IMAGE_EMPTY_NOFILE;
        item.content = NSLocalizedString(@"file_no_data", @"暂无文件");
        [self.view addSubview:_blankSpaceView];
        [_blankSpaceView reloadWithData:item];
    }
    return _blankSpaceView;
}

-(BOOL)isUploadingPhotoID:(NSString *)photoID{
    if (photoID.length < 1) {
        return YES;
    }
   
    NSArray *uploadUploadingArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadUploadingArray"];
    NSMutableArray *uploadPhotoIDmutableArray;
    NSMutableArray *newUploadPhotoIDmutableArray;
    if (uploadUploadingArray.count > 0) {
        NSArray<ESTransferTask *> *cache = [NSArray yy_modelArrayWithClass:[ESTransferTask class] json:[ESCache.defaultCache objectForKey:[NSString stringWithFormat:@"kESTransferManagerUploadedQueue_%@", ESBoxManager.activeBox.boxUUID]]];
        uploadPhotoIDmutableArray = [[NSMutableArray alloc] initWithArray:uploadUploadingArray];
        newUploadPhotoIDmutableArray = [uploadPhotoIDmutableArray mutableCopy];
        if(cache.count > 0){
            for (ESTransferTask *task in cache) {
                for (NSString *photoID in uploadPhotoIDmutableArray) {
                    if([task.metadata.photoID isEqual:photoID]){
                        [newUploadPhotoIDmutableArray removeObject:photoID];
                    }
                }
            }
        }
        for (int i = 0 ; i < uploadUploadingArray.count; i++) {
            if ([photoID isEqual:uploadUploadingArray[i]]) {
                return  YES;
            }
        }
    }else{
        newUploadPhotoIDmutableArray = [[NSMutableArray alloc] init];
    }
    [newUploadPhotoIDmutableArray addObject:photoID];
    NSArray *array = [[NSArray alloc]initWithArray:uploadPhotoIDmutableArray];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"uploadUploadingArray"];
    return NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
