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
//  ESUploadLocalPhotoSelectVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESUploadLocalPhotoSelectVC.h"
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
#import "ESSmartPhotoDataBaseManager.h"
#import "ESLocalPhotoSelectVC.h"

static NSString *photoCollectionViewCell = @"photoCollectionViewCell";

@interface ESPhotoCollectionVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ESPhotoCollectionCellDelegate>

@property (nonatomic, strong) UIButton *uploadBtn;
@property (nonatomic, strong) UIButton *showAlbumButton;
/// 相册列表
@property (nonatomic, strong) UICollectionView *albumCollectionView;

@property (nonatomic, strong) UILabel *uploadPositionLabel;
@property (nonatomic, strong) UILabel *uploadPositionTextLabel;

//@property (nonatomic, copy) NSString *localIdentifier;
//
//@property (nonatomic, copy) NSString *asset;

- (void)setupViewController;
- (void)switched:(UISwitch *)sender;
- (BOOL)isUploadingPhotoID:(NSString *)photoID;

@end


@interface ESUploadLocalPhotoSelectVC ()

@end

@implementation ESUploadLocalPhotoSelectVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self updateUploadDir];
    
    if ( self.albumModel.photoAssets.count > 0 ) {
        [self.albumCollectionView reloadData];
    }
}

#pragma mark - 设置控制器
- (void)setupViewController {
    [super setupViewController];
    self.albumCollectionView.frame = CGRectMake(0, kTopHeight, ScreenWidth, ScreenHeight - 100 - kTopHeight);
    [self.view bringSubviewToFront:self.albumCollectionView];
}

- (void)updateUploadDir {
    self.uploadPositionTextLabel.text = [NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"album_my", @"我的相簿"),self.uploadAlbumModel.albumName];
}

- (void)updateAlbumModel:(ESPhotoModel *)albumModel {
    self.albumModel = albumModel;
    self.albumModel.photoAssets = (NSMutableArray *)self.albumModel.assets;
    if (self.viewLoaded && self.view.window) {
        [self.albumCollectionView reloadData];
    }
}

- (void)addSwitch {
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth - 50 - 30, 124, 50, 30)];
    [self.view addSubview:mySwitch];
    [mySwitch addTarget:self
                  action:@selector(switched:)
        forControlEvents:UIControlEventValueChanged];
    [mySwitch setOn:NO];
    [self switched:mySwitch];
}

- (void)showSelectionCountTitle {
    NSInteger choiceCount = self.albumModel.selectRows.count;
    NSString *titleStr = [NSString stringWithFormat:NSLocalizedString(@"file_select", @"已选择%lu个文件"), choiceCount];
    
    [self.showAlbumButton setTitle:titleStr forState:UIControlStateNormal];
    if (choiceCount == 0) {
        self.uploadBtn.backgroundColor = ESColor.grayBgColor;
        [self.uploadBtn setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        [self.uploadBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
    }
}

- (void)selectPathClick:(UITapGestureRecognizer *)tag {
}

- (void)uploadAction:(UIButton *)btn {
    self.uploadBtn.enabled = NO;
    if (self.dir.length < 1) {
        self.dir = @"/";
    }
    NSString *dir = [self.dir substringFromIndex:self.dir.length - 1];
    if (![dir isEqual:@"/"]) {
        self.dir = [NSString stringWithFormat:@"%@/", self.dir];
    }

    if ([ESPhotoManger standardPhotoManger].choiceCount > 0) {
        for (NSNumber *row in self.albumModel.selectRows) {
            if (row.integerValue < self.albumModel.assets.count) {
                ESSelectPhotoModel *photoModel = [[ESSelectPhotoModel alloc] init];
                __weak typeof(photoModel) weakPhotoModel = photoModel;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        photoModel.getPictureAction = ^{
                            if(![self isUploadingPhotoID:weakPhotoModel.asset.localIdentifier]){
                            ESUploadMetadata *metadata = [ESUploadMetadata fromAsset:weakPhotoModel.asset type:kESUploadMetadataTypeTransfer];
                            NSDate* pictureDate = [weakPhotoModel.asset creationDate];
                            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
                            formatter.dateFormat = @"yyyy/MM";
                            formatter.timeZone = [NSTimeZone localTimeZone];
                            NSString * pictureTime = [formatter stringFromDate:pictureDate];
                            metadata.folderPath = pictureTime.length > 0 ? [NSString stringWithFormat:@"/相册/%@/", pictureTime] : @"/相册/";
                            metadata.multipart = YES;
                            metadata.category = self.category;
                            metadata.source = @"video";
                            metadata.photoNum = self.photoNumer;
                            metadata.photoID = weakPhotoModel.asset.localIdentifier;
                            metadata.albumId = self.uploadAlbumModel.albumId;
                            metadata.businessId = 2;

                            [ESTransferManager.manager upload:metadata
                                                     callback:nil];
                            }
                        };
                       });

//                [ESToast toastSuccess:@"请稍后，将添加至传输列表"];
                [ESToast toastSuccess:NSLocalizedString(@"Please add to the transfer list later", @"请稍后，将添加至传输列表")];
                __block NSUInteger pop2VCIndex = NSNotFound;
                [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj isKindOfClass:[ESLocalPhotoSelectVC class]]) {
                                        pop2VCIndex = idx;
                                        *stop = YES;
                                    }
                                }];
                
                if (self.navigationController.viewControllers.count > (pop2VCIndex - 1)) {
                    [self.navigationController popToViewController:self.navigationController.viewControllers[pop2VCIndex -1] animated:YES];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didHiddenSelfNSNotification" object:nil];
                photoModel.asset = self.albumModel.assets[row.integerValue];
            }
        }
    }
}


- (void)tryAddSelectItemWithIndex:(NSInteger)index {
    if (self.albumModel.selectRows.count < 100) {
        [self.albumModel.selectRows addObject:@(index)];
    } else{
        [ESToast toastError:@"手动上传，每次最多支持100张"];
    }
}

@end
