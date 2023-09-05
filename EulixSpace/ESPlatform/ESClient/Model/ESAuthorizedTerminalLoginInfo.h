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





@protocol ESAuthorizedTerminalLoginInfo
@end

@interface ESAuthorizedTerminalLoginInfo : ESObject

/* 更新业务接口访问 token 的 token。 
 */
@property(nonatomic) NSString* refreshToken;
/* 盒子公钥加密的临时密钥，用来解密后续返回的对称传输密钥。 
 */
@property(nonatomic) NSString* tmpEncryptedSecret;

@end
