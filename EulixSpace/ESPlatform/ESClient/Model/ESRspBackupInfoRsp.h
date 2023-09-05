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


#import "ESBackupInfoRsp.h"
@protocol ESBackupInfoRsp;
@class ESBackupInfoRsp;



@protocol ESRspBackupInfoRsp
@end

@interface ESRspBackupInfoRsp : ESObject

/* 回应错误码 [optional]
 */
@property(nonatomic) NSNumber* code;
/* 错误描述信息 [optional]
 */
@property(nonatomic) NSString* message;
/* 事务id [optional]
 */
@property(nonatomic) NSString* requestId;

@property(nonatomic) ESBackupInfoRsp* results;

@end
