#import "ESPairApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESBaseRspStr.h"
#import "ESKeyExchangeReq.h"
#import "ESPairingReq.h"
#import "ESPasswordInfo.h"
#import "ESPubKeyExchangeReq.h"
#import "ESResetClientReq.h"
#import "ESRevokReq.h"
#import "ESRspInitResult.h"
#import "ESRspKeyExchangeRsp.h"
#import "ESRspMicroServerRsp.h"
#import "ESRspPubKeyExchangeRsp.h"


@interface ESPairApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESPairApi

NSString* kESPairApiErrorDomain = @"ESPairApiErrorDomain";
NSInteger kESPairApiMissingParamErrorCode = 234513;

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
/// 触发盒子端初始化,阻塞式接口 [客户端调用]
/// 盒子端初始化查询接口。主要此接口是同步返回，也就是初始化结束后该接口才会返回。
///  @param passwordInfo 管理员密码. 
///
///  @returns ESRspMicroServerRsp*
///
-(NSURLSessionTask*) initialWithPasswordInfo: (ESPasswordInfo*) passwordInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler {
    // verify the required parameter 'passwordInfo' is set
    if (passwordInfo == nil) {
        NSParameterAssert(passwordInfo);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"passwordInfo"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/initial"];

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
    bodyParam = passwordInfo;

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
                              responseType: @"ESRspMicroServerRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspMicroServerRsp*)data, error);
                                }
                            }];
}

///
/// 对称密钥交换 [客户端调用]
/// App向盒子请求生成对称密钥 示例数据:
///  @param keyExchangeReq {clientPreSecret:必填,客户端对称密钥种子. 客户端生成随机字符串，32个字符,encBtid:必填,使用盒子端公钥加密btid后进行base64得到的字符串} 
///
///  @returns ESRspKeyExchangeRsp*
///
-(NSURLSessionTask*) keyExchangeWithKeyExchangeReq: (ESKeyExchangeReq*) keyExchangeReq
    completionHandler: (void (^)(ESRspKeyExchangeRsp* output, NSError* error)) handler {
    // verify the required parameter 'keyExchangeReq' is set
    if (keyExchangeReq == nil) {
        NSParameterAssert(keyExchangeReq);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"keyExchangeReq"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/keyexchange"];

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
    bodyParam = keyExchangeReq;

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
                              responseType: @"ESRspKeyExchangeRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspKeyExchangeRsp*)data, error);
                                }
                            }];
}

///
/// APP调用进行管理员解绑 [客户端调用]
/// 客户端通过HTTP调用此接口来解绑管理员. Results 内部是网关的 revoke 接口返回的原样数据.
///  @param revokReq 盒子的安全密码 
///
///  @returns ESRspMicroServerRsp*
///
-(NSURLSessionTask*) pairAdminRevokeWithRevokReq: (ESRevokReq*) revokReq
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler {
    // verify the required parameter 'revokReq' is set
    if (revokReq == nil) {
        NSParameterAssert(revokReq);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"revokReq"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/admin/revoke"];

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
    bodyParam = revokReq;

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
                              responseType: @"ESRspMicroServerRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspMicroServerRsp*)data, error);
                                }
                            }];
}

///
/// 盒子有线配对初始请求 [客户端调用]
/// 有线配对的初始状态请求
///  @returns ESRspInitResult*
///
-(NSURLSessionTask*) pairInitWithCompletionHandler: 
    (void (^)(ESRspInitResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pair/init"];

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
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"text/plain"]];

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
                              responseType: @"ESRspInitResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspInitResult*)data, error);
                                }
                            }];
}

///
/// App与盒子端配对接口 [客户端调用]
/// App与盒子端配对接口 返回 result 经过以下处理 based64.decode -> aes.decrypt -> PairingBoxInfo
///  @param pairingBoxInfo 客户端传入盒子的配对数据 
///
///  @returns ESRspMicroServerRsp*
///
-(NSURLSessionTask*) pairingWithPairingBoxInfo: (ESPairingReq*) pairingBoxInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler {
    // verify the required parameter 'pairingBoxInfo' is set
    if (pairingBoxInfo == nil) {
        NSParameterAssert(pairingBoxInfo);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"pairingBoxInfo"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pairing"];

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
    bodyParam = pairingBoxInfo;

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
                              responseType: @"ESRspMicroServerRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspMicroServerRsp*)data, error);
                                }
                            }];
}

///
/// 公钥交换 [客户端调用]
/// App向盒子发送公钥 示例数据:
///  @param pubKeyExchangeReq {clientPubKey:必填,客户端公钥, clientPriKey:选填,客户端私钥(仅调试使用)} 
///
///  @returns ESRspPubKeyExchangeRsp*
///
-(NSURLSessionTask*) pubKeyExchangeWithPubKeyExchangeReq: (ESPubKeyExchangeReq*) pubKeyExchangeReq
    completionHandler: (void (^)(ESRspPubKeyExchangeRsp* output, NSError* error)) handler {
    // verify the required parameter 'pubKeyExchangeReq' is set
    if (pubKeyExchangeReq == nil) {
        NSParameterAssert(pubKeyExchangeReq);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"pubKeyExchangeReq"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pubkeyexchange"];

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
    bodyParam = pubKeyExchangeReq;

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
                              responseType: @"ESRspPubKeyExchangeRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspPubKeyExchangeRsp*)data, error);
                                }
                            }];
}

///
/// 清除盒子端的已配对数据 [客户端调用]
/// Reset pairing data
///  @param request 客户端私钥签名(预留字段, 暂时不验证。 调用者可传入任意字符串,但不可为空) 
///
///  @returns ESBaseRspStr*
///
-(NSURLSessionTask*) resetWithRequest: (ESResetClientReq*) request
    completionHandler: (void (^)(ESBaseRspStr* output, NSError* error)) handler {
    // verify the required parameter 'request' is set
    if (request == nil) {
        NSParameterAssert(request);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"request"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/reset"];

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
    bodyParam = request;

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
                              responseType: @"ESBaseRspStr*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESBaseRspStr*)data, error);
                                }
                            }];
}

///
/// 设置管理员密码 [客户端调用]
/// App设置管理员密码 示例数据:
///  @param passwordInfo 管理员密码 
///
///  @returns ESRspMicroServerRsp*
///
-(NSURLSessionTask*) setpasswordWithPasswordInfo: (ESPasswordInfo*) passwordInfo
    completionHandler: (void (^)(ESRspMicroServerRsp* output, NSError* error)) handler {
    // verify the required parameter 'passwordInfo' is set
    if (passwordInfo == nil) {
        NSParameterAssert(passwordInfo);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"passwordInfo"] };
            NSError* error = [NSError errorWithDomain:kESPairApiErrorDomain code:kESPairApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/setpassword"];

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
    bodyParam = passwordInfo;

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
                              responseType: @"ESRspMicroServerRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspMicroServerRsp*)data, error);
                                }
                            }];
}



@end
