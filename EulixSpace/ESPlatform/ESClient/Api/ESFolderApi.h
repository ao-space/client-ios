#import <Foundation/Foundation.h>
#import "ESCreateFolderReq.h"
#import "ESRspFileInfo.h"
#import "ESRspFolderInfo.h"
#import "ESApi.h"

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



@interface ESFolderApi: NSObject <ESApi>

extern NSString* kESFolderApiErrorDomain;
extern NSInteger kESFolderApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 创建文件夹接口
/// 创建文件夹
///
/// @param createFolderReq 创建文件夹请求参数
/// 
///  code:200 message:"返回值"
///
/// @return ESRspFileInfo*
-(NSURLSessionTask*) spaceV1ApiFolderCreatePostWithCreateFolderReq: (ESCreateFolderReq*) createFolderReq
    completionHandler: (void (^)(ESRspFileInfo* output, NSError* error)) handler;


/// 文件夹详情接口
/// 文件夹详情包括文件夹大小
///
/// @param uuid 文件夹uuid
/// 
///  code:200 message:"返回值"
///
/// @return ESRspFolderInfo*
-(NSURLSessionTask*) spaceV1ApiFolderInfoGetWithUuid: (NSString*) uuid
    completionHandler: (void (^)(ESRspFolderInfo* output, NSError* error)) handler;



@end
