#import "ESPlatformReservedDomainServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESPageListResultReservedDomainInfo.h"
#import "ESReservedDomainCreateReq.h"
#import "ESReservedDomainCreateRsp.h"
#import "ESReservedDomainDeleteRsp.h"
#import "ESReservedDomainMatchInfo.h"
#import "ESReservedDomainUpdateReq.h"
#import "ESReservedDomainUpdateRsp.h"


@interface ESPlatformReservedDomainServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESPlatformReservedDomainServiceApi

NSString* kESPlatformReservedDomainServiceApiErrorDomain = @"ESPlatformReservedDomainServiceApiErrorDomain";
NSInteger kESPlatformReservedDomainServiceApiMissingParamErrorCode = 234513;

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
/// 创建保留域名
///  @param body  (optional)
///
///  @returns ESReservedDomainCreateRsp*
///
-(NSURLSessionTask*) createWithBody: (ESReservedDomainCreateReq*) body
    completionHandler: (void (^)(ESReservedDomainCreateRsp* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/domain/reserved"];

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
                              responseType: @"ESReservedDomainCreateRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESReservedDomainCreateRsp*)data, error);
                                }
                            }];
}

///
/// 
/// 删除保留域名
///  @param regexIds 正则id列表 
///
///  @returns ESReservedDomainDeleteRsp*
///
-(NSURLSessionTask*) deleteWithRegexIds: (NSArray<NSNumber*>*) regexIds
    completionHandler: (void (^)(ESReservedDomainDeleteRsp* output, NSError* error)) handler {
    // verify the required parameter 'regexIds' is set
    if (regexIds == nil) {
        NSParameterAssert(regexIds);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"regexIds"] };
            NSError* error = [NSError errorWithDomain:kESPlatformReservedDomainServiceApiErrorDomain code:kESPlatformReservedDomainServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/domain/reserved"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (regexIds != nil) {
        queryParams[@"regex_ids"] = [[ESQueryParamCollection alloc] initWithValuesAndFormat: regexIds format: @"multi"];
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
                                    method: @"DELETE"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESReservedDomainDeleteRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESReservedDomainDeleteRsp*)data, error);
                                }
                            }];
}

///
/// 
/// 查询某一条保留域名匹配的盒子域名
///  @param regexId 正则id 
///
///  @returns NSArray<ESReservedDomainMatchInfo>*
///
-(NSURLSessionTask*) queryMatchInfoWithRegexId: (NSNumber*) regexId
    completionHandler: (void (^)(NSArray<ESReservedDomainMatchInfo>* output, NSError* error)) handler {
    // verify the required parameter 'regexId' is set
    if (regexId == nil) {
        NSParameterAssert(regexId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"regexId"] };
            NSError* error = [NSError errorWithDomain:kESPlatformReservedDomainServiceApiErrorDomain code:kESPlatformReservedDomainServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/domain/reserved/match"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (regexId != nil) {
        queryParams[@"regex_id"] = regexId;
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
                              responseType: @"NSArray<ESReservedDomainMatchInfo>*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((NSArray<ESReservedDomainMatchInfo>*)data, error);
                                }
                            }];
}

///
/// 
/// 查询保留域名
///  @param currentPage 当前页 
///
///  @param pageSize 每页数量，最大2000 
///
///  @returns ESPageListResultReservedDomainInfo*
///
-(NSURLSessionTask*) queryReservedDomainWithCurrentPage: (NSNumber*) currentPage
    pageSize: (NSNumber*) pageSize
    completionHandler: (void (^)(ESPageListResultReservedDomainInfo* output, NSError* error)) handler {
    // verify the required parameter 'currentPage' is set
    if (currentPage == nil) {
        NSParameterAssert(currentPage);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"currentPage"] };
            NSError* error = [NSError errorWithDomain:kESPlatformReservedDomainServiceApiErrorDomain code:kESPlatformReservedDomainServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'pageSize' is set
    if (pageSize == nil) {
        NSParameterAssert(pageSize);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"pageSize"] };
            NSError* error = [NSError errorWithDomain:kESPlatformReservedDomainServiceApiErrorDomain code:kESPlatformReservedDomainServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/domain/reserved"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (currentPage != nil) {
        queryParams[@"current_page"] = currentPage;
    }
    if (pageSize != nil) {
        queryParams[@"page_size"] = pageSize;
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
                              responseType: @"ESPageListResultReservedDomainInfo*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESPageListResultReservedDomainInfo*)data, error);
                                }
                            }];
}

///
/// 
/// 修改保留域名
///  @param regexId 正则id 
///
///  @param body  (optional)
///
///  @returns ESReservedDomainUpdateRsp*
///
-(NSURLSessionTask*) updateWithRegexId: (NSNumber*) regexId
    body: (ESReservedDomainUpdateReq*) body
    completionHandler: (void (^)(ESReservedDomainUpdateRsp* output, NSError* error)) handler {
    // verify the required parameter 'regexId' is set
    if (regexId == nil) {
        NSParameterAssert(regexId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"regexId"] };
            NSError* error = [NSError errorWithDomain:kESPlatformReservedDomainServiceApiErrorDomain code:kESPlatformReservedDomainServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/domain/reserved"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (regexId != nil) {
        queryParams[@"regex_id"] = regexId;
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
                                    method: @"PUT"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESReservedDomainUpdateRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESReservedDomainUpdateRsp*)data, error);
                                }
                            }];
}



@end
