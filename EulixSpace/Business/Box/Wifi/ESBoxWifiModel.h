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
//  ESBoxWifiModel.h
//  EulixSpace
//
//  Created by dazhou on 2022/11/28.
//  Copyright © 2022 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESBindInitResp.h"
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESBoxWifiModel : NSObject
@property (nonatomic, strong) NSMutableArray<ESBindNetworkModel *> * connectList;
@property (nonatomic, strong) NSMutableArray<ESBindNetworkModel *> * availableList;

- (BOOL)hasDetail;
@end


@interface ESBoxNetworkAdapterModel : NSObject
//网卡名称(获取网络信息: 返回; 其他: 不传;)
@property (nonatomic, strong) NSString * adapterName;
//是否已连接，不表示能连互联网，仅仅表示是否有WiFi连接或者有线连接
@property (nonatomic, assign) BOOL connected;
//默认网关 (获取网络信息: 返回; 其他: 不传;)(获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * defaultGateway;
//ipv4 地址(获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * ipv4;
//ipv4 使用 dhcp 自动获取 (获取网络信息: 返回; 其他: 必传;)
@property (nonatomic, assign) BOOL ipv4UseDhcp;
// 端口号
@property (nonatomic, assign) long port;
//ipv6 地址(获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * ipv6;
//ipv6 默认网关 (获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * ipv6DefaultGateway;
//ipv6 使用 dhcp 自动获取(获取网络信息: 返回; 其他: 必传;)
@property (nonatomic, assign) BOOL ipv6UseDhcp;
//网卡地址(不是路由器的网络地址) (获取网络信息: 返回; 其他: 不传;)
@property (nonatomic, strong) NSString * mACAddress;
//子网掩码 (获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * subNetMask;
//子网前缀长度 (获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 可选; 有线时修改配置: 必传;)
@property (nonatomic, strong) NSString * subNetPreLen;
//路由器无线网络地址(不是盒子网卡地址)。有线连接时为空串。 (获取网络信息: 不返回; 无线连上修改配置: 不传; 无线未连上修改配置: 必传; 有线时修改配置: 不传;)
@property (nonatomic, strong) NSString * wIFIAddress;
//WIFI名称。有线连接时为空串。 (获取网络信息: 返回; 无线连上修改配置: 必传; 无线未连上修改配置: 必传; 有线时修改配置: 不传;)
@property (nonatomic, strong) NSString * wIFIName;
//WIFI密码。有线连接时为空串。 (获取网络信息: 不返回; 无线连上修改配置: 不传; 无线未连上修改配置: 必传; 有线时修改配置: 不传;)
@property (nonatomic, strong) NSString * wIFIPassword;
//有线还是无线网卡。 true: 有线; false: 无线。 (获取网络信息: 返回; 其他: 必传;)
@property (nonatomic, assign) BOOL wired;

@end

@interface ESBoxNetworkStatusModel : NSObject
//ipv4 dNS1 地址
@property (nonatomic, strong) NSString * dNS1;
//ipv4  地址
@property (nonatomic, strong) NSString * dNS2;
//是否可以访问互联网
@property (nonatomic, assign) BOOL internetAccess;
//ipv6 dNS1 地址
@property (nonatomic, strong) NSString * ipv6DNS1;
//ipv6 dNS2 地址
@property (nonatomic, strong) NSString * ipv6DNS2;

@property (nonatomic, strong) NSMutableArray<ESBoxNetworkAdapterModel *> * networkAdapters;
@end

@interface ESBoxNetworkConfigResp : ESBaseResp
@property (nonatomic, strong) ESBoxNetworkStatusModel * results;
@end



// 网络配置接口请求定义
@interface ESBoxNetworkConfigReq : NSObject
//ipv4 dNS1 地址
@property (nonatomic, strong) NSString * dNS1;
//ipv4 dNS2 地址
@property (nonatomic, strong) NSString * dNS2;
//ipv6 dNS1 地址
@property (nonatomic, strong) NSString * ipv6DNS1;
//ipv6 dNS2 地址
@property (nonatomic, strong) NSString * ipv6DNS2;

@property (nonatomic, assign) BOOL internetAccess;
//网络适配器列表
@property (nonatomic, strong) NSMutableArray<ESBoxNetworkAdapterModel *> * networkAdapters;
@end


@interface ESBoxNetRowModel : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * value;
@property (nonatomic, assign) BOOL hasArrow;
@property (nonatomic, assign) BOOL hasLine;
@property (nonatomic, assign) BOOL firstRow;
@property (nonatomic, assign) BOOL lastRow;

@property (nonatomic, assign) BOOL canJoinNet;
@property (nonatomic, assign) BOOL canIgnoreNet;

@property (nonatomic, copy) void (^onRowClickBlock)(void);


@property (nonatomic, assign) BOOL isDhcpSelectedType;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString * placeholderString;
// 记录 UITextField 输入的值
@property (nonatomic, strong) NSString * inputValue;

@property (nonatomic, copy) void (^onEditBlock)(NSString * value);
@end

@interface ESBoxNetSectionModel : NSObject
@property (nonatomic, strong) NSString * sectionTitle;
@property (nonatomic, strong) NSMutableArray<ESBoxNetRowModel *> * rowList;
@end


@interface ESBoxNetEditModel : NSObject
@property (nonatomic, assign) BOOL ipv4UseDhcp;

@property (nonatomic, strong) NSString * ipv4;
@property (nonatomic, strong) NSString * subNetMask;
@property (nonatomic, strong) NSString * defaultGateway;
@property (nonatomic, strong) NSString * dns1;
@property (nonatomic, strong) NSString * dns2;

@property (nonatomic, copy) void (^canDoneBlock)(BOOL done);
- (void)checkIfDone;
@end




NS_ASSUME_NONNULL_END
