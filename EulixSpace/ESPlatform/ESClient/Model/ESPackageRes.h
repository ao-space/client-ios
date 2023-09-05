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





@protocol ESPackageRes
@end

@interface ESPackageRes : ESObject


@property(nonatomic) NSString* downloadUrl;
/* 是否强制更新 [optional]
 */
@property(nonatomic) NSNumber* isForceUpdate;

@property(nonatomic) NSString* md5;
/* 兼容的最小App版本,用于box版本 [optional]
 */
@property(nonatomic) NSString* minAndroidVersion;
/* 所需的最小盒子版本,用于app版本 [optional]
 */
@property(nonatomic) NSString* minBoxVersion;
/* 兼容的最小App版本,用于box版本 [optional]
 */
@property(nonatomic) NSString* minIOSVersion;
/* 软件包标识符 [optional]
 */
@property(nonatomic) NSString* pkgName;

@property(nonatomic) NSNumber* pkgSize;
/* 软件包类型 [optional]
 */
@property(nonatomic) NSString* pkgType;
/* 软件包版本 [optional]
 */
@property(nonatomic) NSString* pkgVersion;
/* 版本特性 [optional]
 */
@property(nonatomic) NSString* updateDesc;

@property(nonatomic) NSNumber* restart; //boolean 是否需要重启

@end
