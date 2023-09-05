#import <Foundation/Foundation.h>
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



@interface ESNetApi: NSObject <ESApi>

extern NSString* kESNetApiErrorDomain;
extern NSInteger kESNetApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 获取盒子ip地址 [客户端调用]
/// 通过此接口查看盒子ip地址
///
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspNetwork*
-(NSURLSessionTask*) pairNetLocalIpsWithCompletionHandler: 
    (void (^)(ESRspNetwork* output, NSError* error)) handler;


/// 获取盒子扫描到的wifi列表 [客户端]
/// 获取盒子扫描到的wifi列表 [root@WENOS ~]# curl http://172.17.0.1:5680/agent/v1/api/device/netconfig { \"code\": \"AG-200\", \"message\": \"OK\", \"wifiInfos\": [ \"name\": \"ZFY_Wifi\", \"addr\": \"18:3C:B7:5F:D4:58\" }, { \"name\": \"TY-Wifi\", \"addr\": \"C4:2B:44:DC:A1:D0\" } ] }
///
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspWifiListRsp*
-(NSURLSessionTask*) pairNetNetConfigWithCompletionHandler: 
    (void (^)(ESRspWifiListRsp* output, NSError* error)) handler;


/// 设置wifi密码 [客户端]
/// 设置wifi密码 [root@WENOS ~]# curl -H \"Content-Type: application/json\" -X POST -d '{\"name\": \"18:3C:B7:5F:D4:8C\", \"password\":\"wrong_password\" }'  http://172.17.0.1:5680/agent/v1/api/device/netconfig {\"code\":\"AG-404\",\"message\":\"ConnectToWifi failed, []\"} [root@WENOS ~]# curl -H \"Content-Type: application/json\" -X POST -d '{\"name\": \"18:3C:B7:5F:D4:8C\", \"password\":\"wifi803b\" }'  http://172.17.0.1:5680/agent/v1/api/device/netconfig { \"code\": \"AG-200\", \"message\": \"OK\" }
///
/// @param req 需要连接的 wifi 名称和密码的json.
/// 
///  code:200 message:"code=AG-200 成功; code=AG-561 连接失败"
///
/// @return ESRspWifiStatusRsp*
-(NSURLSessionTask*) pairNetNetConfigSettingWithReq: (ESWifiPwdReq*) req
    completionHandler: (void (^)(ESRspWifiStatusRsp* output, NSError* error)) handler;



@end