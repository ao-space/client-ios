#import "ESRecycledApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESRecycledPhyDeleteReq.h"
#import "ESRestoreRecycledReq.h"
#import "ESRsp.h"
#import "ESRspDbAffect.h"
#import "ESRspGetListRspData.h"


@interface ESRecycledApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESRecycledApi

NSString* kESRecycledApiErrorDomain = @"ESRecycledApiErrorDomain";
NSInteger kESRecycledApiMissingParamErrorCode = 234513;

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
/// 清理回收站
/// 清理回收站，不可恢复，调用返回任务接收成功，实际清理动作为异步。
///  @param uuids 删除的文件(或目录) uuid 列表，如果列表为空，则表示清空回收站 
///
///  @returns ESRsp*
///
-(NSURLSessionTask*) spaceV1ApiRecycledClearPostWithUuids: (ESRecycledPhyDeleteReq*) uuids
    completionHandler: (void (^)(ESRsp* output, NSError* error)) handler {
    // verify the required parameter 'uuids' is set
    if (uuids == nil) {
        NSParameterAssert(uuids);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"uuids"] };
            NSError* error = [NSError errorWithDomain:kESRecycledApiErrorDomain code:kESRecycledApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/recycled/clear"];

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
    bodyParam = uuids;

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
/// 回收站文件列表
/// 回收站文件列表
///  @param page 页码，默认1 (optional)
///
///  @param pageSize 页码大小，默认10 (optional)
///
///  @returns ESRspGetListRspData*
///
-(NSURLSessionTask*) spaceV1ApiRecycledListGetWithPage: (NSNumber*) page
    pageSize: (NSNumber*) pageSize
    completionHandler: (void (^)(ESRspGetListRspData* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/recycled/list"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (page != nil) {
        queryParams[@"page"] = page;
    }
    if (pageSize != nil) {
        queryParams[@"pageSize"] = pageSize;
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
                              responseType: @"ESRspGetListRspData*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspGetListRspData*)data, error);
                                }
                            }];
}

///
/// 回收站文件还原
/// 回收站文件还原
///  @param restoreFilesReq 文件（夹）uuid 
///
///  @returns ESRspDbAffect*
///
-(NSURLSessionTask*) spaceV1ApiRecycledRestorePostWithRestoreFilesReq: (ESRestoreRecycledReq*) restoreFilesReq
    completionHandler: (void (^)(ESRspDbAffect* output, NSError* error)) handler {
    // verify the required parameter 'restoreFilesReq' is set
    if (restoreFilesReq == nil) {
        NSParameterAssert(restoreFilesReq);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"restoreFilesReq"] };
            NSError* error = [NSError errorWithDomain:kESRecycledApiErrorDomain code:kESRecycledApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/recycled/restore"];

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
    bodyParam = restoreFilesReq;

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
                              responseType: @"ESRspDbAffect*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspDbAffect*)data, error);
                                }
                            }];
}



@end
