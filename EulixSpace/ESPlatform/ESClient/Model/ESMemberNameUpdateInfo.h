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





@protocol ESMemberNameUpdateInfo
@end

@interface ESMemberNameUpdateInfo : ESObject

/* 被修改者的aoId 
 */
@property(nonatomic) NSString* aoId;
/* 需要修改的昵称 
 */
@property(nonatomic) NSString* nickName;

@end
