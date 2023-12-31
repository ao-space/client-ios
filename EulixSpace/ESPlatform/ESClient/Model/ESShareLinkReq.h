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





@protocol ESShareLinkReq
@end

@interface ESShareLinkReq : ESObject


@property(nonatomic) BOOL autoFill;
/* 公开分享的提取码请传 0000 [optional]
 */
@property(nonatomic) NSString* extractedCode;

@property(nonatomic) NSArray<NSString*>* fileIds;

@property(nonatomic) NSNumber* sharePerson;

@property(nonatomic) NSNumber* validDay;

@end
