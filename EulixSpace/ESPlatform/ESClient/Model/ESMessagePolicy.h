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





@protocol ESMessagePolicy
@end

@interface ESMessagePolicy : ESObject

/* 可选，消息过期时间，其值不可小于发送时间或者startTime。如果不填写此参数，默认为3天后过期。格式: YYYY-MM-DD hh:mm:ss [optional]
 */
@property(nonatomic) NSString* expireTime;
/* 可选，定时发送时，若不填写表示立即发送。格式: YYYY-MM-DD hh:mm:ss [optional]
 */
@property(nonatomic) NSString* startTime;

@end