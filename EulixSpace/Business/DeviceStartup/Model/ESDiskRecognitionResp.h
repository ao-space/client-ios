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
//  ESDiskRecognitionResp.h
//  EulixSpace
//
//  Created by dazhou on 2022/10/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import "ESBaseResp.h"
#import "ESBoxItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ESDiskStorageEnum) {
    ESDiskStorage_UnKnown = -1,
    ESDiskStorage_Disk1 = 1, // 磁盘 1
    ESDiskStorage_Disk2 = 2, // 磁盘 2
    ESDiskStorage_SSD = 101, // SSD
};

//磁盘扩容状态
typedef NS_ENUM(NSUInteger, ESDiskExpandStatus) {
    ESDiskExpandStatusNormal = 1, // 扩容完成
    ESDiskExpandStatusNotExpand = 2, // 未扩容状态;
    ESDiskExpandStatusExpanding = 3, // 正在扩容;

    ESDiskExpandStatusError = 100, // 扩容未知错误
    ESDiskExpandStatusFormatError = 101, // 扩容磁盘格式化错误; >101: 扩容其他错误;
};

typedef NS_ENUM(NSUInteger, ESDiskStorageModeType) {
    ESDiskStorageModeType_UnKnown = 0,
    ESDiskStorageModeType_Normal = 1, // normal
    ESDiskStorageModeType_Raid = 2, // raid 1
};

typedef NS_ENUM(NSUInteger, ESDiskEncryptType) {
    ESDiskEncryptType_Encrypt = 1, // 加密
    ESDiskEncryptType_UnEncrypt = 2, // 不加密
};


typedef NS_ENUM(NSUInteger, ESDiskExceptionType) {
    ESDiskExceptionType_Normal = 0, // 磁盘正常
    ESDiskExceptionType_Absent = 1, // 不存在(磁盘格式化后，被拔出后的返回状态)
    ESDiskExceptionType_Expand = 10, // 新接入磁盘(待扩容)
    ESDiskExceptionType_Expanding = 11, // 新接入磁盘(正在扩容)
    ESDiskExceptionType_ExpandError = 12, // 新接入磁盘(扩容失败)
    
    ESDiskExceptionType_Miss = 1010, // 不存在(磁盘格式化时就没有该磁盘，本地显示用的，因为这种场景下，磁盘列表接口没有返回该磁盘的占位信息，需要前端自己处理）
};



@interface ESDiskInfoModel : NSObject

// sata硬盘总线号码. 1: in sata 0; 2: in sata 4; 3: in sata 8; 101: m.2;
@property (nonatomic, assign) ESDiskStorageEnum busNumber;
@property (nonatomic, strong) NSString * deviceModel;

// 设备名称
@property (nonatomic, strong) NSString * deviceName;
// 服务端用来给前端展示的设备名称，避免不同存储设备之间取的字段不同
@property (nonatomic, strong) NSString * displayName;

@property (nonatomic, assign) ESDiskExceptionType diskException;
// 业务层标记为：选择磁盘进行扩容
@property (nonatomic, assign) BOOL isSelected4Expand;

// 磁盘唯一id (格盘后会变化)
@property (nonatomic, strong) NSString * diskUniId;

// 生成的硬件id (格盘后不会变化). HASH(Model Family + Device Model + Model Number + Serial Number)
@property (nonatomic, strong) NSString * hwId;
@property (nonatomic, strong) NSString * modelFamily;
@property (nonatomic, strong) NSString * modelNumber;

// 分区名称
@property (nonatomic, strong) NSMutableArray<NSString *> * partedNames;

// 分区唯一id (格盘后会变化)
@property (nonatomic, strong) NSMutableArray<NSString *> * partedUniIds;

@property (nonatomic, strong) NSString * serialNumber;

// 磁盘空间总容量。 单位: 字节(Byte)
@property (nonatomic, assign) long spaceTotal;
// 磁盘空间使用大小。单位: 字节(Byte)
@property (nonatomic, assign) long spaceUsage;
// 磁盘空间剩余大小。单位: 字节(Byte)
@property (nonatomic, assign) long spaceAvailable;
// 磁盘空间使用百分比, 含百分号。
@property (nonatomic, strong) NSString * spaceUsePercent;

/**
 传输类型 1: usb, 2: sata, 3: nvme
 目前根据这个字段来判断 1:磁盘 1，2:磁盘 2， 3: SSD，等拿到真实的板子后，可能有变动
 */
@property (nonatomic, assign) long transportType;

// 初始化是否失败，业务自己用的，不是服务传的
@property (nonatomic, assign) ESDiskInitStatus diskInitStatus;
// 扩容是否失败，业务自己用的，不是服务传的
@property (nonatomic, assign) ESDiskExpandStatus diskExpandStatus;

//
/**
 1： 磁盘 1；  2：磁盘 2；  101：ssd
 */
- (ESDiskStorageEnum)getDiskStorageEnum;
- (NSString *)getDiskName;
// 获取显示的名称、型号之类的内容
- (NSString *)getDiskShowText;
// 判断当前存储是否可以扩容
- (BOOL)canExpand;
// 获取磁盘类型，比如 HDD/SSD
- (NSString *)getDiskType;

+ (NSString *)getDiskPhysicalName:(ESDiskStorageEnum)busNumber;
@end

@interface ESDiskListModel : NSObject
@property (nonatomic, assign) ESDiskStorageModeType raidType;

@property (nonatomic, strong) NSMutableArray<ESDiskInfoModel *> * diskInfos;

- (BOOL)hasDisk:(ESDiskStorageEnum)num;
- (ESDiskInfoModel *)getDiskInfo:(ESDiskStorageEnum)num;

