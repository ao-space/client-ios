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
//  ESCommonToolManager.m
//  EulixSpace
//
//  Created by qu on 2021/10/20.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommonToolManager.h"
#import "ESBoxManager.h"
#import "ESGatewayManager.h"
#import "ESWebContainerViewController.h"
#import "ESNetworkRequestManager.h"
#import "ESCommentToolVC.h"
#import "ESPlatformClient.h"
#import "UIImage+ESTool.h"
#import "ESLocalPath.h"
#import "ESFeedbackImagItem.h"
#import <sys/utsname.h>
#import "ESBackupApi.h"
#import "ESRestoreApi.h"


@implementation ESCommonToolManager

+ (instancetype)manager {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark-- 判断手机型号


+ (NSString *)judgeIphoneType:(NSString *)phoneTypeNil{

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneType;
    if (phoneTypeNil.length > 0) {
        phoneType = phoneTypeNil;
    }else{
        phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    }
       
        if ([phoneType isEqualToString:@"i386"])
            return @"Simulator";
    
        if ([phoneType isEqualToString:@"x86_64"])
            return @"Simulator";
    
        //  常用机型  不需要的可自行删除
    
        if ([phoneType isEqualToString:@"iPhone1,1"])
            return @"iPhone 2G";
    
        if ([phoneType isEqualToString:@"iPhone1,2"])
            return @"iPhone 3G";
    
        if ([phoneType isEqualToString:@"iPhone2,1"])
            return @"iPhone 3GS";
    
        if ([phoneType isEqualToString:@"iPhone3,1"])
            return @"iPhone 4";
    
        if ([phoneType isEqualToString:@"iPhone3,2"])
            return @"iPhone 4";
    
        if ([phoneType isEqualToString:@"iPhone3,3"])
            return @"iPhone 4";
    
        if ([phoneType isEqualToString:@"iPhone4,1"])
            return @"iPhone 4S";
    
        if ([phoneType isEqualToString:@"iPhone5,1"])
            return @"iPhone 5";
    
        if ([phoneType isEqualToString:@"iPhone5,2"])
            return @"iPhone 5";
    
        if ([phoneType isEqualToString:@"iPhone5,3"])
            return @"iPhone 5c";
    
        if ([phoneType isEqualToString:@"iPhone5,4"])
            return @"iPhone 5c";
    
        if ([phoneType isEqualToString:@"iPhone6,1"])
            return @"iPhone 5s";
    
        if ([phoneType isEqualToString:@"iPhone6,2"])
            return @"iPhone 5s";
    
        if ([phoneType isEqualToString:@"iPhone7,1"])
            return @"iPhone 6 Plus";
    
        if ([phoneType isEqualToString:@"iPhone7,2"])
            return @"iPhone 6";
    
        if ([phoneType isEqualToString:@"iPhone8,1"])
            return @"iPhone 6s";
    
        if ([phoneType isEqualToString:@"iPhone8,2"])
            return @"iPhone 6s Plus";
    
        if ([phoneType isEqualToString:@"iPhone8,4"])
            return @"iPhone SE";
    
        if ([phoneType isEqualToString:@"iPhone9,1"])
            return @"iPhone 7";
    
        if ([phoneType isEqualToString:@"iPhone9,2"])
            return @"iPhone 7 Plus";
    
        if ([phoneType isEqualToString:@"iPhone10,1"])
            return @"iPhone 8";
    
        if ([phoneType isEqualToString:@"iPhone10,4"])
            return @"iPhone 8";
    
        if ([phoneType isEqualToString:@"iPhone10,2"])
            return @"iPhone 8 Plus";
    
        if ([phoneType isEqualToString:@"iPhone10,5"])
            return @"iPhone 8 Plus";
    
        if ([phoneType isEqualToString:@"iPhone10,3"])
            return @"iPhone X";
    
        if ([phoneType isEqualToString:@"iPhone10,6"])
            return @"iPhone X";
    
        if ([phoneType isEqualToString:@"iPhone11,8"])
            return @"iPhone XR";
    
        if ([phoneType isEqualToString:@"iPhone11,2"])
            return @"iPhone XS";
    
        if ([phoneType isEqualToString:@"iPhone11,4"])
            return @"iPhone XS Max";
    
        if ([phoneType isEqualToString:@"iPhone11,6"])
            return @"iPhone XS Max";
    
        if ([phoneType isEqualToString:@"iPhone12,1"])
            return @"iPhone 11";
    
        if ([phoneType isEqualToString:@"iPhone12,3"])
            return @"iPhone 11 Pro";
    
        if ([phoneType isEqualToString:@"iPhone12,5"])
            return @"iPhone 11 Pro Max";
    
        if ([phoneType isEqualToString:@"iPhone12,8"])
            return @"iPhone SE2";
    
        if ([phoneType isEqualToString:@"iPhone13,1"])
            return @"iPhone 12 mini";
    
        if ([phoneType isEqualToString:@"iPhone13,2"])
            return @"iPhone 12";
    
        if ([phoneType isEqualToString:@"iPhone13,3"])
            return @"iPhone 12  Pro";
    
        if ([phoneType isEqualToString:@"iPhone13,4"])
            return @"iPhone 12  Pro Max";
    
        if ([phoneType isEqualToString:@"iPhone14,4"])
            return @"iPhone 13 mini";
    
        if ([phoneType isEqualToString:@"iPhone14,5"])
            return @"iPhone 13";
    
        if ([phoneType isEqualToString:@"iPhone14,2"])
            return @"iPhone 13 Pro";
    
        if ([phoneType isEqualToString:@"iPhone14,3"])
            return @"iPhone 13 Pro Max";
    
        if ([phoneType isEqualToString:@"iPhone14,6"])
            return @"iPhone SE3";

        if ([phoneType isEqualToString:@"iPhone14,7"])
            return @"iPhone 14";

        if ([phoneType isEqualToString:@"iPhone14,8"])
            return @"iPhone 14 Plus";

        if ([phoneType isEqualToString:@"iPhone15,2"])
            return @"iPhone 14 Pro";

        if ([phoneType isEqualToString:@"iPhone15,3"])
            return @"iPhone 14 Pro Max";
   
        if([phoneType  isEqualToString:@"iPad1,1"])// ipad
            return @"iPad";
        if([phoneType  isEqualToString:@"iPad2,1"])// iapd 2
                return@"iPad 2";
        if([phoneType  isEqualToString:@"iPad2,2"])
           return @"iPad 2";
        if([phoneType  isEqualToString:@"iPad2,3"])
           return @"iPad 2";
        if([phoneType  isEqualToString:@"iPad2,4"])
           return @"iPad 2";
        if([phoneType  isEqualToString:@"iPad3,1"])//ipad 3
           return @"iPad (3rd generation)";
        if([phoneType  isEqualToString:@"iPad3,2"])
           return @"iPad (3rd generation)";
        if([phoneType  isEqualToString:@"iPad3,3"])
           return @"iPad (3rd generation)";
        if([phoneType  isEqualToString:@"iPad3,4"])//ipad 4
           return @"iPad (4th generation)";
        if([phoneType  isEqualToString:@"iPad3,5"])
           return @"iPad (4th generation)";
        if([phoneType  isEqualToString:@"iPad3,6"])
           return @"iPad (4th generation)";
        if([phoneType  isEqualToString:@"iPad6,11"])//ipad 5
           return @"iPad (5th generation)";
        if([phoneType  isEqualToString:@"iPad6,12"])
           return @"iPad (5th generation)";
        if([phoneType  isEqualToString:@"iPad7,5"])//ipad 6
           return @"iPad (6th generation)";
        if([phoneType  isEqualToString:@"iPad7,6"])
           return @"iPad (6th generation)";
        if([phoneType  isEqualToString:@"iPad7,11"])//ipad 7
           return @"iPad (7th generation)";
        if([phoneType  isEqualToString:@"iPad7,12"])
           return @"iPad (7th generation)";
        if([phoneType  isEqualToString:@"iPad11,6"])//ipad 8
           return @"iPad (8th generation))";
        if([phoneType  isEqualToString:@"iPad11,7"])
           return @"iPad (8th generation)";
        if([phoneType  isEqualToString:@"iPa12,1"])//ipad 9
           return @"iPad (9th generation)";
        if([phoneType  isEqualToString:@"iPad12,2"])
           return @"iPad (9th generation)";
        if([phoneType  isEqualToString:@"iPad4,1"])//iPad Air
           return @"iPad Air";
        if([phoneType  isEqualToString:@"iPad4,2"])
           return @"iPad Air";
        if([phoneType  isEqualToString:@"iPad4,3"])
           return @"iPad Air";
        if([phoneType  isEqualToString:@"iPad5,3"])//iPad Air 2
           return @"iPad Air 2";
        if([phoneType  isEqualToString:@"iPad5,4"])
           return @"iPad Air 2";
        if([phoneType  isEqualToString:@"iPad11,3"])//iPad Air (3rd generation)
           return @"Pad Air (3rd generation)";
        if([phoneType  isEqualToString:@"iPad11,4"])
           return @"Pad Air (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,1"])//iPad Air (4th generation)
           return @"iPad Air (4th generation)";
        if([phoneType  isEqualToString:@"iPad13,2"])
           return @"iPad Air (4th generation)";
        if([phoneType  isEqualToString:@"iPad6,7"])//iPad Pro (12.9-inch)
           return @"iPad Pro (12.9-inch)";
        if([phoneType  isEqualToString:@"iPad6,8"])
           return @"iPad Pro (12.9-inch)";
        if([phoneType  isEqualToString:@"iPad6,3"])//iPad Pro (9.7-inch)
           return @"iPad Pro (9.7-inch)";
        if([phoneType  isEqualToString:@"iPad6,4"])
           return @"iPad Pro (9.7-inch)";
        if([phoneType  isEqualToString:@"iPad7,1"])//iPad Pro (12.9-inch) (2nd generation)
           return @"iPad Pro (12.9-inch) (2nd generation)";
        if([phoneType  isEqualToString:@"iPad7,2"])
           return @"iPad Pro (12.9-inch) (2nd generation)";
        if([phoneType  isEqualToString:@"iPad7,3"])//iPad Pro (10.5-inch)
           return @"iPad Pro (10.5-inch)";
        if([phoneType  isEqualToString:@"iPad7,4"])
           return @"iPad Pro (10.5-inch)";
        if([phoneType  isEqualToString:@"iPad7,3"])//iPad Pro (10.5-inch)
           return @"iPad Pro (10.5-inch)";
        if([phoneType  isEqualToString:@"iPad7,4"])
           return @"iPad Pro (10.5-inch)";
        if([phoneType  isEqualToString:@"iPad8,1"])//iPad Pro (11-inch)
           return @"iPad Pro (11-inch)";
        if([phoneType  isEqualToString:@"iPad8,2"])
           return @"iPad Pro (11-inch)";
        if([phoneType  isEqualToString:@"iPad8,3"])
           return @"iPad Pro (11-inch)";
        if([phoneType  isEqualToString:@"iPad8,4"])
           return @"iPad Pro (11-inch)";
        if([phoneType  isEqualToString:@"iPad8,5"])//iPad Pro (12.9-inch) (3rd generation)
           return @"iPad Pro (12.9-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad8,6"])
           return @"iPad Pro (12.9-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad8,7"])
           return @"iPad Pro (12.9-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad8,8"])
           return @"iPad Pro (12.9-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad8,9"])//iPad Pro (11-inch) (2nd generation)
           return @"iPad Pro (11-inch) (2nd generation)";
        if([phoneType  isEqualToString:@"iPad8,10"])
           return @"iPad Pro (11-inch) (2nd generation)";
        if([phoneType  isEqualToString:@"iPad8,11"])//iPad Pro (12.9-inch) (4th generation)
           return @"iPad Pro (12.9-inch) (4th generation)";
        if([phoneType  isEqualToString:@"iPad8,12"])
           return @"iPad Pro (12.9-inch) (4th generation)";
        if([phoneType  isEqualToString:@"iPad13,4"])//iPad Pro (11-inch) (3rd generation)
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,5"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,6"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,7"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,8"])//iPad Pro (12.9-inch) (5th generation)
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,9"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,10"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad13,11"])
           return @"iPad Pro (11-inch) (3rd generation)";
        if([phoneType  isEqualToString:@"iPad2,5"])//iPad mini
           return @"iPad mini";
        if([phoneType  isEqualToString:@"iPad2,6"])
           return @"iPad mini";
        if([phoneType  isEqualToString:@"iPad2,7"])
           return @"iPad mini";
        if([phoneType  isEqualToString:@"iPad4,4"])//iPad mini 2
           return @"iPad mini 2";
        if([phoneType  isEqualToString:@"iPad4,5"])
           return @"iPad mini 2";
        if([phoneType  isEqualToString:@"iPad4,6"])
           return @"iPad mini 2";
        if([phoneType  isEqualToString:@"iPad4,7"])//iPad mini 3
           return @"iPad mini 3";
        if([phoneType  isEqualToString:@"iPad4,8"])
           return @"iPad mini 3";
        if([phoneType  isEqualToString:@"iPad4,9"])
           return @"iPad mini 3";
        if([phoneType  isEqualToString:@"iPad5,1"])//iPad mini 4
           return @"iPad mini 4";
        if([phoneType  isEqualToString:@"iPad5,2"])
           return @"iPad mini 4";
        if([phoneType  isEqualToString:@"iPad11,1"])//iPad mini (5th generation)
           return @"iPad mini (5th generation)";
        if([phoneType  isEqualToString:@"iPad11,2"])
           return @"iPad mini (5th generation)";
        if([phoneType  isEqualToString:@"iPad14,1"])//iPad mini (6th generation)
           return @"iPad mini (6th generation)";
        if([phoneType  isEqualToString:@"iPod1,1"])//iPod touch
           return @"iPod touch";
        if([phoneType  isEqualToString:@"iPod2,1"])//iPod touch (2nd generation)
           return @"iPod touch (2nd generation)";
        if([phoneType  isEqualToString:@"iPod3,1"])//iPod touch (3rd generation)
           return @"iPod touch (3rd generation)";
        if([phoneType  isEqualToString:@"iPod4,1"])//iPod touch (4th generation)
           return @"iPod touch (4th generation)";
        if([phoneType  isEqualToString:@"iPod5,1"])//iPod touch (5th generation)
           return @"iPod touch (5th generation)";
        if([phoneType  isEqualToString:@"iPod7,1"])//iPod touch (6th generation)
           return @"iPod touch (6th generation)";
        if([phoneType  isEqualToString:@"iPod9,1"])//iPod touch (7th generation)
           return @"iPod touch (7th generation)";
     
        return @"Unknown";
    }
   
