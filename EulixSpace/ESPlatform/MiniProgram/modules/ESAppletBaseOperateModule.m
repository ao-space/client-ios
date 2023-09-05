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
//  ESMimiProgramDownloadModule.m
//  EulixSpace
//
//  Created by KongBo on 2022/6/6.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESAppletBaseOperateModule.h"
#import "ESApiClient.h"
#import "ESAppletServiceApi.h"
#import "ESAppletManager+ESCache.h"
#import "ESBoxManager.h"
#import "ESAppletService.h"
#import "ESNetworkRequestManager.h"
#import "ESAppStoreModel.h"
#import "NSError+ESTool.h"
#import "ESToast.h"

@interface ESAppletBaseOperateModule ()
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation ESAppletBaseOperateModule

- (void)installAppletWithId:(NSString *)appletId completionBlock:(ESMPBaseModuleCompletionBlock)block {
    if (appletId.length <= 0) {
        return;
    }
    ESAppletService *api = [ESAppletService new];
    [api spaceV1ApiAppletInstallPostWithAppletId:appletId completionHandler:^(ESAppletResponseBase *output, NSError *error) {
        if (!block) {
            return;
        }
        if (error) {
            block(NO, error);
            return;
        }
        // applet 已经存在
        if ([output.code isEqualToString:@"GW-4020"]) {
            block(YES, nil);
            return;
        }
        
        if (![output.code isEqualToString:@"GW-200"]) {
            block(NO, [NSError errorWithDomain:ESNetWorkErrorDomain
                                          code:NSNetworkErrorResponseBusiness
                                      userInfo:@{ESNetworkErrorUserInfoMessageKey : ESSafeString(output.message),
                                                 ESNetworkErrorUserInfoResposeCodeKey : ESSafeString(output.code)
                                               }]);
            return;
        }
        
        block(YES, nil);
        return;
    }];
}

- (void)unintallAppletWithId:(NSString *)appletId completionBlock:(ESMPBaseModuleCompletionBlock)block {
    if (appletId.length <= 0) {
        return;
    }
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_uninstall"
                                                queryParams:@{ @"appid" : appletId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
       // __strong typeof(weakSelf) self = weakSelf;
         block(YES, nil);
            
        } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         //   __strong typeof(weakSelf) self = weakSelf;
            if (error) {
               block(NO, error);
               return;
           }
        }];
    
}

- (void)updateAppletWithId:(NSString *)appletId  packageId:(NSString *)packageId completionBlock:(ESMPBaseModuleCompletionBlock)block {
    if (appletId.length <= 0) {
        return;
    }
    // 修改v2更新
    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
                                                    apiName:@"appstore_update"
                                                queryParams:@{@"appid" : appletId,
                                                              @"packageid":packageId
                                                            }
                                                     header:@{}
                                                       body:@{}
                                                  modelName:@""
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {

        
                if (!block) {
                    return;
                }
                block(YES, nil);
    }
    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([[error codeString] isEqualToString:@"GW-5006"]) {
            [ESToast toastWarning:NSLocalizedString(@"Box can not access platform", @"无法完成此操作，原因：无法连接至傲空间平台")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic = [NSDictionary new];
            dic =error.userInfo;
            NSString *codeStr = [NSString stringWithFormat:@"%ld",(long)error.code];
            block(NO, [NSError errorWithDomain:ESNetWorkErrorDomain
                                                    code:NSNetworkErrorResponseBusiness
                                                userInfo:@{ESNetworkErrorUserInfoMessageKey : ESSafeString(dic[@"message"]),
                                                           ESNetworkErrorUserInfoResposeCodeKey : ESSafeString(codeStr)
                                                         }]);
        });
    }];
//    ESAppletService *api = [ESAppletService new];
//    [api spaceV1ApiAppletUpdatePutWithAppletId:appletId completionHandler:^(ESAppletResponseBase *output, NSError *error) {
//        if (!block) {
//            return;
//        }
//        if (error) {
//            block(NO, error);
//            return;
//        }
//
//        if (![output.code isEqualToString:@"GW-200"]) {
//            block(NO, [NSError errorWithDomain:ESNetWorkErrorDomain
//                                          code:NSNetworkErrorResponseBusiness
//                                      userInfo:@{ESNetworkErrorUserInfoMessageKey : ESSafeString(output.message),
//                                                 ESNetworkErrorUserInfoResposeCodeKey : ESSafeString(output.code)
//                                               }]);
//            return;
//        }
//        block(YES, nil);
//    }];
}

- (void)downAppletWithId:(NSString *)appletId
           appletVersion:(NSString *)appletVersion
         completionBlock:(ESMPBaseModuleDownloadCompletionBlock)block {
    if (appletId.length <= 0) {
        return;
    }
    NSString *userDomain = ESBoxManager.activeBox.info.userDomain;
    if (userDomain.length <= 0) {
        return;
    }
    
    //NSString *url = @"http://g398hmrn.dev-space.eulix.xyz/space/v1/api/gateway/applet/down";
    NSString *url = [NSString stringWithFormat:@"http://%@/space/v1/api/gateway/applet/down",userDomain];
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    if (!components) {
        return;
    }
    NSURLQueryItem * newQueryItem = [[NSURLQueryItem alloc] initWithName:@"applet_id" value:appletId];
    [components setQueryItems:@[newQueryItem]];

    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    [mRequest addValue:NSUUID.UUID.UUIDString.lowercaseString  forHTTPHeaderField:@"Request-Id"];
    [mRequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [mRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mRequest setHTTPMethod:@"POST"];
    
    [[[NSURLSession sharedSession] downloadTaskWithRequest:mRequest
                                         completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!block) {
            return;
        }
        if (error) {
            block(NO, nil, error);
            return;
        }

        NSString *unzipPath =  [ESAppletManager.shared getCacheUnzipFilePathWithAppleId:appletId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:unzipPath]) {
            NSError *removeError;
            [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:nil];
            if (removeError) {
                block(NO, nil, removeError);
                return;
            }
        }

        BOOL unZipSuccess = [ESAppletManager.shared addAppletCacheWithId:appletId
                                                            appletVerion:appletVersion
                                                        downloadFilePath:location.path];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(unZipSuccess, unZipSuccess ? unzipPath : nil, nil);
        });
      }] resume];
}

//- (void)getManagementServiceApi:(NSString *){
//    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-appstore-service"
//                                                    apiName:@"appstore_sort_list"
//                                                queryParams:@{}
//                                                     header:@{}
//                                                       body:@{}
//                                                  modelName:@""
//                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if([response isKindOfClass:[NSArray class]]){
//                NSMutableArray *dataResponse = [[NSMutableArray alloc] init];
//                for (NSDictionary *dictData in response) {
//                    NSMutableArray *dataList = [[NSMutableArray alloc] init];
//                    NSArray *arrayAppDate= dictData[@"appStoreResList"];
//                    for (NSDictionary *dict in arrayAppDate) {
//                        ESAppStoreModel *model = [ESAppStoreModel yy_modelWithJSON:dict];
//                        if([model.appId isEqual: self.appStoreModel.appId]){
//                            if([model.state isEqual:@"已安装"]){
//                            }else if([model.state isEqual:@"安装失败"]){
//                            }else if([model.state isEqual:@"更新失败"]){
//
//                            }
//                        }
//                    }
//                }
//            }
//        });
//    }
//    failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        [self timerStop];
//    }];
//}


- (void)timerStop {
    @synchronized (self){
        if (self.timer) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    }
}


@end
