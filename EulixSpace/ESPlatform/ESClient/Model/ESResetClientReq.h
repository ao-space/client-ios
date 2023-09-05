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





@protocol ESResetClientReq
@end

@interface ESResetClientReq : ESObject

/* 客户端签名数据 [optional]
 */
@property(nonatomic) NSString* hashed;
/* 客户端待签数据 [optional]
 */
@property(nonatomic) NSString* msg;

@end