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


#import "ESPasswdTryInfo.h"
@protocol ESPasswdTryInfo;
@class ESPasswdTryInfo;



@protocol ESResponseBasePasswdTryInfo
@end

@interface ESResponseBasePasswdTryInfo : ESObject

/* 返回码 [optional]
 */
@property(nonatomic) NSString* code;
/* 错误信息 [optional]
 */
@property(nonatomic) NSString* message;
/* 请求标识，用于跟踪业务请求过程。 [optional]
 */
@property(nonatomic) NSString* requestId;

@property(nonatomic) ESPasswdTryInfo* results;

@end
