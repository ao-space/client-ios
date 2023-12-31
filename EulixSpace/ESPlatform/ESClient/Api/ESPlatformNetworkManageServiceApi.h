#import <Foundation/Foundation.h>
#import "ESStunServerRes.h"
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



@interface ESPlatformNetworkManageServiceApi: NSObject <ESApi>

extern NSString* kESPlatformNetworkManageServiceApiErrorDomain;
extern NSInteger kESPlatformNetworkManageServiceApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 
/// 查询相应 stun server 信息
///
/// @param subdomain 
/// 
///  code:200 message:"OK"
///
/// @return ESStunServerRes*
-(NSURLSessionTask*) stunServerDetailWithSubdomain: (NSString*) subdomain
    completionHandler: (void (^)(ESStunServerRes* output, NSError* error)) handler;



@end
