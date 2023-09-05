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





@protocol ESMemberCreateResult
@end

@interface ESMemberCreateResult : ESObject

/* 用户aoId [optional]
 */
@property(nonatomic) NSString* aoId;
/* 随机32位密钥 [optional]
 */
@property(nonatomic) NSString* authKey;
/* 用户clientUUID [optional]
 */
@property(nonatomic) NSString* clientUUID;
/* 用户userdomain [optional]
 */
@property(nonatomic) NSString* userDomain;
/* 用户userid [optional]
 */
@property(nonatomic) NSString* userid;

@end
