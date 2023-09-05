#import <Foundation/Foundation.h>
#import "ESObject.h"

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


#import "ESAlgorithmConfig.h"
@protocol ESAlgorithmConfig;
@class ESAlgorithmConfig;



@protocol ESEncryptAuthDTO
@end

@interface ESEncryptAuthDTO : ESObject

/* 业务接口访问 token。 [optional]
 */
@property(nonatomic) NSString* accessToken;

@property(nonatomic) ESAlgorithmConfig* algorithmConfig;
/* 临时密钥(tmpEncryptedSecret) 加密的 aoid [optional]
 */
@property(nonatomic) NSString* aoid;
/* 是否自动登录。 [optional]
 */
@property(nonatomic) NSNumber* autoLogin;
/* 自动登录的到期时间。 [optional]
 */
@property(nonatomic) NSString* autoLoginExpiresAt;
/* 临时密钥(tmpEncryptedSecret) 加密的 box name [optional]
 */
@property(nonatomic) NSString* boxName;
/* 临时密钥(tmpEncryptedSecret) 加密的 box uuid [optional]
 */
@property(nonatomic) NSString* boxUUID;
/* 用于业务数据传输的对等密钥，该字段临时对称密钥加密，解密时使用请求时的临时密钥加上algorithmConfig里的动态iv [optional]
 */
@property(nonatomic) NSString* encryptedSecret;
/* 业务接口访问 token 的到期时间，该字段是一个字符串，格式为：2007-12-03T10:15:30+01:00[Europe/Paris]。 [optional]
 */
@property(nonatomic) NSString* expiresAt;
/* 业务接口访问 token 的到期时间，该字段是一个长整型，具体表示从 unix 纪元（1970-01-01T00:00:00Z）开始的秒数。 [optional]
 */
@property(nonatomic) NSNumber* expiresAtEpochSeconds;
/* 用于更新业务接口 token 的 token，该 token 本身也会被更新。 [optional]
 */
@property(nonatomic) NSString* refreshToken;
/* 请求标识，用于跟踪业务请求过程。 [optional]
 */
@property(nonatomic) NSString* requestId;

@end