@end

@interface ESDiskRecognitionResp : ESBaseResp
@property (nonatomic, strong) ESDiskListModel * results;
@end


@interface ESSpaceReadyCheckResultModel : NSObject


@property (nonatomic, assign) ESDiskInitStatus diskInitialCode;
// 缺少主存储
@property (nonatomic, assign) BOOL missingMainStorage;
// 0: 已经绑定; 1: 新盒子; 2: 已解绑
@property (nonatomic, assign) long paired;

@end

@interface ESSpaceReadyCheckResp : ESBaseResp
@property (nonatomic, strong) ESSpaceReadyCheckResultModel * results;
@end


@interface ESDiskInitializeProgressModel : NSObject

@property (nonatomic, assign) ESDiskInitStatus initialCode;
//初始化正常或异常错误信息。
@property (nonatomic, strong) NSString * initialMessage;
//磁盘初始化进度。
@property (nonatomic, assign) long initialProgress;

- (NSString *)toString;
@end

@interface ESDiskInitializeProgressResp : ESBaseResp
@property (nonatomic, strong) ESDiskInitializeProgressModel * results;
@end


@interface ESDiskInitializeReq : NSObject
// 磁盘加密与否。 1: 加密; 2: 不加密
@property (nonatomic, assign) ESDiskEncryptType diskEncrypt;
// 主存储磁盘硬件 id 列表。
@property (nonatomic, strong) NSMutableArray<NSString *> * primaryStorageHwIds;
// 参与 raid 的磁盘硬件 id 列表.
@property (nonatomic, strong) NSMutableArray<NSString *> * raidDiskHwIds;
// 次存储磁盘硬件 id 列表
@property (nonatomic, strong) NSMutableArray<NSString *> * secondaryStorageHwIds;
// 1: normal; 2: raid1。 对应 ESDiskStorageModeType
@property (nonatomic, assign) ESDiskStorageModeType raidType;


- (void)clearAllHwIds;
@end


@interface ESDiskManagementModel : NSObject
//主存储磁盘硬件 id 列表
@property (nonatomic, strong) NSMutableArray<NSString *> * PrimaryStorageHwIds;
@property (nonatomic, strong) NSString * createdTime;
@property (nonatomic, assign) ESDiskEncryptType diskEncrypt;

@property (nonatomic, assign) ESDiskExpandStatus diskExpandCode;
//磁盘扩容结果/异常信息
@property (nonatomic, strong) NSString * diskExpandMessage;
// 磁盘扩容进度。
@property (nonatomic, assign) long diskExpandProgress;

@property (nonatomic, assign) ESDiskInitStatus diskInitialCode;
//磁盘初始化结果/异常信息。
@property (nonatomic, strong) NSString * diskInitialMessage;
//磁盘初始化进度。
@property (nonatomic, assign) long diskInitialProgress;
@property (nonatomic, strong) NSMutableArray<ESDiskInfoModel *> * diskManageInfos;
//是否缺失主存储
@property (nonatomic, assign) BOOL isMissingMainStorage;
//主存储挂载目录
@property (nonatomic, strong) NSString * rimaryStorageMountPaths;
// 主存储挂载目录
@property (nonatomic, strong) NSString * primaryStorageMountPaths;

// 主存储磁盘硬件 id 列表。
@property (nonatomic, strong) NSMutableArray<NSString *> * primaryStorageHwIds;
// 参与 raid 的磁盘硬件 id 列表.
@property (nonatomic, strong) NSMutableArray<NSString *> * raidDiskHwIds;
// 次存储磁盘硬件 id 列表
@property (nonatomic, strong) NSMutableArray<NSString *> * secondaryStorageHwIds;
// 1: normal; 2: raid1。 对应 ESDiskStorageModeType
@property (nonatomic, assign) ESDiskStorageModeType raidType;
//次存储挂载目录
@property (nonatomic, strong) NSMutableArray<NSString *> * secondaryStorageMountPaths;

// 更新时间
@property (nonatomic, strong) NSString * updatedTime;

@end

@interface ESDiskManagementListResp : ESBaseResp
@property (nonatomic, strong) ESDiskManagementModel * results;
@end



@interface ESRaidInfoModel : NSObject
//同步结果. 0: 正在同步; 1: 同步完成; 其他: 同步出错
@property (nonatomic, assign) int copyResult;
//raid 同步进度百分比
@property (nonatomic, assign) float copyPercent;
// raid 类型. 1: normal; 2: raid1。
@property (nonatomic, assign) ESDiskStorageModeType raidType;
@end



@interface ESDiskManagementExpandReq : NSObject
// 参与 raid 的磁盘硬件 id 列表
@property (nonatomic, strong) NSMutableArray<NSString *> * raidDiskHwIds;
// 1: normal; 2: raid1。
@property (nonatomic, assign) ESDiskStorageModeType raidType;
// 新增的次存储磁盘硬件 id 列表
@property (nonatomic, strong) NSMutableArray<NSString *> * secondaryStorageHwIds;
@end


@interface ESDiskManagementExpandProgressModel : NSObject

@property (nonatomic, assign) ESDiskExpandStatus expandCode;
//扩容正常或异常错误信息。
@property (nonatomic, strong) NSString * expandMessage;
//磁盘扩容进度。
@property (nonatomic, assign) long expandProgress;

- (NSString *)toString;
@end

@interface ESDiskManagementExpandProgressResp : ESBaseResp
@property (nonatomic, strong) ESDiskManagementExpandProgressModel * results;
@end
NS_ASSUME_NONNULL_END
