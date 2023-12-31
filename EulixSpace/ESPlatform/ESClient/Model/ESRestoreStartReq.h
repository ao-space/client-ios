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





@protocol ESRestoreStartReq
@end

@interface ESRestoreStartReq : ESObject


@property(nonatomic) NSString* boxId;

@property(nonatomic) NSString* restoreDataType;

@property(nonatomic) NSString* restoreFolder;
/* 传入用户的userId，不选择就传入所有的用户userId [optional]
 */
@property(nonatomic) NSString* restoreUser;

@property(nonatomic) NSString* secPass;
/* 处理策略（替换replace，跳过skip，合并combine） [optional]
 */
@property(nonatomic) NSString* strategy;


@end
