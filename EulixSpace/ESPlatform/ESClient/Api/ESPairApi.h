#import <Foundation/Foundation.h>
#import "ESBaseRspStr.h"
#import "ESKeyExchangeReq.h"
#import "ESPairingReq.h"
#import "ESPasswordInfo.h"
#import "ESPubKeyExchangeReq.h"
#import "ESResetClientReq.h"
#import "ESRevokReq.h"
#import "ESRspInitResult.h"
#import "ESRspKeyExchangeRsp.h"
#import "ESRspMicroServerRsp.h"
#import "ESRspPubKeyExchangeRsp.h"
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



@interface ESPairApi: NSObject <ESApi>

extern NSString* kESPairApiErrorDomain;
extern NSInteger kESPairApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 触发盒子端初始化,阻塞式接口 [客户端调用]
/// 盒子端初始化查询接口。主要此接口是同步返回，也就是初始化结束后该接口才会返回。
///
/// @param passwordInfo 管理员密码.
/// 
///  code:200 message:"code=AG-200 成功."
///
/// @return ESRspMicroServerRsp*
-(NSURLSessionTask*) initialWithPasswordInfo: (ESPasswordInfo*) passwordInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler;


/// 对称密钥交换 [客户端调用]
/// App向盒子请求生成对称密钥 示例数据:
///
/// @param keyExchangeReq {clientPreSecret:必填,客户端对称密钥种子. 客户端生成随机字符串，32个字符,encBtid:必填,使用盒子端公钥加密btid后进行base64得到的字符串}
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspKeyExchangeRsp*
-(NSURLSessionTask*) keyExchangeWithKeyExchangeReq: (ESKeyExchangeReq*) keyExchangeReq
    completionHandler: (void (^)(ESRspKeyExchangeRsp* output, NSError* error)) handler;


/// APP调用进行管理员解绑 [客户端调用]
/// 客户端通过HTTP调用此接口来解绑管理员. Results 内部是网关的 revoke 接口返回的原样数据.
///
/// @param revokReq 盒子的安全密码
/// 
///  code:200 message:"OK"
///
/// @return ESRspMicroServerRsp*
-(NSURLSessionTask*) pairAdminRevokeWithRevokReq: (ESRevokReq*) revokReq
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler;


/// 盒子有线配对初始请求 [客户端调用]
/// 有线配对的初始状态请求
///
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspInitResult*
-(NSURLSessionTask*) pairInitWithCompletionHandler: 
    (void (^)(ESRspInitResult* output, NSError* error)) handler;


/// App与盒子端配对接口 [客户端调用]
/// App与盒子端配对接口 返回 result 经过以下处理 based64.decode -> aes.decrypt -> PairingBoxInfo
///
/// @param pairingBoxInfo 客户端传入盒子的配对数据
/// 
///  code:200 message:"code=200 成功; 410 表示clientUuid已经被注册未成员.不可以再作为管理员来注册"
///
/// @return ESRspMicroServerRsp*
-(NSURLSessionTask*) pairingWithPairingBoxInfo: (ESPairingReq*) pairingBoxInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler;


/// 公钥交换 [客户端调用]
/// App向盒子发送公钥 示例数据:
///
/// @param pubKeyExchangeReq {clientPubKey:必填,客户端公钥, clientPriKey:选填,客户端私钥(仅调试使用)}
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspPubKeyExchangeRsp*
-(NSURLSessionTask*) pubKeyExchangeWithPubKeyExchangeReq: (ESPubKeyExchangeReq*) pubKeyExchangeReq
    completionHandler: (void (^)(ESRspPubKeyExchangeRsp* output, NSError* error)) handler;


/// 清除盒子端的已配对数据 [客户端调用]
/// Reset pairing data
///
/// @param request 客户端私钥签名(预留字段, 暂时不验证。 调用者可传入任意字符串,但不可为空)
/// 
///  code:200 message:"code=AG-200 成功; AG-462 尚未配对,无需重置;"
///
/// @return ESBaseRspStr*
-(NSURLSessionTask*) resetWithRequest: (ESResetClientReq*) request
    completionHandler: (void (^)(ESBaseRspStr* output, NSError* error)) handler;


/// 设置管理员密码 [客户端调用]
/// App设置管理员密码 示例数据:
///
/// @param passwordInfo 管理员密码
/// 
///  code:200 message:"code=AG-200 成功;"
///
/// @return ESRspMicroServerRsp*
-(NSURLSessionTask*) setpasswordWithPasswordInfo: (ESPasswordInfo*) passwordInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler;



@end