#import "ESOpenApiPlatformServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESSecretCheckResult.h"


@interface ESOpenApiPlatformServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESOpenApiPlatformServiceApi

NSString* kESOpenApiPlatformServiceApiErrorDomain = @"ESOpenApiPlatformServiceApiErrorDomain";
NSInteger kESOpenApiPlatformServiceApiMissingParamErrorCode = 234513;

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
///  @param appletId  
///
///  @param appletSecret  
///
///  @param boxRegKey  
///
///  @returns ESSecretCheckResult*
///
-(NSURLSessionTask*) spaceV1ApiAppletCheckSecretGetWithAppletId: (NSString*) appletId
    appletSecret: (NSString*) appletSecret
    boxRegKey: (NSString*) boxRegKey
    completionHandler: (void (^)(ESSecretCheckResult* output, NSError* error)) handler {
    // verify the required parameter 'appletId' is set
    if (appletId == nil) {
        NSParameterAssert(appletId);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletId"] };
            NSError* error = [NSError errorWithDomain:kESOpenApiPlatformServiceApiErrorDomain code:kESOpenApiPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'appletSecret' is set
    if (appletSecret == nil) {
        NSParameterAssert(appletSecret);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"appletSecret"] };
            NSError* error = [NSError errorWithDomain:kESOpenApiPlatformServiceApiErrorDomain code:kESOpenApiPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    // verify the required parameter 'boxRegKey' is set
    if (boxRegKey == nil) {
        NSParameterAssert(boxRegKey);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"boxRegKey"] };
            NSError* error = [NSError errorWithDomain:kESOpenApiPlatformServiceApiErrorDomain code:kESOpenApiPlatformServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/applet/check-secret"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (appletId != nil) {
        queryParams[@"applet_id"] = appletId;
    }
    if (appletSecret != nil) {
        queryParams[@"applet_secret"] = appletSecret;
    }
    if (boxRegKey != nil) {
        queryParams[@"box_reg_key"] = boxRegKey;
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
                              responseType: @"ESSecretCheckResult*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESSecretCheckResult*)data, error);
                                }
                            }];
}



@end
