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
//  ESBottomToolVC.m
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBottomSelectedOperateVC.h"
#import "ESTransferManager.h"
#import "ESToast.h"
#import "ESMoreOperateComponentItem.h"
#import "ESShareOperateItem.h"
#import "ESDownloadOperateItem.h"
#import "ESAddToAblumOperateItem.h"
#import "ESDeleteOperateItem.h"
#import "ESMoreOperateItem.h"
//#import "ESSmartPhotoHomeVC.h"
#import "ESDetailOperateItem.h"
#import "ESCopyOperateItem.h"
#import "ESMoveOperateItem.h"
#import "ESMoreOperatePicSelectedModule.h"

//@interface ESSmartPhotoHomeVC () <ESParentVCDelegate>
//
//@end

@interface ESBottomSelectedOperateVC () <ESMoreOperateVCDelegate>

@property (nonatomic, assign) BOOL tabBarShowPre;
@property (nonatomic, copy) NSArray *selectedInfoArray;
@property (nonatomic, strong) NSArray *isSelectUUIDSArray;
@property (nonatomic, weak) UIViewController<ESParentVCDelegate> *parentVC;

@property (nonatomic, copy) NSArray<ESMoreOperateComponentItem *> *operateItems;

@end

static CGFloat const ESLeftRightSpacing = 18.0f;

@implementation ESBottomSelectedOperateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ESColor.systemBackgroundColor;
}

- (void)showFrom:(UIViewController *)parentVC {
    self.parentVC = (UIViewController<ESParentVCDelegate> *)parentVC;
    if (self.view.superview) {
        return;
    }
    [[UIApplication sharedApplication].keyWindow.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 1088) {
            [obj removeFromSuperview];
        }
    }];
    self.view.tag = 1088;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    if ([UIApplication sharedApplication].keyWindow) {
        [self reloadComponentItems];
    }
    
    [self updateSelectedList:self.selectedInfoArray];
    
    if (!parentVC.tabBarController.tabBar.hidden) {
        _tabBarShowPre = YES;
        _parentVC.tabBarController.tabBar.hidden = YES;
    }
}

- (void)reloadComponentItems {
    [self.operateItems enumerateObjectsUsingBlock:^(ESMoreOperateComponentItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.menuView.superview) {
            [obj.menuView removeFromSuperview];
        }
    }];
    self.operateItems = [self componentsWithParentVC:(UIViewController<ESParentVCDelegate> *)self.parentVC];
    CGFloat height = 50 + kBottomHeight;
    if(kBottomHeight < 1){
        height = 50 + kBottomHeight + 20;
    }
    CGSize size = [UIApplication sharedApplication].keyWindow.bounds.size;
    self.view.frame = CGRectMake(0, size.height - height, size.width, height);
    CGFloat seprateOffset = 30.0f;
    if (self.operateItems.count >= 3) {
        __block CGFloat totalItemsWidth = 0;
//        [self.operateItems enumerateObjectsUsingBlock:^(ESMoreOperateComponentItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
//            totalItemsWidth += [item viewSize].width;
//        }];
        
        totalItemsWidth = [self.operateItems[0] viewSize].width * 5;
        seprateOffset = ((size.width - totalItemsWidth) - 2 * ESLeftRightSpacing ) / (4);
    }
    
    [self.operateItems enumerateObjectsUsingBlock:^(ESMoreOperateComponentItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:item.menuView];
        if (idx == 0) {
            [item.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view.mas_left).offset(ESLeftRightSpacing);
                make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
                make.size.mas_equalTo(item.viewSize);
            }];
        } else {
            ESMoreOperateComponentItem *preItem = self.operateItems[idx -1];
            [item.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(preItem.menuView.mas_right).offset(seprateOffset);
                make.top.mas_equalTo(self.view.mas_top).offset(0.0f);
                make.size.mas_equalTo(item.viewSize);
            }];
        }
    }];
}

- (NSArray<ESMoreOperateComponentItem *> *)componentsWithParentVC:(UIViewController<ESParentVCDelegate> *)parentVC {
    NSMutableArray *componentItemList = [NSMutableArray array];
    NSArray *componentNameList ;
    if (self.selectedInfoArray.count == 0) {
        componentNameList = @[];
    } else if (self.selectedInfoArray.count == 1) {
        componentNameList = self.componentSingleSeletedOperateClassNameList;
    } else {
        componentNameList = self.componentMutilSeletedOperateClassNameList;
    }
    
    [componentNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        ESMoreOperateComponentItem *componentItem = [[NSClassFromString(className) alloc] initWithParentMoreOperateVC:self];
        componentItem.parentVC = parentVC;
        componentItem.selectedModule  = [ESMoreOperatePicSelectedModule new];
        componentItem.albumId = self.albumId;
        [componentItemList addObject:componentItem];
    }];
    return componentItemList;
}

- (NSArray *)componentSingleSeletedOperateClassNameList {
//    return @[@"ESDownloadOperateItem", @"ESShareOperateItem", @"ESAddToAblumOperateItem", @"ESDeleteOperateItem", @"ESMoreOperateItem"];
    return @[@"ESDownloadOperateItem", @"ESShareOperateItem", @"ESDeleteOperateItem", @"ESDetailOperateItem", @"ESMoreOperateItem"];
}

- (NSArray *)componentMutilSeletedOperateClassNameList {
    return @[@"ESDownloadOperateItem", @"ESShareOperateItem", @"ESDeleteOperateItem"];
}

- (void)hidden {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    if (_tabBarShowPre) {
        _parentVC.tabBarController.tabBar.hidden = NO;
    }
}

- (void)updateSelectedList:(NSArray *)selectedList {
    BOOL needReload = !(selectedList.count >= 2 && self.selectedInfoArray.count > 2);
    if (selectedList.count > 0 && [selectedList[0] isKindOfClass:[ESFileInfoPub class]]) {
        NSMutableArray *list = [NSMutableArray array];
        [selectedList enumerateObjectsUsingBlock:^(ESFileInfoPub *_Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
            ESPicModel *pic = [ESPicModel new];
            pic.uuid = file.uuid;
            pic.name = file.name;
            pic.path = file.path;
            pic.shootAt =  [file.operationAt doubleValue];
            pic.size = [file.size floatValue];
            [list addObject:pic];
        }];
        self.selectedInfoArray = [list copy];
    } else if ([selectedList[0] isKindOfClass:[ESPicModel class]]){
        self.selectedInfoArray = selectedList;
    } else {
        return;
    }
   
    if (needReload) {
        [self reloadComponentItems];
    }
    [self.operateItems enumerateObjectsUsingBlock:^(ESMoreOperateComponentItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item updateSelectedList:self.selectedInfoArray];
    }];
    
}

- (void)cancelAction {
    [self hidden];
    if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)]) {
        [self.parentVC finishActionShowNormalStyleWithCleanSelected];
    }
}

@end
