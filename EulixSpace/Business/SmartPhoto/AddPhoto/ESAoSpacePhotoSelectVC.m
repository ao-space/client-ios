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
//  ESAoSpacePhotoSelectVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/10/31.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAoSpacePhotoSelectVC.h"
#import "ESSmartPhotoDataBaseManager.h"
#import "ESBaseViewController+Status.h"
#import "ESSmartPhotoAsyncManager.h"
#import "ESSelectedTopToolVC.h"
#import "ESBottomSelectedOperateVC.h"
#import "ESFileDefine.h"
#import "ESLocalizableDefine.h"
#import "ESImageDefine.h"
#import "ESAlbumModifyModule.h"
#import "ESToast.h"
#import "ESPicModel.h"

FOUNDATION_EXTERN NSNotificationName const ESMoreOperateAddToAlbum;

@interface ESPhotoBasePageVC ()

@property (nonatomic, strong) ESSelectedTopToolVC *topSelecteToolVC;
@property (nonatomic, strong) ESBottomSelectedOperateVC *bottomMoreToolVC;

- (void)updateTopSelectedStatus;
- (void)showSelectedStyle;
- (void)showSelectStyle;

@end

@interface ESAoSpacePhotoSelectVC ()

@property (nonatomic, strong) UILabel *uploadPositionLabel;
@property (nonatomic, strong) UILabel *uploadPositionTextLabel;
@property (nonatomic, strong) UIButton *uploadBtn;

@end

@implementation ESAoSpacePhotoSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    [self.listModule setShowStyle:ESSmartPhotoPageShowStyleSelecte];
    [self.bottomMoreToolVC hidden];
    
    [self updateUploadDir];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.topSelecteToolVC hidden];
}

- (void)setupSubViews {
    __weak typeof (self) weakSelf = self;
    self.topSelecteToolVC.cancelActionBlock = ^() {
        __strong typeof(weakSelf) self = weakSelf;
        [self.listModule cleanAllSeleted];
        [self updateShowStyle];
    };
    
    self.topSelecteToolVC.goActionBlock = ^() {
        __strong typeof(weakSelf) self = weakSelf;
        [self.topSelecteToolVC hidden];
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    self.topSelecteToolVC.limitSelectStyle = YES;
    [self.topSelecteToolVC updateSelectdCount:0 isAllSelected:NO];
    
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
    }];

    [self.uploadPositionTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.uploadPositionLabel.mas_right).inset(10);
        make.centerY.mas_equalTo(self.uploadBtn.mas_centerY).inset(26);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.uploadBtn.mas_left).offset(-20);
    }];
    
    [self.listView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(4.0f);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-104.0f);
    }];
}

- (void)showSelectedStyle {
    [super showSelectedStyle];
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.view.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)updateSelectedToolStatus {
    [self.topSelecteToolVC showFrom:self];
    [self updateTopSelectedStatus];
    if (self.listModule.selectedCount > 0) {
        [self.topSelecteToolVC setShowStyle:ESSelectedTopToolVCShowStyleSelecte];
        [self.uploadBtn setBackgroundImage:IMAGE_COMMON_GRADUAL_BTNBG forState:UIControlStateNormal];
    } else {
        [self.topSelecteToolVC setShowStyle:ESSelectedTopToolVCShowStyleCanGoBack];
        self.uploadBtn.backgroundColor = ESColor.grayBgColor;
        [self.uploadBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

- (void)reloadDataByType {
    weakfy(self)
    dispatch_async([ESSmartPhotoAsyncManager shared].requestHandleQueue, ^{
        self.listModule.timeLineType = ESTimelineFrameItemTypeDay;
        ESSmartPhotoListModel *mockModel = [ESSmartPhotoListModel reloadOnlyPicDataFromDBWithType:self.listModule.timeLineType];
        NSArray<ESPicModel *> *picList = [ESSmartPhotoDataBaseManager.shared getPicsFromDBWithAlbumId:self.uploadAlbumModel.albumId];
        NSMutableArray *uuidList = [NSMutableArray array];
        [picList enumerateObjectsUsingBlock:^(ESPicModel *pic, NSUInteger idx, BOOL * _Nonnull stop) {
            [uuidList addObject: ESSafeString(pic.uuid)];
        }];
        
        //需要过滤处理
        if (uuidList.count > 0) {
            NSMutableArray *needRemoveSection = [NSMutableArray array];
            [mockModel.sections enumerateObjectsUsingBlock:^(ESSmartPhotoListSectionModel * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *blockTemp = [NSMutableArray array];
                [section.blocks enumerateObjectsUsingBlock:^(ESSmartPhotoListBlockModel * _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (block.items.count == 1 && [block.items[0] isKindOfClass:[ESPicModel class]]  &&
                        ![uuidList containsObject:ESSafeString([(ESPicModel *)block.items[0] uuid])] ) {
                        [blockTemp addObject:block];
                    }
                }];
                section.blocks = [blockTemp copy];
                if (section.blocks.count <= 0) {
                    [needRemoveSection addObject:section];
                }
            }];
            
            if (needRemoveSection.count > 0) {
                NSMutableArray *sectionTemp = [mockModel.sections mutableCopy];
                [sectionTemp removeObjectsInArray:needRemoveSection];
                mockModel.sections = [sectionTemp copy];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongfy(self)
            if (mockModel.sections.count == 0) {
                [self showEmpty:YES];
            } else {
                [self showEmpty:NO];
            }
            [self.listModule reloadData:mockModel];
        });
    });
}

- (NSString *)titleForEmpty {
    return NSLocalizedString(@"file_none_photos", @"您还没有任何图片哦");
}

#pragma UI -
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
        if (path.length > 0) {
            _uploadPositionTextLabel.text = path;
        } else {
            _uploadPositionTextLabel.text = NSLocalizedString(@"me_space", @"我的空间");
        }
        [_uploadPositionTextLabel addGestureRecognizer:tapRecognizerWeibo];
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

- (void)updateUploadDir {
    self.uploadPositionTextLabel.text = [NSString stringWithFormat:@"%@/%@",@"我的相簿",self.uploadAlbumModel.albumName];
}

- (void)selectPathClick:(UITapGestureRecognizer *)tag {

}

- (void)uploadAction:(id)sender {
    NSArray *uuidList = self.listModule.selectedMap.allKeys;
    if (uuidList.count <= 0 || self.uploadAlbumModel.albumId.length <= 0) {
        return;
    }
    
    [ESAlbumModifyModule addPhtotos:uuidList
                            albumId:[self.uploadAlbumModel.albumId integerValue]
                         completion:^(ESAlbumModifyType modifyType, BOOL success, NSError * _Nullable error) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ESMoreOperateAddToAlbum object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ESToast toastSuccess:NSLocalizedString(@"add_success", @"添加成功")];
            });
       
            return;
        }
        if ([error.userInfo[@"code"] isEqual:@(1060)]) {
            [ESToast toastError:@"该文件已在相簿中，请勿重复添加"];
            return;
        }
        [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];

    }];
}
@end

