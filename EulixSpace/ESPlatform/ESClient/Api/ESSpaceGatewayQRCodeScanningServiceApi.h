#import <Foundation/Foundation.h>
#import "ESAuthorizedTerminalLoginConfirmInfo.h"
#import "ESAuthorizedTerminalLoginInfo.h"
#import "ESCreateAuthCodeInfo.h"
#import "ESCreateAuthCodeResult.h"
#import "ESCreateTokenResult.h"
#import "ESEncryptAuthInfo.h"
#import "ESEncryptAuthResult.h"
#import "ESRefreshTokenInfo.h"
#import "ESResponseBaseCreateTokenResult.h"
#import "ESResponseBaseVerifyTokenResult.h"
#import "ESVerifyTokenResult.h"
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



@interface ESSpaceGatewayQRCodeScanningServiceApi: NSObject <ESApi>

extern NSString* kESSpaceGatewayQRCodeScanningServiceApiErrorDomain;
extern NSInteger kESSpaceGatewayQRCodeScanningServiceApiMissingParamErrorCode;

-(instancetype) initWithApiClient:(ESApiClient *)apiClient NS_DESIGNATED_INITIALIZER;

/// 
/// authorized terminal login
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESResponseBaseVerifyTokenResult*
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginConfirmPostWithBody: (ESAuthorizedTerminalLoginConfirmInfo*) body
    completionHandler: (void (^)(ESResponseBaseVerifyTokenResult* output, NSError* error)) handler;


/// 
/// authorized terminal login
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESResponseBaseCreateTokenResult*
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginPollPostWithBody: (ESAuthorizedTerminalLoginInfo*) body
    completionHandler: (void (^)(ESResponseBaseCreateTokenResult* output, NSError* error)) handler;


/// 
/// authorized terminal login
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESResponseBaseCreateTokenResult*
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginPostWithBody: (ESAuthorizedTerminalLoginInfo*) body
    completionHandler: (void (^)(ESResponseBaseCreateTokenResult* output, NSError* error)) handler;


/// 
/// Get authorization code; NOTE: you need to use encrypted(symmetric key) auth-key, client uuid, boxName, boxUUID to exchange an authCode;  authCode in the response uses symmetric key encryption
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESCreateAuthCodeResult*
-(NSURLSessionTask*) spaceV1ApiAuthBkeyCreatePostWithBody: (ESCreateAuthCodeInfo*) body
    completionHandler: (void (^)(ESCreateAuthCodeResult* output, NSError* error)) handler;


/// 
/// short-polling the result (caller: scan code mobile phone)
///
/// @param bkey 
/// @param autoLogin  (optional) (default to true)
/// 
///  code:200 message:"OK"
///
/// @return ESVerifyTokenResult*
-(NSURLSessionTask*) spaceV1ApiAuthBkeyPollPostWithBkey: (NSString*) bkey
    autoLogin: (NSNumber*) autoLogin
    completionHandler: (void (^)(ESVerifyTokenResult* output, NSError* error)) handler;


/// 
/// Tries to refresh an access token for further api call with a refresh-token. you need to use encrypted(box public key) tmpEncryptedSecret; 
///
/// @param tmpEncryptedSecret  (optional)
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESCreateTokenResult*
-(NSURLSessionTask*) spaceV1ApiAuthBkeyRefreshPostWithTmpEncryptedSecret: (NSString*) tmpEncryptedSecret
    body: (ESRefreshTokenInfo*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler;


/// 
/// Verify the authorization code on the new device side (caller: front end of the new device box); NOTE: you need to use encrypted(box public key) authCode, bkey, tmpEncryptedSecret; encryptedSecret, boxName, boxUUID in the response uses tmpEncryptedSecret encryption
///
/// @param body  (optional)
/// 
///  code:200 message:"OK"
///
/// @return ESEncryptAuthResult*
-(NSURLSessionTask*) spaceV1ApiAuthBkeyVerifyPostWithBody: (ESEncryptAuthInfo*) body
    completionHandler: (void (^)(ESEncryptAuthResult* output, NSError* error)) handler;



@end
