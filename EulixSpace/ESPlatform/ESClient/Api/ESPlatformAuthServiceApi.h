#import <Foundation/Foundation.h>
#import "ESGenPkeyRsp.h"
#import "ESPollPkeyRsp.h"
#import "ESTransBoxInfoReq.h"
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



@interface ESPlatformAuthServiceApi: NSObject <ESApi>

extern NSString* kESPlatformAuthServiceApiErrorDomain;
extern NSInteger kESPlatformAuthServiceApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 
/// Receive box info from app(old client).
///
/// @param body  (optional)
/// 
///  code:201 message:"Created"
///
/// @return void
-(NSURLSessionTask*) boxinfoTransWithBody: (ESTransBoxInfoReq*) body
    completionHandler: (void (^)(NSError* error)) handler;


/// 
/// Generate pkey for new client.
///
/// 
///  code:200 message:"OK"
///
/// @return ESGenPkeyRsp*
-(NSURLSessionTask*) pkeyGenWithCompletionHandler: 
    (void (^)(ESGenPkeyRsp* output, NSError* error)) handler;


/// 
/// Poll box info by new client.
///
/// @param pkey 
/// 
///  code:200 message:"OK"
///
/// @return ESPollPkeyRsp*
-(NSURLSessionTask*) pkeyPollWithPkey: (NSString*) pkey
    completionHandler: (void (^)(ESPollPkeyRsp* output, NSError* error)) handler;



@end
