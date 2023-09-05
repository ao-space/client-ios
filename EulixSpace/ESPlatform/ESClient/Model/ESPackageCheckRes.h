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


#import "ESPackageRes.h"
@protocol ESPackageRes;
@class ESPackageRes;



@protocol ESPackageCheckRes
@end

@interface ESPackageCheckRes : ESObject

/* app是否需要关联更新 [optional]
 */
@property(nonatomic) NSNumber* isAppNeedUpdate;
/* box是否需要关联更新 [optional]
 */
@property(nonatomic) NSNumber* isBoxNeedUpdate;

@property(nonatomic) ESPackageRes* latestAppPkg;

@property(nonatomic) ESPackageRes* latestBoxPkg;
/* 是否存在更新 [optional]
 */
@property(nonatomic) NSNumber* varNewVersionExist;

@end