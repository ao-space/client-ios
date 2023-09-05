#import <Foundation/Foundation.h>
#import "ESRspBoxDeviceInfo.h"
#import "ESRspNetwork.h"
#import "ESRspWifiListRsp.h"
#import "ESRspWifiStatusRsp.h"
#import "ESWifiPwdReq.h"
#import "ESApi.h"

/**
* EulixOS Platform Server API
* Platform open APIs
*
* OpenAPI spec version: 0.1.0
* Contact: dev-support@eulixos.com
*
* NOTE: This class is auto generated by the swagger code generator program.
* https://github.com/swagger-api/swagger-codegen.git
* Do not edit the class manually.
*/



@interface ESDeviceApi: NSObject <ESApi>

extern NSString* kESDeviceApiErrorDomain;
extern NSInteger kESDeviceApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 获取盒子设备信息 [微服务调用]
/// 通过此接口查看盒子设备信息
///
/// 
///  code:200 message:"code=0 成功;"
///
/// @return ESRspBoxDeviceInfo*
-(NSURLSessionTask*) infoWithCompletionHandler: 
    (void (^)(ESRspBoxDeviceInfo* output, NSError* error)) handler;


/// 获取盒子ip地址 [网关调用]
/// 通过此接口查看盒子ip地址
///
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspNetwork*
-(NSURLSessionTask*) pairNetLocalIpsDeviceWithCompletionHandler: 
    (void (^)(ESRspNetwork* output, NSError* error)) handler;


/// 获取盒子扫描到的wifi列表 [网关调用]
/// 获取盒子扫描到的wifi列表
///
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspWifiListRsp*
-(NSURLSessionTask*) pairNetNetConfigDeviceWithCompletionHandler: 
    (void (^)(ESRspWifiListRsp* output, NSError* error)) handler;


/// 设置wifi密码 [网关调用]
/// 设置wifi密码
///
/// @param req 需要连接的 wifi 名称和密码的json.
/// 
///  code:200 message:"code=AG-200 成功; code=AG-561 连接失败"
///
/// @return ESRspWifiStatusRsp*
-(NSURLSessionTask*) pairNetNetConfigSettingDeviceWithReq: (ESWifiPwdReq*) req
    completionHandler: (void (^)(ESRspWifiStatusRsp* output, NSError* error)) handler;



@end
