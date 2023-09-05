#import "ESSpaceGatewayMemberAuthingServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESCreateMemberInfo.h"
#import "ESCreateMemberResult.h"
#import "ESCreateMemberTokenInfo.h"
#import "ESCreateTokenResult.h"
#import "ESInviteResult.h"
#import "ESResponseBaseRevokeMemberClientResult.h"
#import "ESRevokeMemberClientInfo.h"


@interface ESSpaceGatewayMemberAuthingServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESSpaceGatewayMemberAuthingServiceApi

NSString* kESSpaceGatewayMemberAuthingServiceApiErrorDomain = @"ESSpaceGatewayMemberAuthingServiceApiErrorDomain";
NSInteger kESSpaceGatewayMemberAuthingServiceApiMissingParamErrorCode = 234513;

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
/// 成员接受邀请接口 使用邀请码验证是否是有效邀请，并返回盒子公钥
///  @param inviteCode  (optional)
///
///  @returns ESInviteResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayAuthMemberAcceptGetWithInviteCode: (NSString*) inviteCode
    completionHandler: (void (^)(ESInviteResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/auth/member/accept"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (inviteCode != nil) {
        queryParams[@"inviteCode"] = inviteCode;
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
                              responseType: @"ESInviteResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESInviteResult*)data, error);
                                }
                            }];
}

///
/// 
/// 成员创建接口 使用邀请码（盒子公钥加密）和客户端UUID（盒子公钥加密）、tempEncryptedSecret（盒子公钥加密）、aoId 获取 AuthKey和 box uuid（临时密钥加密）
///  @param aoId  (optional)
///
///  @param body  (optional)
///
///  @returns ESCreateMemberResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayAuthMemberCreatePostWithAoId: (NSString*) aoId
    body: (ESCreateMemberInfo*) body
    completionHandler: (void (^)(ESCreateMemberResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/auth/member/create"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (aoId != nil) {
        queryParams[@"aoId"] = aoId;
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
                              responseType: @"ESCreateMemberResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCreateMemberResult*)data, error);
                                }
                            }];
}

///
/// 
/// 解绑成员客户端。
///  @param body  (optional)
///
///  @returns ESResponseBaseRevokeMemberClientResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayAuthRevokeMemberPostWithBody: (ESRevokeMemberClientInfo*) body
    completionHandler: (void (^)(ESResponseBaseRevokeMemberClientResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/auth/revoke/member"];

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
                              responseType: @"ESResponseBaseRevokeMemberClientResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseRevokeMemberClientResult*)data, error);
                                }
                            }];
}

///
/// 
/// 成员创建 token 接口 使用AuthKey（盒子公钥加密）和客户端UUID（盒子公钥加密）、临时密钥（盒子公钥加密）获取 token
///  @param body  (optional)
///
///  @returns ESCreateTokenResult*
///
-(NSURLSessionTask*) spaceV1ApiGatewayAuthTokenCreateMemberPostWithBody: (ESCreateMemberTokenInfo*) body
    completionHandler: (void (^)(ESCreateTokenResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/auth/token/create/member"];

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
