#import "ESMultipartApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESCompleteMultipartTaskReq.h"
#import "ESCreateMultipartTaskReq.h"
#import "ESDeleteMultipartTaskReq.h"
#import "ESListMultipartReq.h"
#import "ESRsp.h"
#import "ESRspCompleteMultipartTaskRsp.h"
#import "ESRspCreateMultipartTaskRsp.h"
#import "ESRspListMultipartRsp.h"


@interface ESMultipartApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESMultipartApi

NSString* kESMultipartApiErrorDomain = @"ESMultipartApiErrorDomain";
NSInteger kESMultipartApiMissingParamErrorCode = 234513;

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
/// 合并分片上传任务
/// 
///  @param requestId 请求id 
///
///  @param object 上传任务参数 
///
///  @returns ESRspCompleteMultipartTaskRsp*
///
-(NSURLSessionTask*) spaceV1ApiMultipartCompletePostWithRequestId: (NSString*) requestId
    object: (ESCompleteMultipartTaskReq*) object
    completionHandler: (void (^)(ESRspCompleteMultipartTaskRsp* output, NSError* error)) handler {
    // verify the required parameter 'requestId' is set
    if (requestId == nil) {
        NSParameterAssert(requestId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"requestId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'object' is set
    if (object == nil) {
        NSParameterAssert(object);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"object"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/multipart/complete"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (requestId != nil) {
        queryParams[@"requestId"] = requestId;
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
    bodyParam = object;

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
                              responseType: @"ESRspCompleteMultipartTaskRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspCompleteMultipartTaskRsp*)data, error);
                                }
                            }];
}

///
/// 创建分片上传任务
/// 
///  @param requestId 请求id 
///
///  @param object 创建任务参数 
///
///  @returns ESRspCreateMultipartTaskRsp*
///
-(NSURLSessionTask*) spaceV1ApiMultipartCreatePostWithRequestId: (NSString*) requestId
    object: (ESCreateMultipartTaskReq*) object
    completionHandler: (void (^)(ESRspCreateMultipartTaskRsp* output, NSError* error)) handler {
    // verify the required parameter 'requestId' is set
    if (requestId == nil) {
        NSParameterAssert(requestId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"requestId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'object' is set
    if (object == nil) {
        NSParameterAssert(object);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"object"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/multipart/create"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (requestId != nil) {
        queryParams[@"requestId"] = requestId;
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
    bodyParam = object;

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
                              responseType: @"ESRspCreateMultipartTaskRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspCreateMultipartTaskRsp*)data, error);
                                }
                            }];
}

///
/// 删除分片上传任务
/// 
///  @param requestId 请求id 
///
///  @param object 删除任务参数 
///
///  @returns ESRsp*
///
-(NSURLSessionTask*) spaceV1ApiMultipartDeletePostWithRequestId: (NSString*) requestId
    object: (ESDeleteMultipartTaskReq*) object
    completionHandler: (void (^)(ESRsp* output, NSError* error)) handler {
    // verify the required parameter 'requestId' is set
    if (requestId == nil) {
        NSParameterAssert(requestId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"requestId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'object' is set
    if (object == nil) {
        NSParameterAssert(object);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"object"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/multipart/delete"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (requestId != nil) {
        queryParams[@"requestId"] = requestId;
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
    bodyParam = object;

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
                              responseType: @"ESRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRsp*)data, error);
                                }
                            }];
}

///
/// 查询分片上传任务信息
/// 
///  @param requestId 请求id 
///
///  @param object 查询任务参数 
///
///  @returns ESRspListMultipartRsp*
///
-(NSURLSessionTask*) spaceV1ApiMultipartListGetWithRequestId: (NSString*) requestId
    object: (ESListMultipartReq*) object
    completionHandler: (void (^)(ESRspListMultipartRsp* output, NSError* error)) handler {
    // verify the required parameter 'requestId' is set
    if (requestId == nil) {
        NSParameterAssert(requestId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"requestId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'object' is set
    if (object == nil) {
        NSParameterAssert(object);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"object"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/multipart/list"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (requestId != nil) {
        queryParams[@"requestId"] = requestId;
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
    bodyParam = object;

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
                              responseType: @"ESRspListMultipartRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspListMultipartRsp*)data, error);
                                }
                            }];
}

///
/// 上传分片
/// 
///  @param requestId 请求id 
///
///  @param end  
///
///  @param md5sum  
///
///  @param uploadId  
///
///  @param object 分片文件数据 
///
///  @param start  (optional)
///
///  @returns ESRsp*
///
-(NSURLSessionTask*) spaceV1ApiMultipartUploadPostWithRequestId: (NSString*) requestId
    end: (NSNumber*) end
    md5sum: (NSString*) md5sum
    uploadId: (NSString*) uploadId
    object: (NSString*) object
    start: (NSNumber*) start
    completionHandler: (void (^)(ESRsp* output, NSError* error)) handler {
    // verify the required parameter 'requestId' is set
    if (requestId == nil) {
        NSParameterAssert(requestId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"requestId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'end' is set
    if (end == nil) {
        NSParameterAssert(end);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"end"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'md5sum' is set
    if (md5sum == nil) {
        NSParameterAssert(md5sum);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"md5sum"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'uploadId' is set
    if (uploadId == nil) {
        NSParameterAssert(uploadId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"uploadId"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'object' is set
    if (object == nil) {
        NSParameterAssert(object);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"object"] };
            NSError* error = [NSError errorWithDomain:kESMultipartApiErrorDomain code:kESMultipartApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/multipart/upload"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (requestId != nil) {
        queryParams[@"requestId"] = requestId;
    }
    if (end != nil) {
        queryParams[@"end"] = end;
    }
    if (md5sum != nil) {
        queryParams[@"md5sum"] = md5sum;
    }
    if (start != nil) {
        queryParams[@"start"] = start;
    }
    if (uploadId != nil) {
        queryParams[@"uploadId"] = uploadId;
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
    bodyParam = object;

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
                              responseType: @"ESRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRsp*)data, error);
                                }
                            }];
}



@end
