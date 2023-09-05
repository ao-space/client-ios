#import <Foundation/Foundation.h>
#import "ESRestoreInfoReq.h"
#import "ESRestoreStartReq.h"
#import "ESRestoreUserReq.h"
#import "ESRsp.h"
#import "ESRspBackupUserList.h"
#import "ESRspRestoreInfoRsp.h"
#import "ESRspRestoreSourceRsp.h"
#import "ESRspRestoreStartRsp.h"
#import "ESRspRestoreTransId.h"
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



@interface ESRestoreApi: NSObject <ESApi>

extern NSString* kESRestoreApiErrorDomain;
extern NSInteger kESRestoreApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 获取用户头像
/// 获取用户头像
///
/// @param aoId 用户的aoid
/// @param folderName 恢复的目录
/// @param imagePath 路径
/// 
///  code:200 message:"整个文件"
///
/// @return NSURL*
-(NSURLSessionTask*) spaceV1ApiRestoreHeadGetWithAoId: (NSString*) aoId
    folderName: (NSString*) folderName
    imagePath: (NSString*) imagePath
    completionHandler: (void (^)(NSURL* output, NSError* error)) handler;


/// 获取恢复事务id
/// 获取恢复事务id
///
/// 
///  code:200 message:"返回值"
///
/// @return ESRspRestoreTransId*
-(NSURLSessionTask*) spaceV1ApiRestoreIdGetWithCompletionHandler: 
    (void (^)(ESRspRestoreTransId* output, NSError* error)) handler;


/// 备份的状态信息（进度）
/// 备份的状态信息（进度）
///
/// @param restoreInfoReq 获取恢复进度状态的请求参数
/// 
///  code:200 message:"备份返回值"
///
/// @return ESRspRestoreInfoRsp*
-(NSURLSessionTask*) spaceV1ApiRestoreInfoPostWithRestoreInfoReq: (ESRestoreInfoReq*) restoreInfoReq
    completionHandler: (void (^)(ESRspRestoreInfoRsp* output, NSError* error)) handler;


/// 获取要恢复的目录
/// 获取要恢复的目录
///
/// 
///  code:200 message:"备份返回值"
///
/// @return ESRspRestoreSourceRsp*
-(NSURLSessionTask*) spaceV1ApiRestoreSourceGetWithCompletionHandler: 
    (void (^)(ESRspRestoreSourceRsp* output, NSError* error)) handler;


/// 恢复备份
/// 恢复备份
///
/// @param restoreStartReq 恢复请求，目录和用户选择本期不实现，可不填
/// 
///  code:200 message:"返回值"
///
/// @return ESRspRestoreStartRsp*
-(NSURLSessionTask*) spaceV1ApiRestoreStartPostWithRestoreStartReq: (ESRestoreStartReq*) restoreStartReq
    completionHandler: (void (^)(ESRspRestoreStartRsp* output, NSError* error)) handler;


/// 停止备份
/// 停止备份
///
/// @param restoreInfoReq 停止恢复备份的请求参数
/// 
///  code:200 message:"停止备份返回值"
///
/// @return ESRsp*
-(NSURLSessionTask*) spaceV1ApiRestoreStopPostWithRestoreInfoReq: (ESRestoreInfoReq*) restoreInfoReq
    completionHandler: (void (^)(ESRsp* output, NSError* error)) handler;


/// 可选择的恢复用户
/// 可选择的恢复用户
///
/// @param restoreUserReq 请求参数
/// 
///  code:200 message:"返回值"
///
/// @return ESRspBackupUserList*
-(NSURLSessionTask*) spaceV1ApiRestoreUserPostWithRestoreUserReq: (ESRestoreUserReq*) restoreUserReq
    completionHandler: (void (^)(ESRspBackupUserList* output, NSError* error)) handler;



@end