+ (NSString *)arcRandom16Str {
    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil]; //存放十个数，以备随机取
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:16];
    NSString *changeString = [[NSMutableString alloc] initWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        NSInteger index = arc4random() % ([changeArray count] - 1); //循环六次，得到一个随机数，作为下标值取数组里面的数放到一个可变字符串里，在存放到自身定义的可变字符串
        getStr = changeArray[index];
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr];
    }
    return changeString;
}

+(BOOL)isEnglish{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = arr.firstObject;
    if([languageName containsString:@"cn-"] || [languageName containsString:@"zh-Han"]){
        return NO;
    }else{
        return YES;
    }
}



- (void)lockCheck:(void (^)(BOOL success, NSError * __nullable error))reply boxUUID:(NSString *)boxUUID{
    
    [self getLocalAuthentication:^(BOOL success, NSError * _Nullable error) {
        reply(success,error);
    }boxUUID:boxUUID typeInt:4];
}

+(void)isBackupInComple{
    ESBackupApi *api = [ESBackupApi new];
    ESBackupInfoReq *infoReq = [[ESBackupInfoReq alloc] init];
    NSString *transId =  [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBackupID"];
    infoReq.transId = transId;
    [api spaceV1ApiBackupInfoPostWithBackupInfoReq:infoReq
                                 completionHandler:^(ESRspBackupInfoRsp *output, NSError *error) {
                                     if (!error) {
                                         if([output.code intValue] == 200){
                                             if(output.results.status.intValue == 3){
                                                 [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"backupInProgress"];
                                        
                                             }else{
                                                 [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"backupInProgress"];
                                             }
                                     }else{
                                         [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"backupInProgress"];
                                     }
                                }
    }
 ];
}


+(void)isRecoverComple{
    ESRestoreApi *api = [ESRestoreApi new];
    ESRestoreInfoReq *infoReq = [[ESRestoreInfoReq alloc] init];
    infoReq.transId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRecoverID"];

    [api spaceV1ApiRestoreInfoPostWithRestoreInfoReq:infoReq
                                   completionHandler:^(ESRspRestoreInfoRsp *output, NSError *error) {
        if (!error) {
            if([output.code intValue] == 200){
                if(output.results.status.intValue == 3){
                    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"reStoreInProgress"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reStoreInProgress"];
                }
            }
        }
   }];
}


-(void)savelockSwitchOpenLock:(NSString *)openLockStr{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"isOpenLockDic"];
    NSMutableDictionary *mulDic = [dic mutableCopy];
    if(mulDic.count < 1){
        mulDic = [NSMutableDictionary new];
    }
    [mulDic setObject:openLockStr forKey:ESBoxManager.activeBox.boxUUID];
    //openLockStr = dic[ESBoxManager.activeBox.boxUUID];
    [[NSUserDefaults standardUserDefaults] setObject:mulDic forKey:@"isOpenLockDic"];

}


