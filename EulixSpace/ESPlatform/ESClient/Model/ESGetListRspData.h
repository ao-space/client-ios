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


#import "ESFileInfoPub.h"
#import "ESPageInfoExt.h"
@protocol ESFileInfoPub;
@class ESFileInfoPub;
@protocol ESPageInfoExt;
@class ESPageInfoExt;



@protocol ESGetListRspData
@end

@interface ESGetListRspData : ESObject


@property(nonatomic) NSArray<ESFileInfoPub>* fileList;

@property(nonatomic) ESPageInfoExt* pageInfo;

@end
