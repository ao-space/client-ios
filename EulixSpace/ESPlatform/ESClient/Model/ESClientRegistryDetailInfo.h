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





@protocol ESClientRegistryDetailInfo
@end

@interface ESClientRegistryDetailInfo : ESObject

/* 客户端UUID [optional]
 */
@property(nonatomic) NSString* clientUUID;
/* 创建时间 [optional]
 */
@property(nonatomic) NSDate* createdAt;
/* 注册类型 [optional]
 */
@property(nonatomic) NSString* userType;

@end
