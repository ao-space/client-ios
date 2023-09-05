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





@protocol ESMoveFileReq
@end

@interface ESMoveFileReq : ESObject

/* 目的路径的uuid [optional]
 */
@property(nonatomic) NSString* destPath;
/* 需要复制的文件的uuid列表 
 */
@property(nonatomic) NSArray<NSString*>* uuids;

@end
