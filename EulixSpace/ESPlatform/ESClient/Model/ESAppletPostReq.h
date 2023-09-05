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





@protocol ESAppletPostReq
@end

@interface ESAppletPostReq : ESObject

/* 小程序名字 [optional]
 */
@property(nonatomic) NSString* appletName;
/* 小程序英文名 [optional]
 */
@property(nonatomic) NSString* appletNameEn;
/* applet_size [optional]
 */
@property(nonatomic) NSNumber* appletSize;
/* 小程序version [optional]
 */
@property(nonatomic) NSString* appletVersion;
/* categories,小程序所需求的权限，以逗号分割 [optional]
 */
@property(nonatomic) NSString* categories;
/* down_url [optional]
 */
@property(nonatomic) NSString* downUrl;
/* icon_url [optional]
 */
@property(nonatomic) NSString* iconUrl;
/* 是否强制更新 [optional]
 */
@property(nonatomic) NSNumber* isForceUpdate;
/* md5 
 */
@property(nonatomic) NSString* md5;
/* 兼容盒子最小版本 [optional]
 */
@property(nonatomic) NSString* minCompatibleBoxVersion;
/* 小程序发布状态 [optional]
 */
@property(nonatomic) NSNumber* state;
/* update_desc [optional]
 */
@property(nonatomic) NSString* updateDesc;

@end
