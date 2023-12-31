#import <Foundation/Foundation.h>
#import "ESStatusResult.h"
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



@interface ESPlatformServiceStatusApi: NSObject <ESApi>

extern NSString* kESPlatformServiceStatusApiErrorDomain;
extern NSInteger kESPlatformServiceStatusApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 
/// Try to fetch the current status of server.
///
/// 
///  code:200 message:"OK"
///
/// @return ESStatusResult*
-(NSURLSessionTask*) spaceStatusGetWithCompletionHandler: 
    (void (^)(ESStatusResult* output, NSError* error)) handler;



@end
