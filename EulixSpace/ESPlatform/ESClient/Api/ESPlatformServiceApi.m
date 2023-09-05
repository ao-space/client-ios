#import "ESPlatformServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESCompatibleCheckRes.h"
#import "ESPackageCheckRes.h"


@interface ESPlatformServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESPlatformServiceApi

NSString* kESPlatformServiceApiErrorDomain = @"ESPlatformServiceApiErrorDomain";
NSInteger kESPlatformServiceApiMissingParamErrorCode = 234513;

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
/// 
///  @param action  (optional)
///
///  @param appPkgName  (optional)
///
///  @param appPkgType  (optional)
///
///  @param boxPkgName  (optional)
///
///  @param boxPkgType  (optional)
///
///  @param curAppVersion  (optional)
///
///  @param curBoxVersion  (optional)
///
///  @returns ESPackageCheckRes*
///
-(NSURLSessionTask*) spaceV1ApiPackageCheckGetWithAction: (NSString*) action
    appPkgName: (NSString*) appPkgName
    appPkgType: (NSString*) appPkgType
    boxPkgName: (NSString*) boxPkgName
    boxPkgType: (NSString*) boxPkgType
    curAppVersion: (NSString*) curAppVersion
    curBoxVersion: (NSString*) curBoxVersion
    completionHandler: (void (^)(ESPackageCheckRes* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/package/check"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (action != nil) {
        queryParams[@"action"] = action;
    }
    if (appPkgName != nil) {
        queryParams[@"app_pkg_name"] = appPkgName;
    }
    if (appPkgType != nil) {
        queryParams[@"app_pkg_type"] = appPkgType;
    }
    if (boxPkgName != nil) {
        queryParams[@"box_pkg_name"] = boxPkgName;
    }
    if (boxPkgType != nil) {
        queryParams[@"box_pkg_type"] = boxPkgType;
    }
    if (curAppVersion != nil) {
        queryParams[@"cur_app_version"] = curAppVersion;
    }
    if (curBoxVersion != nil) {
        queryParams[@"cur_box_version"] = curBoxVersion;
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
                              responseType: @"ESPackageCheckRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESPackageCheckRes*)data, error);
                                }
                            }];
}

///
/// 
/// 
///  @param appPkgName  
///
///  @param appPkgType  
///
///  @param boxPkgName  
///
///  @param boxPkgType  
///
///  @param curAppVersion  
///
///  @param curBoxVersion  
///
///  @returns ESCompatibleCheckRes*
///
-(NSURLSessionTask*) spaceV1ApiPackageCompatibleGetWithAppPkgName: (NSString*) appPkgName
    appPkgType: (NSObject*) appPkgType
    boxPkgName: (NSString*) boxPkgName
    boxPkgType: (NSObject*) boxPkgType
    curAppVersion: (NSString*) curAppVersion
    curBoxVersion: (NSString*) curBoxVersion
    completionHandler: (void (^)(ESCompatibleCheckRes* output, NSError* error)) handler {
    // verify the required parameter 'appPkgName' is set
    if (appPkgName == nil) {
        NSParameterAssert(appPkgName);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appPkgName"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'appPkgType' is set
    if (appPkgType == nil) {
        NSParameterAssert(appPkgType);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appPkgType"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'boxPkgName' is set
    if (boxPkgName == nil) {
        NSParameterAssert(boxPkgName);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxPkgName"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'boxPkgType' is set
    if (boxPkgType == nil) {
        NSParameterAssert(boxPkgType);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxPkgType"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'curAppVersion' is set
    if (curAppVersion == nil) {
        NSParameterAssert(curAppVersion);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"curAppVersion"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'curBoxVersion' is set
    if (curBoxVersion == nil) {
        NSParameterAssert(curBoxVersion);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"curBoxVersion"] };
            NSError* error = [NSError errorWithDomain:kESPlatformServiceApiErrorDomain code:kESPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/package/compatible"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (appPkgName != nil) {
        queryParams[@"app_pkg_name"] = appPkgName;
    }
    if (appPkgType != nil) {
        queryParams[@"app_pkg_type"] = appPkgType;
    }
    if (boxPkgName != nil) {
        queryParams[@"box_pkg_name"] = boxPkgName;
    }
    if (boxPkgType != nil) {
        queryParams[@"box_pkg_type"] = boxPkgType;
    }
    if (curAppVersion != nil) {
        queryParams[@"cur_app_version"] = curAppVersion;
    }
    if (curBoxVersion != nil) {
        queryParams[@"cur_box_version"] = curBoxVersion;
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
                              responseType: @"ESCompatibleCheckRes*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESCompatibleCheckRes*)data, error);
                                }
                            }];
}



@end
