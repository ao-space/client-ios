#import "ESPlatformQuestionnaireManagementServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESFeedbackReq.h"
#import "ESFeedbackRes.h"
#import "ESPageListResultQuestionnaireRes.h"
#import "ESQuestionnaireReq.h"
#import "ESQuestionnaireRes.h"


@interface ESPlatformQuestionnaireManagementServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESPlatformQuestionnaireManagementServiceApi

NSString* kESPlatformQuestionnaireManagementServiceApiErrorDomain = @"ESPlatformQuestionnaireManagementServiceApiErrorDomain";
NSInteger kESPlatformQuestionnaireManagementServiceApiMissingParamErrorCode = 234513;

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
/// 用户提交问卷
///  @param body  (optional)
///
///  @returns ESFeedbackRes*
///
-(NSURLSessionTask*) feedbackSaveWithBody: (ESFeedbackReq*) body
    completionHandler: (void (^)(ESFeedbackRes* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/questionnaire/feedback"];

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
                              responseType: @"ESFeedbackRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESFeedbackRes*)data, error);
                                }
                            }];
}

///
/// 
/// 获取问卷列表
///  @param currentPage 当前页 
///
///  @param pageSize 每页数量，最大2000 
///
///  @param userDomain 用户域名 (optional)
///
///  @returns ESPageListResultQuestionnaireRes*
///
-(NSURLSessionTask*) questionnaireListWithCurrentPage: (NSNumber*) currentPage
    pageSize: (NSNumber*) pageSize
    userId: (NSString*) userId
    boxUuid: (NSString*) boxUuid
    completionHandler: (void (^)(ESPageListResultQuestionnaireRes* output, NSError* error)) handler {
    // verify the required parameter 'currentPage' is set
    if (currentPage == nil) {
        NSParameterAssert(currentPage);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"currentPage"] };
            NSError* error = [NSError errorWithDomain:kESPlatformQuestionnaireManagementServiceApiErrorDomain code:kESPlatformQuestionnaireManagementServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'pageSize' is set
    if (pageSize == nil) {
        NSParameterAssert(pageSize);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"pageSize"] };
            NSError* error = [NSError errorWithDomain:kESPlatformQuestionnaireManagementServiceApiErrorDomain code:kESPlatformQuestionnaireManagementServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/v2/service/questionnaires"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (currentPage != nil) {
        queryParams[@"current_page"] = currentPage;
    }
    if (pageSize != nil) {
        queryParams[@"page_size"] = pageSize;
    }
    if (userId != nil) {
        queryParams[@"user_id"] = userId;
    }
    if (boxUuid != nil) {
        queryParams[@"box_uuid"] = boxUuid;
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
                              responseType: @"ESPageListResultQuestionnaireRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESPageListResultQuestionnaireRes*)data, error);
                                }
                            }];
}

///
/// 
/// 新增问卷
///  @param body  (optional)
///
///  @returns ESQuestionnaireRes*
///
-(NSURLSessionTask*) questionnaireSaveWithBody: (ESQuestionnaireReq*) body
    completionHandler: (void (^)(ESQuestionnaireRes* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/questionnaire"];

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
                              responseType: @"ESQuestionnaireRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESQuestionnaireRes*)data, error);
                                }
                            }];
}



@end