-(NSString *)getLockSwitchOpenLock:(NSString *)boxUUID{
    NSString *openLockStr;
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"isOpenLockDic"];
    if(boxUUID.length > 0 ){
        openLockStr = dic[boxUUID];
    }else{
        openLockStr = dic[ESBoxManager.activeBox.boxUUID];
    }
    return openLockStr;
}


+(BOOL)isShowMsgTime:(NSString *) beginTime endTime:(NSString *) endTime{

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];

    //要注意格式一定要统一

    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];

    NSDate *beginD=[dateFormatter dateFromString:beginTime];

    NSDate *endD=[dateFormatter dateFromString:endTime];

    NSTimeInterval value=[endD timeIntervalSinceDate:beginD];

    //如果时间大于5分钟，5*60秒，则显示时间

    if (value>5*60) {

        return true;

    }

    return NO;

}



//获取当前时间yyyyMMddHHmmss

+(NSString *)getCurrentTime{

    NSDate *date=[[NSDate alloc]init];

    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];

    [formatter  setDateFormat:@"yyyyMMddHHmmss"];

    NSString *curTime=[formatter stringFromDate:date];

    return curTime;

}


- (void)getDataServiceApi {

    [ESNetworkRequestManager sendCallRequestWithServiceName:@"eulixspace-history-record-service"
                                                    apiName:@"history_record_add"                                                queryParams:@{@"userId" : ESBoxManager.clientUUID}
                                                     header:@{}
                                                       body:@{}
                                                  modelName:nil
                                               successBlock:^(NSInteger requestId, id  _Nullable response) {
        
      }
        failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"%@",response);
     }];
}

