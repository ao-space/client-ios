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





@protocol ESReservedDomainInfo
@end

@interface ESReservedDomainInfo : ESObject

/* 规则描述 [optional]
 */
@property(nonatomic) NSString* desc;
/* 正则表达式 [optional]
 */
@property(nonatomic) NSString* regex;
/* 条目id [optional]
 */
@property(nonatomic) NSNumber* regexId;
/* 更新时间 [optional]
 */
@property(nonatomic) NSDate* updatedAt;

@end
