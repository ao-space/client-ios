#import "ESSpaceGatewayOpenAPIServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESCreateTokenResult.h"
#import "ESGetAccessTokenRequest.h"
#import "ESOAuthProcessData.h"
#import "ESRefreshTokenRequest.h"


@interface ESSpaceGatewayOpenAPIServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESSpaceGatewayOpenAPIServiceApi

NSString* kESSpaceGatewayOpenAPIServiceApiErrorDomain = @"ESSpaceGatewayOpenAPIServiceApiErrorDomain";
NSInteger kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode = 234513;

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
/// 通过 JSONP 的方式获得用户（owner）点击授权后相应的授权码
///  @param appletId 调用小应用 ID 
///
///  @param appletSecret 调用小应用 secret 
///
///  @param callback JSONP 回调 
///
///  @param tempSecret 临时对称密钥，用户传输后续的 auth-code，该密钥需要通过盒子公钥加密 
///
///  @param tempSecretIv 临时对称密钥IV，用户传输后续的 auth-code，该密钥 iv 需要通过 base64 编码 
///
///  @returns void
///
-(NSURLSessionTask*) spaceV1ApiGatewayOpenapiAuthCodeGetWithAppletId: (NSString*) appletId
    appletSecret: (NSString*) appletSecret
    callback: (NSString*) callback
    tempSecret: (NSString*) tempSecret
    tempSecretIv: (NSString*) tempSecretIv
    completionHandler: (void (^)(NSError* error)) handler {
    // verify the required parameter 'appletId' is set
    if (appletId == nil) {
        NSParameterAssert(appletId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletId"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    // verify the required parameter 'appletSecret' is set
    if (appletSecret == nil) {
        NSParameterAssert(appletSecret);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletSecret"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    // verify the required parameter 'callback' is set
    if (callback == nil) {
        NSParameterAssert(callback);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"callback"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    // verify the required parameter 'tempSecret' is set
    if (tempSecret == nil) {
        NSParameterAssert(tempSecret);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"tempSecret"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    // verify the required parameter 'tempSecretIv' is set
    if (tempSecretIv == nil) {
        NSParameterAssert(tempSecretIv);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"tempSecretIv"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/openapi/auth/code"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (appletId != nil) {
        queryParams[@"applet_id"] = appletId;
    }
    if (appletSecret != nil) {
        queryParams[@"applet_secret"] = appletSecret;
    }
    if (callback != nil) {
        queryParams[@"callback"] = callback;
    }
    if (tempSecret != nil) {
        queryParams[@"temp_secret"] = tempSecret;
    }
    if (tempSecretIv != nil) {
        queryParams[@"temp_secret_iv"] = tempSecretIv;
    }
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[]];
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
                                    method: @"GET"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: nil
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler(error);
                                }
                            }];
}

///
/// 
/// 获取用户（owner）确认授权
///  @param appletId 调用小应用 ID 
///
///  @param appletSecret 调用小应用 secret 
///
///  @returns ESOAuthProcessData*
///
-(NSURLSessionTask*) spaceV1ApiGatewayOpenapiAuthConfirmGetWithAppletId: (NSString*) appletId
    appletSecret: (NSString*) appletSecret
    completionHandler: (void (^)(ESOAuthProcessData* output, NSError* error)) handler {
    // verify the required parameter 'appletId' is set
    if (appletId == nil) {
        NSParameterAssert(appletId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletId"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'appletSecret' is set
    if (appletSecret == nil) {
        NSParameterAssert(appletSecret);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletSecret"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/openapi/auth/confirm"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (appletId != nil) {
        queryParams[@"applet_id"] = appletId;
    }
    if (appletSecret != nil) {
        queryParams[@"applet_secret"] = appletSecret;
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
                                    method: @"GET"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESOAuthProcessData*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESOAuthProcessData*)data, error);
                                }
                            }];
}

///
/// 
/// 获取指定 applet-id 所申请的服务能力分组，每个分组包括对应的权限列表
///  @param appletId 调用客户端 ID 
///
///  @param appletSecret 调用客户端 secret 
///
///  @returns ESOAuthProcessData*
///
-(NSURLSessionTask*) spaceV1ApiGatewayOpenapiAuthScopesGetWithAppletId: (NSString*) appletId
    appletSecret: (NSString*) appletSecret
    completionHandler: (void (^)(ESOAuthProcessData* output, NSError* error)) handler {
    // verify the required parameter 'appletId' is set
    if (appletId == nil) {
        NSParameterAssert(appletId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletId"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'appletSecret' is set
    if (appletSecret == nil) {
        NSParameterAssert(appletSecret);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletSecret"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayOpenAPIServiceApiErrorDomain code:kESSpaceGatewayOpenAPIServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/openapi/auth/scopes"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (appletId != nil) {
        queryParams[@"applet_id"] = appletId;
    }
    if (appletSecret != nil) {
        queryParams[@"applet_secret"] = appletSecret;
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
                                    method: @"GET"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESOAuthProcessData*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESOAuthProcessData*)data, error);
                                }
                            }];
}

///
/// 
/// 用户（owner）点击授权获得相应的授权码
///  @param body  (optional)
///
///  @returns ESCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayOpenapiAuthTokenCreatePostWithBody: (ESGetAccessTokenRequest*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/openapi/auth/token/create"];

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
                              responseType: @"ESCreateTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCreateTokenResult*)data, error);
                                }
                            }];
}

///
/// 
/// 用户（owner）点击授权获得相应的授权码
///  @param body  (optional)
///
///  @returns ESCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayOpenapiAuthTokenRefreshPostWithBody: (ESRefreshTokenRequest*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/openapi/auth/token/refresh"];

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
                              responseType: @"ESCreateTokenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCreateTokenResult*)data, error);
                                }
                            }];
}



@end