- (ESFeedbackImagItem * )addImageToTable:(UIImage *)image {
    NSString *fileName = [NSString stringWithFormat:@"feed_back_%zd.png", (NSInteger)NSDate.date.timeIntervalSince1970 * 1000];
    NSString *localPath = [NSString randomCacheLocationWithName:fileName];
    if (image.size.width > 1080) {
    CGSize size = CGSizeMake(1080, image.size.height / image.size.width * 1080);
    image = [image imageConvertToSize:size];
    }
    [UIImageJPEGRepresentation(image, 0.45) writeToFile:localPath.fullCachePath atomically:YES];
    ///ESFeedbackImagItem
    ESFeedbackImagItem *imageItem = [ESFeedbackImagItem new];
    imageItem.image = image;
    imageItem.name = fileName;
    imageItem.localPath = localPath.fullCachePath;
    return imageItem;
}

-(void)toWebFeedbackWithImage:(UIImage *)screenshotImage{
   
    
}


+ (NSInteger)compareVersion:(NSString *)version1 withVersion:(NSString *)version2 {
    NSArray *version1Array = [version1 componentsSeparatedByString:@"."];
    NSArray *version2Array = [version2 componentsSeparatedByString:@"."];
    NSInteger count = MAX(version1Array.count, version2Array.count);
    for (NSInteger i = 0; i < count; i++) {
        NSInteger num1 = i < version1Array.count ? [version1Array[i] integerValue] : 0;
        NSInteger num2 = i < version2Array.count ? [version2Array[i] integerValue] : 0;
        if (num1 < num2) {
            return -1;
        } else if (num1 > num2) {
            return 1;
        }
    }
    return 0;
}


+ (NSString *)miniAppKey:(NSString *)appid {
    NSString *key = [NSString stringWithFormat:@"%@-%@-%lu-%@",ESBoxManager.activeBox.boxUUID,ESBoxManager.activeBox.aoid,(unsigned long)ESBoxManager.activeBox.boxType,appid];
    return key;
}

@end
