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





@protocol ESClientRegistryResetInfo
@end

@interface ESClientRegistryResetInfo : ESObject

/* 盒子的 UUID 
 */
@property(nonatomic) NSString* boxUUID;
/* 客户端的注册码 
 */
@property(nonatomic) NSString* clientRegKey;
/* 客户端的 UUID 
 */
@property(nonatomic) NSString* clientUUID;
/* 用户的 ID 
 */
@property(nonatomic) NSString* userId;

@end
