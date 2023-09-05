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





@protocol ESResponseBase1
@end

@interface ESResponseBase1 : ESObject

/* 返回码，格式为 GW-xxx。 [optional]
 */
@property(nonatomic) NSString* code;
/* 错误信息中的上下文信息，用于通过 MessageFormat 格式化 message。 [optional]
 */
@property(nonatomic) NSArray<NSObject*>* context;
/* 错误信息，格式为 MessageFormat： {0} xx {1}， 参考：https://docs.oracle.com/javase/8/docs/api/java/text/MessageFormat.html 。 [optional]
 */
@property(nonatomic) NSString* message;
/* 请求标识 id，用于跟踪业务请求过程。 [optional]
 */
@property(nonatomic) NSString* requestId;

@property(nonatomic) NSObject* results;

@end
