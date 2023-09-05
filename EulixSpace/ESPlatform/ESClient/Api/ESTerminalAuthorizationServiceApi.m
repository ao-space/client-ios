#import "ESTerminalAuthorizationServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESAuthorizedTerminalInfo.h"
#import "ESResponseBaseAuthorizedTerminalEntity.h"
#import "ESResponseBaseAuthorizedTerminalResult.h"
#import "ESResponseBaseListAuthorizedTerminalResult.h"


@interface ESTerminalAuthorizationServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESTerminalAuthorizationServiceApi

NSString* kESTerminalAuthorizationServiceApiErrorDomain = @"ESTerminalAuthorizationServiceApiErrorDomain";
NSInteger kESTerminalAuthorizationServiceApiMissingParamErrorCode = 234513;

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
/// Tries to get authorized terminal information by userId.
///  @param aoid  (optional)
///
///  @returns ESResponseBaseListAuthorizedTerminalResult*
///
-(NSURLSessionTask*) spaceV1ApiTerminalAllInfoGetWithAoid: (NSString*) aoid
    completionHandler: (void (^)(ESResponseBaseListAuthorizedTerminalResult* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/all/info"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (aoid != nil) {
        queryParams[@"aoid"] = aoid;
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
                              responseType: @"ESResponseBaseListAuthorizedTerminalResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseListAuthorizedTerminalResult*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param aoid  
///
///  @param clientUUID  
///
///  @returns ESResponseBaseAuthorizedTerminalResult*
///
-(NSURLSessionTask*) spaceV1ApiTerminalInfoDeleteDeleteWithAoid: (NSString*) aoid
    clientUUID: (NSString*) clientUUID
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalResult* output, NSError* error)) handler {
    // verify the required parameter 'aoid' is set
    if (aoid == nil) {
        NSParameterAssert(aoid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"aoid"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'clientUUID' is set
    if (clientUUID == nil) {
        NSParameterAssert(clientUUID);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"clientUUID"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/info/delete"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (aoid != nil) {
        queryParams[@"aoid"] = aoid;
    }
    if (clientUUID != nil) {
        queryParams[@"clientUUID"] = clientUUID;
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
                              responseType: @"ESResponseBaseAuthorizedTerminalResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalResult*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param aoid  
///
///  @param clientUUID  
///
///  @returns ESResponseBaseAuthorizedTerminalResult*
///
-(NSURLSessionTask*) spaceV1ApiTerminalInfoDeletePostWithAoid: (NSString*) aoid
    clientUUID: (NSString*) clientUUID
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalResult* output, NSError* error)) handler {
    // verify the required parameter 'aoid' is set
    if (aoid == nil) {
        NSParameterAssert(aoid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"aoid"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'clientUUID' is set
    if (clientUUID == nil) {
        NSParameterAssert(clientUUID);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"clientUUID"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/info/delete"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (aoid != nil) {
        queryParams[@"aoid"] = aoid;
    }
    if (clientUUID != nil) {
        queryParams[@"clientUUID"] = clientUUID;
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
                              responseType: @"ESResponseBaseAuthorizedTerminalResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalResult*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param aoid  
///
///  @param clientUUID  (optional)
///
///  @returns ESResponseBaseAuthorizedTerminalResult*
///
-(NSURLSessionTask*) spaceV1ApiTerminalInfoGetWithAoid: (NSString*) aoid
    clientUUID: (NSString*) clientUUID
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalResult* output, NSError* error)) handler {
    // verify the required parameter 'aoid' is set
    if (aoid == nil) {
        NSParameterAssert(aoid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"aoid"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/info"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (aoid != nil) {
        queryParams[@"aoid"] = aoid;
    }
    if (clientUUID != nil) {
        queryParams[@"clientUUID"] = clientUUID;
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
                              responseType: @"ESResponseBaseAuthorizedTerminalResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalResult*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param body  (optional)
///
///  @returns ESResponseBaseAuthorizedTerminalEntity*
///
-(NSURLSessionTask*) spaceV1ApiTerminalInfoInsertPostWithBody: (ESAuthorizedTerminalInfo*) body
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalEntity* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/info/insert"];

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
                              responseType: @"ESResponseBaseAuthorizedTerminalEntity*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalEntity*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param body  (optional)
///
///  @returns ESResponseBaseAuthorizedTerminalEntity*
///
-(NSURLSessionTask*) spaceV1ApiTerminalInfoUpdatePostWithBody: (ESAuthorizedTerminalInfo*) body
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalEntity* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/info/update"];

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
                              responseType: @"ESResponseBaseAuthorizedTerminalEntity*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalEntity*)data, error);
                                }
                            }];
}

///
/// 
/// Tries to get authorized terminal information by userId.
///  @param aoid  
///
///  @param clientUUID  
///
///  @param accessTokenClientUUID  (optional)
///
///  @returns ESResponseBaseAuthorizedTerminalResult*
///
-(NSURLSessionTask*) spaceV1ApiTerminalLogoutPostWithAoid: (NSString*) aoid
    clientUUID: (NSString*) clientUUID
    accessTokenClientUUID: (NSString*) accessTokenClientUUID
    completionHandler: (void (^)(ESResponseBaseAuthorizedTerminalResult* output, NSError* error)) handler {
    // verify the required parameter 'aoid' is set
    if (aoid == nil) {
        NSParameterAssert(aoid);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"aoid"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'clientUUID' is set
    if (clientUUID == nil) {
        NSParameterAssert(clientUUID);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"clientUUID"] };
            NSError* error = [NSError errorWithDomain:kESTerminalAuthorizationServiceApiErrorDomain code:kESTerminalAuthorizationServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/terminal/logout"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (accessTokenClientUUID != nil) {
        queryParams[@"AccessToken-clientUUID"] = accessTokenClientUUID;
    }
    if (aoid != nil) {
        queryParams[@"aoid"] = aoid;
    }
    if (clientUUID != nil) {
        queryParams[@"clientUUID"] = clientUUID;
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
                              responseType: @"ESResponseBaseAuthorizedTerminalResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESResponseBaseAuthorizedTerminalResult*)data, error);
                                }
                            }];
}



@end
