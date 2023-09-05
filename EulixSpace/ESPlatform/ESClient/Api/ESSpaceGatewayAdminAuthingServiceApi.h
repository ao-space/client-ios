#import <Foundation/Foundation.h>
#import "ESCreateTokenInfo.h"
#import "ESCreateTokenResult.h"
#import "ESRefreshTokenInfo.h"
#import "ESResponseBaseRevokeClientResult.h"
#import "ESRevokeClientInfo.h"
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



@interface ESSpaceGatewayAdminAuthingServiceApi: NSObject <ESApi>

extern NSString* kESSpaceGatewayAdminAuthingServiceApiErrorDomain;
extern NSInteger kESSpaceGatewayAdminAuthingServiceApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 
/// 解绑管理员客户端。
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESResponseBaseRevokeClientResult*
-(NSURLSessionTask*) spaceV1ApiGatewayAuthRevokePostWithBody: (ESRevokeClientInfo*) body
    completionHandler: (void (^)(ESResponseBaseRevokeClientResult* output, NSError* error)) handler;


/// 
/// Tries to get an admin access token for further api  NOTE: you need to use encrypted(box public key) auth-key and client uuid to exchange an access token.
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESCreateTokenResult*
-(NSURLSessionTask*) spaceV1ApiGatewayAuthTokenCreatePostWithBody: (ESCreateTokenInfo*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler;


/// 
/// Tries to refresh an admin access token for further api call with a refresh-token.
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESCreateTokenResult*
-(NSURLSessionTask*) spaceV1ApiGatewayAuthTokenRefreshPostWithBody: (ESRefreshTokenInfo*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler;



@end