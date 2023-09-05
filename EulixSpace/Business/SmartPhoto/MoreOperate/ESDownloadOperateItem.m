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
//  ESBottomToolVC.h
//  EulixSpace
//
//  Created by KongBo on 2022/9/23.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESDownloadOperateItem.h"
#import "ESToast.h"
#import "ESTransferManager.h"
#import "ESCacheInfoDBManager.h"
#import "ESNetworkRequestManager.h"
#import "ESBoxManager.h"
#import "ESLocalizableDefine.h"

@interface ESDownloadOperateItem ()

@property (nonatomic, copy) NSArray<ESPicModel *> *selectedInfoArray;

@end

@implementation ESDownloadOperateItem

- (instancetype)initWithParentMoreOperateVC:(UIViewController<ESMoreOperateVCDelegate> *)moreOperateVC {
    if (self = [super initWithParentMoreOperateVC:moreOperateVC]) {
        __weak typeof (self) weakSelf = self;
        self.actionBlock = ^() {
            __strong typeof(weakSelf) self = weakSelf;
            [self downloadItems];
        };
    }
    return self;
}

- (void)updateSelectedList:(NSArray<ESPicModel *> *)selectedList {
    [self.selectedModule updateSelectedList:selectedList];
}

- (NSString *)title {
    return NSLocalizedString(@"file_bottom_down", @"保存本地");
}

- (NSString *)iconName {
    return @"file_bottom_down";
}


- (void)downloadItems {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:&error];
    if (dictionary) {
        NSNumber *free = dictionary[NSFileSystemFreeSize];
        long long int size = 0;
        for(int i = 0; i < self.selectedInfoArray.count; i++){
            ESPicModel *info = self.selectedInfoArray[i];
            size = size + info.size;
        }
        if(free.unsignedLongLongValue < size * 2){
            [ESToast toastError:@"手机空间不足"];
            return;
        }
    }
   
//    [ESToast toastInfo:@"已添加到传输列表"];
    [ESToast toastSuccess:TEXT_ADDED_TO_TRANSFER_LIST];
    [self.selectedModule.selectedInfoArray enumerateObjectsUsingBlock:^(ESPicModel *_Nonnull pic, NSUInteger idx, BOOL *_Nonnull stop) {
        [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                        apiName:@"history_record_add"                                  queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                         header:@{}
                                                           body:@{@"phoneType" : @"ios",
                                                                  @"uuid" : pic.uuid,
                                                                  @"fileName" : pic.name,
                                                                  @"category" :pic.category,
                                                                  @"opType" : @(1),
                                                                }
                                                      modelName:nil
                                                   successBlock:^(NSInteger requestId, id  _Nullable response) {
              NSLog(@"%@",response);
          }
            failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@",response);
            [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
         }];
        
        if (![pic.uuid hasPrefix:@"mock"]) {
            ESFileInfoPub *fileInfo = [ESFileInfoPub new];
            fileInfo.uuid = pic.uuid;
            fileInfo.name = pic.name;
            fileInfo.category = pic.category;
            fileInfo.size = [NSNumber numberWithLong:pic.size];
            [ESTransferManager.manager download:fileInfo
                                       callback:^(NSURL *output, NSError *error){
                                        if (!error && output.absoluteString.length > 0) {
                                            ESCacheInfoItem *item = [ESCacheInfoItem new];
                                            item.name = pic.name;
//                                        file:///var/mobile/Containers/Data/Application/A49AEC49-C082-4661-BB27-E328DD0D98E7/Library/Caches/IMG_0950888/IMG_0950888.HEIC
                                            NSRange range = [output.absoluteString rangeOfString:@"Library/Caches/"];
                                            if (range.location != NSNotFound) {
                                                item.path = [output.absoluteString substringFromIndex:(range.location + range.length)];
                                            }
                                            
                                            item.size = pic.size;
                                            item.uuid = pic.uuid;
                                            item.cacheType = ESBusinessCacheInfoTypePhoto;
                                            [[ESCacheInfoDBManager shared] insertOrUpdatCacheInfoToDB:@[item]];
                                        }else{
                                             [ESToast toastWarning:NSLocalizedString(@"service failed, retry later", @"服务异常，请稍后重试")];
                                        }

                                       }];
        }
    }];
    if ([self.parentVC respondsToSelector:@selector(finishActionShowNormalStyleWithCleanSelected)]) {
        [self.parentVC finishActionShowNormalStyleWithCleanSelected];
    }
}

@end
