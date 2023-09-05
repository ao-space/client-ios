#import "ESSpaceGatewayQRCodeScanningServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
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


@interface ESSpaceGatewayQRCodeScanningServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESSpaceGatewayQRCodeScanningServiceApi

NSString* kESSpaceGatewayQRCodeScanningServiceApiErrorDomain = @"ESSpaceGatewayQRCodeScanningServiceApiErrorDomain";
NSInteger kESSpaceGatewayQRCodeScanningServiceApiMissingParamErrorCode = 234513;

@synthesize apiClient = _apiClient;

#pragma mark - Initialize methods

- (instancetype) init {
    return [self initWithApiClient:[ESApiClient sharedClient]];
}


-(instancetype) initWithApiClient:(ESApiClient *)apiClient {
    self = [super init];
    if (self) {
        _apiClient = apiClient;
        _mutableDefaultHeaders = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -

-(NSString*) defaultHeaderForKey:(NSString*)key {
    return self.mutableDefaultHeaders[key];
}

-(void) setDefaultHeaderValue:(NSString*) value forKey:(NSString*)key {
    [self.mutableDefaultHeaders setValue:value forKey:key];
}

-(NSDictionary *)defaultHeaders {
    return self.mutableDefaultHeaders;
}

#pragma mark - Api Methods

///
/// 
/// authorized terminal login
///  @param body  (optional)
///
///  @returns ESResponseBaseVerifyTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginConfirmPostWithBody: (ESAuthorizedTerminalLoginConfirmInfo*) body
    completionHandler: (void (^)(ESResponseBaseVerifyTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/auto/login/confirm"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESResponseBaseVerifyTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseVerifyTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// authorized terminal login
///  @param body  (optional)
///
///  @returns ESResponseBaseCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginPollPostWithBody: (ESAuthorizedTerminalLoginInfo*) body
    completionHandler: (void (^)(ESResponseBaseCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/auto/login/poll"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESResponseBaseCreateTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseCreateTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// authorized terminal login
///  @param body  (optional)
///
///  @returns ESResponseBaseCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthAutoLoginPostWithBody: (ESAuthorizedTerminalLoginInfo*) body
    completionHandler: (void (^)(ESResponseBaseCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/auto/login"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESResponseBaseCreateTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseCreateTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// Get authorization code; NOTE: you need to use encrypted(symmetric key) auth-key, client uuid, boxName, boxUUID to exchange an authCode;  authCode in the response uses symmetric key encryption
///  @param body  (optional)
///
///  @returns ESCreateAuthCodeResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthBkeyCreatePostWithBody: (ESCreateAuthCodeInfo*) body
    completionHandler: (void (^)(ESCreateAuthCodeResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/bkey/create"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESCreateAuthCodeResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCreateAuthCodeResult*)data, error);
                                }
                            }];
}

///
/// 
/// short-polling the result (caller: scan code mobile phone)
///  @param bkey  
///
///  @param autoLogin  (optional, default to true)
///
///  @returns ESVerifyTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthBkeyPollPostWithBkey: (NSString*) bkey
    autoLogin: (NSNumber*) autoLogin
    completionHandler: (void (^)(ESVerifyTokenResult* output, NSError* error)) handler {
    // verify the required parameter 'bkey' is set
    if (bkey == nil) {
        NSParameterAssert(bkey);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"bkey"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayQRCodeScanningServiceApiErrorDomain code:kESSpaceGatewayQRCodeScanningServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/bkey/poll"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (autoLogin != nil) {
        queryParams[@"autoLogin"] = [autoLogin isEqual:@(YES)] ? @"true" : @"false";
    }
    if (bkey != nil) {
        queryParams[@"bkey"] = bkey;
    }
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESVerifyTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESVerifyTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to refresh an access token for further api call with a refresh-token. you need to use encrypted(box public key) tmpEncryptedSecret; 
///  @param tmpEncryptedSecret  (optional)
///
///  @param body  (optional)
///
///  @returns ESCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthBkeyRefreshPostWithTmpEncryptedSecret: (NSString*) tmpEncryptedSecret
    body: (ESRefreshTokenInfo*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/bkey/refresh"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (tmpEncryptedSecret != nil) {
        queryParams[@"tmpEncryptedSecret"] = tmpEncryptedSecret;
    }
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESCreateTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCreateTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// Verify the authorization code on the new device side (caller: front end of the new device box); NOTE: you need to use encrypted(box public key) authCode, bkey, tmpEncryptedSecret; encryptedSecret, boxName, boxUUID in the response uses tmpEncryptedSecret encryption
///  @param body  (optional)
///
///  @returns ESEncryptAuthResult*
///
-(NSURLSessionTask*) spaceV1ApiAuthBkeyVerifyPostWithBody: (ESEncryptAuthInfo*) body
    completionHandler: (void (^)(ESEncryptAuthResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/auth/bkey/verify"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"application/json"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = body;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESEncryptAuthResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESEncryptAuthResult*)data, error);
                                }
                            }];
}



@end
