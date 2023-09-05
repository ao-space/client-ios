#import "ESPlatformRegistryServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESSubdomainGenResult.h"
#import "ESSubdomainUpdateResult.h"


@interface ESPlatformRegistryServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESPlatformRegistryServiceApi

NSString* kESPlatformRegistryServiceApiErrorDomain = @"ESPlatformRegistryServiceApiErrorDomain";
NSInteger kESPlatformRegistryServiceApiMissingParamErrorCode = 234513;

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
/// 分发全局唯一的subdomain。
///  @param boxRegKey 盒子的注册 key。 
///
///  @param boxUuid 盒子的 uuid。 
///
///  @param effectiveTime 有效期，单位秒，最长7天 (optional)
///
///  @returns ESSubdomainGenResult*
///
-(NSURLSessionTask*) subdomainGenWithBoxRegKey: (NSString*) boxRegKey
    boxUuid: (NSString*) boxUuid
    effectiveTime: (NSNumber*) effectiveTime
    completionHandler: (void (^)(ESSubdomainGenResult* output, NSError* error)) handler {
    // verify the required parameter 'boxRegKey' is set
    if (boxRegKey == nil) {
        NSParameterAssert(boxRegKey);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxRegKey"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'boxUuid' is set
    if (boxUuid == nil) {
        NSParameterAssert(boxUuid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxUuid"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/subdomain/gen"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (boxRegKey != nil) {
        queryParams[@"box_reg_key"] = boxRegKey;
    }
    if (boxUuid != nil) {
        queryParams[@"box_uuid"] = boxUuid;
    }
    if (effectiveTime != nil) {
        queryParams[@"effective_time"] = effectiveTime;
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
                              responseType: @"ESSubdomainGenResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESSubdomainGenResult*)data, error);
                                }
                            }];
}

///
/// 
/// 更新subdomain。幂等设计，建议client失败重试3次。
///  @param boxUuid 盒子的 uuid。 
///
///  @param subdomain 子域名，最长100字符 
///
///  @param userId 用户的 id。 
///
///  @param userRegKey 用户的注册 key。 
///
///  @returns ESSubdomainUpdateResult*
///
-(NSURLSessionTask*) subdomainUpdateWithBoxUuid: (NSString*) boxUuid
    subdomain: (NSString*) subdomain
    userId: (NSString*) userId
    userRegKey: (NSString*) userRegKey
    completionHandler: (void (^)(ESSubdomainUpdateResult* output, NSError* error)) handler {
    // verify the required parameter 'boxUuid' is set
    if (boxUuid == nil) {
        NSParameterAssert(boxUuid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxUuid"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'subdomain' is set
    if (subdomain == nil) {
        NSParameterAssert(subdomain);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"subdomain"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'userId' is set
    if (userId == nil) {
        NSParameterAssert(userId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"userId"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'userRegKey' is set
    if (userRegKey == nil) {
        NSParameterAssert(userRegKey);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"userRegKey"] };
            NSError* error = [NSError errorWithDomain:kESPlatformRegistryServiceApiErrorDomain code:kESPlatformRegistryServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/platform/v1/api/subdomain/update"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (boxUuid != nil) {
        queryParams[@"box_uuid"] = boxUuid;
    }
    if (subdomain != nil) {
        queryParams[@"subdomain"] = subdomain;
    }
    if (userId != nil) {
        queryParams[@"user_id"] = userId;
    }
    if (userRegKey != nil) {
        queryParams[@"user_reg_key"] = userRegKey;
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
                              responseType: @"ESSubdomainUpdateResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESSubdomainUpdateResult*)data, error);
                                }
                            }];
}



@end
