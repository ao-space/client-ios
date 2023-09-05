#import "ESArticleServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESArticleReq.h"
#import "ESArticleRes.h"
#import "ESBaseResultRes.h"
#import "ESPageListResultArticleRes.h"


@interface ESArticleServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESArticleServiceApi

NSString* kESArticleServiceApiErrorDomain = @"ESArticleServiceApiErrorDomain";
NSInteger kESArticleServiceApiMissingParamErrorCode = 234513;

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
/// 创建文章
///  @param body  (optional)
///
///  @returns ESArticleRes*
///
-(NSURLSessionTask*) createArticleWithBody: (ESArticleReq*) body
    completionHandler: (void (^)(ESArticleRes* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article"];

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
                              responseType: @"ESArticleRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESArticleRes*)data, error);
                                }
                            }];
}

///
/// 
/// 删除文章
///  @param articleid  
///
///  @returns ESBaseResultRes*
///
-(NSURLSessionTask*) deleteArticleWithArticleid: (NSNumber*) articleid
    completionHandler: (void (^)(ESBaseResultRes* output, NSError* error)) handler {
    // verify the required parameter 'articleid' is set
    if (articleid == nil) {
        NSParameterAssert(articleid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"articleid"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article/{articleid}"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];
    if (articleid != nil) {
        pathParams[@"articleid"] = articleid;
    }

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
                              responseType: @"ESBaseResultRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESBaseResultRes*)data, error);
                                }
                            }];
}

///
/// 
/// 删除文章列表
///  @param articleIds  (optional)
///
///  @returns ESBaseResultRes*
///
-(NSURLSessionTask*) deleteArticlesWithArticleIds: (NSArray<NSNumber*>*) articleIds
    completionHandler: (void (^)(ESBaseResultRes* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article/batch"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (articleIds != nil) {
        queryParams[@"article_ids"] = [[ESQueryParamCollection alloc] initWithValuesAndFormat: articleIds format: @"multi"];
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
                              responseType: @"ESBaseResultRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESBaseResultRes*)data, error);
                                }
                            }];
}

///
/// 
/// 获取文章详细信息
///  @param articleid  
///
///  @returns ESArticleRes*
///
-(NSURLSessionTask*) getArticleDetailWithArticleid: (NSNumber*) articleid
    completionHandler: (void (^)(ESArticleRes* output, NSError* error)) handler {
    // verify the required parameter 'articleid' is set
    if (articleid == nil) {
        NSParameterAssert(articleid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"articleid"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article/{articleid}"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];
    if (articleid != nil) {
        pathParams[@"articleid"] = articleid;
    }

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
                              responseType: @"ESArticleRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESArticleRes*)data, error);
                                }
                            }];
}

///
/// 
/// 获取文章列表
///  @param cataId 目录id 
///
///  @param currentPage 当前页 
///
///  @param pageSize 每页数量，最大2000 
///
///  @returns ESPageListResultArticleRes*
///
-(NSURLSessionTask*) getArticlesWithCataId: (NSNumber*) cataId
    currentPage: (NSNumber*) currentPage
    pageSize: (NSNumber*) pageSize
    completionHandler: (void (^)(ESPageListResultArticleRes* output, NSError* error)) handler {
    // verify the required parameter 'cataId' is set
    if (cataId == nil) {
        NSParameterAssert(cataId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"cataId"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'currentPage' is set
    if (currentPage == nil) {
        NSParameterAssert(currentPage);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"currentPage"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'pageSize' is set
    if (pageSize == nil) {
        NSParameterAssert(pageSize);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"pageSize"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article/list"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (cataId != nil) {
        queryParams[@"cata_id"] = cataId;
    }
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
                              responseType: @"ESPageListResultArticleRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESPageListResultArticleRes*)data, error);
                                }
                            }];
}

///
/// 
/// 修改文章
///  @param articleid  
///
///  @param body  (optional)
///
///  @returns ESArticleRes*
///
-(NSURLSessionTask*) updateArticleWithArticleid: (NSNumber*) articleid
    body: (ESArticleReq*) body
    completionHandler: (void (^)(ESArticleRes* output, NSError* error)) handler {
    // verify the required parameter 'articleid' is set
    if (articleid == nil) {
        NSParameterAssert(articleid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"articleid"] };
            NSError* error = [NSError errorWithDomain:kESArticleServiceApiErrorDomain code:kESArticleServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/article/{articleid}"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];
    if (articleid != nil) {
        pathParams[@"articleid"] = articleid;
    }

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
                              responseType: @"ESArticleRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESArticleRes*)data, error);
                                }
                            }];
}



@end
