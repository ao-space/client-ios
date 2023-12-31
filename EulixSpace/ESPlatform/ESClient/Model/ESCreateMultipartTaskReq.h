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





@protocol ESCreateMultipartTaskReq
@end

@interface ESCreateMultipartTaskReq : ESObject


@property(nonatomic) NSString* betag;
/* 业务来源id， 默认为0， 1-来源相册同步 [optional]
 */
@property(nonatomic) NSNumber* businessId;

@property(nonatomic) NSNumber* createTime;

@property(nonatomic) NSString* fileName;

@property(nonatomic) NSString* folderId;

@property(nonatomic) NSString* folderPath;

@property(nonatomic) NSString* mime;

@property(nonatomic) NSNumber* modifyTime;

@property(nonatomic) NSNumber* size;

@property(nonatomic) NSNumber* albumId;

@end
