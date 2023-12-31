#import <Foundation/Foundation.h>
#import "ESRsp.h"
#import "ESRspStorage.h"
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



@interface ESUserApi: NSObject <ESApi>

extern NSString* kESUserApiErrorDomain;
extern NSInteger kESUserApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 删除用户空间
/// 删除元数据和文件
///
/// 
///  code:200 message:"返回值"
///
/// @return ESRsp*
-(NSURLSessionTask*) spaceV1ApiUserDeletePostWithCompletionHandler: 
    (void (^)(ESRsp* output, NSError* error)) handler;


/// 初始化用户空间元数据接口
/// 初始化默认文件夹和文件等
///
/// 
///  code:200 message:"返回值"
///
/// @return ESRsp*
-(NSURLSessionTask*) spaceV1ApiUserInitPostWithCompletionHandler: 
    (void (^)(ESRsp* output, NSError* error)) handler;


/// 用户空间使用
/// 用户空间使用量
///
/// @param targetUserId 要查看的用户id
/// 
///  code:200 message:"返回值"
///
/// @return ESRspStorage*
-(NSURLSessionTask*) spaceV1ApiUserStorageGetWithTargetUserId: (NSString*) targetUserId
    completionHandler: (void (^)(ESRspStorage* output, NSError* error)) handler;



@end
